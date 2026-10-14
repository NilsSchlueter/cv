/**
 * Zweistufige Validierung (läuft via `prebuild` automatisch vor jedem Build):
 *
 *   (a) Quelldateien (data/*) gegen die eigenen, generierten JSON-Schemata
 *       (schema/*). Das ist derselbe Vertrag, den VS Code per `$schema` nutzt –
 *       so kann die Pipeline nichts durchlassen, was der Editor grün anzeigt.
 *
 *   (b) Die generierten Dateien (generated/resume.*.json) gegen das offizielle
 *       JSON-Resume-Schema (@jsonresume/schema).
 *
 *   (c) Kompetenzen gegen Projekte: Vermittler-Datenbanken werten einen
 *       Skill erst als belegt, wenn er in einem Projekt steht (Tag oder
 *       Fließtext). Warnt bei Kompetenzen ohne Projekt (Ausnahme: Grundlagen
 *       wie JavaScript, REST APIs, HTML, CSS, Git);
 *       listet Tags aus >= 2 Projekten, die nicht unter Kompetenzen stehen
 *       (nur Info — die Liste ist bewusst kuratiert).
 *
 *   (d) Offene `[[TODO …]]`-Platzhalter in data/ (Datei:Zeile). Warnung im
 *       normalen Build, Abbruch mit CV_STRICT=1 (Release-Builds in der CI).
 *
 * Bricht mit Exit-Code 1 ab, sobald irgendeine Datei fehlschlägt.
 */
import { readFileSync, readdirSync } from "node:fs";
import { createRequire } from "node:module";
import { join, relative } from "node:path";
import Ajv, { type ErrorObject } from "ajv";
import addFormats from "ajv-formats";
import {
  DATA,
  GENERATED_DIR,
  LANGS,
  PROJECTS_DIR,
  ROOT,
  SCHEMA_DIR,
  listProjectFiles,
  pick,
  projectTags,
  readJson,
} from "./lib";
import { Project, SkillsFile } from "./types";

const require = createRequire(import.meta.url);
const officialResumeSchema = require("@jsonresume/schema/schema.json");

// strict: false -> zod-to-json-schema und das offizielle Schema nutzen Konstrukte
// (z. B. $ref-Geschwister), die ajv im Strict-Mode sonst bemängeln würde.
const ajv = new Ajv({ allErrors: true, strict: false });
addFormats(ajv);

let failures = 0;

function formatErrors(errors: ErrorObject[] | null | undefined): string {
  return (errors ?? [])
    .map((e) => `      - ${e.instancePath || "/"} ${e.message ?? ""}`.trimEnd())
    .join("\n");
}

function check(label: string, schema: object, data: unknown): void {
  const validate = ajv.compile(schema);
  if (validate(data)) {
    console.log(`  ok   ${label}`);
  } else {
    failures++;
    console.error(`  FAIL ${label}`);
    console.error(formatErrors(validate.errors));
  }
}

/* -------------------------------------------------------------------------- */
console.log("(a) Quelldateien gegen eigenes Schema:");

const schemaFor = (name: string) => readJson<object>(join(SCHEMA_DIR, name));

check("data/basics.json", schemaFor("basics.schema.json"), readJson(join(DATA, "basics.json")));
check("data/skills.json", schemaFor("skills.schema.json"), readJson(join(DATA, "skills.json")));
check("data/education.json", schemaFor("education.schema.json"), readJson(join(DATA, "education.json")));

const projectSchema = schemaFor("project.schema.json");
for (const file of listProjectFiles()) {
  check(`data/projects/${file.slice(PROJECTS_DIR.length + 1)}`, projectSchema, readJson(file));
}

/* -------------------------------------------------------------------------- */
console.log("\n(b) Generierte Dateien gegen offizielles JSON-Resume-Schema:");

for (const lang of LANGS) {
  check(
    `generated/resume.${lang}.json`,
    officialResumeSchema,
    readJson(join(GENERATED_DIR, `resume.${lang}.json`)),
  );
}

/* -------------------------------------------------------------------------- */
console.log("\n(c) Kompetenzen gegen Projekte (Tags + Text):");

// safeParse: ungültige Dateien hat (a) bereits gemeldet.
const projects = listProjectFiles().flatMap((f) => {
  const r = Project.safeParse(readJson(f));
  return r.success ? [r.data] : [];
});
const skillsFile = SkillsFile.safeParse(readJson(join(DATA, "skills.json")));
const skillGroups = skillsFile.success ? skillsFile.data.skills : [];
const skillKeywords = skillGroups.flatMap((s) => s.keywords);
// Gruppennamen zählen als gelistet ("Headless CMS & SEO: Sanity · …").
const groupNames = skillGroups.flatMap((s) => LANGS.flatMap((l) => pick(s.name, l).split(" & ")));
const listed = new Set([...skillKeywords, ...groupNames]);
// Grundlagen aus jedem Projekt: einmal unter Kompetenzen, bewusst nicht in
// jeder Tech-Zeile.
const IMPLIED = new Set(["JavaScript", "REST APIs", "HTML", "CSS", "Git"]);
// Detail-Klammer ignorieren: "Accessibility (WCAG)" wird von "accessibility" belegt.
const base = (tag: string) => tag.replace(/\s*\(.*\)$/, "");
// Auch der Fließtext belegt: Parser lesen Titel und Bullets mit, daher steht
// ein dort genannter Begriff (z. B. "Payload CMS" bei BMW) nicht noch einmal
// in der Tech-Zeile.
const projectText = projects
  .flatMap((p) => [p.role, ...p.responsibilities, ...p.achievements,
    ...p.subprojects.flatMap((s) => [s.title, ...s.responsibilities, ...s.achievements])])
  .flatMap((v) => LANGS.map((l) => pick(v, l)))
  .join("\n")
  .toLowerCase();
const inText = (k: string) => projectText.includes(k.toLowerCase()) || projectText.includes(base(k).toLowerCase());

const tagCounts = new Map<string, number>();
for (const p of projects) {
  for (const tag of projectTags(p)) tagCounts.set(tag, (tagCounts.get(tag) ?? 0) + 1);
}
const backed = new Set([...tagCounts.keys()].flatMap((tag) => [tag, base(tag)]));
const unbacked = skillKeywords.filter((k) => !IMPLIED.has(k) && !backed.has(k) && !inText(k));
const unlisted = [...tagCounts]
  .filter(([tag, n]) => n >= 2 && !listed.has(tag) && !listed.has(base(tag)))
  .map(([tag, n]) => `${tag} (${n})`);

if (unbacked.length > 0) {
  console.warn(`  WARN Kompetenz ohne Projekt-Beleg: ${unbacked.join(", ")}`);
} else {
  console.log("  ok   jede Kompetenz steht in mindestens einem Projekt");
}
if (unlisted.length > 0) {
  console.log(`  info in >= 2 Projekten, nicht unter Kompetenzen: ${unlisted.join(", ")}`);
}

/* -------------------------------------------------------------------------- */
console.log("\n(d) Offene Platzhalter [[TODO …]]:");

const dataFiles = [
  ...readdirSync(DATA).filter((f) => f.endsWith(".json")).map((f) => join(DATA, f)),
  ...listProjectFiles(),
];
const todos = dataFiles.flatMap((file) =>
  readFileSync(file, "utf8")
    .split("\n")
    .flatMap((line, i) =>
      [...line.matchAll(/\[\[TODO[^\]]*\]\]/g)].map((m) => `${relative(ROOT, file)}:${i + 1}  ${m[0]}`),
    ),
);

if (todos.length === 0) {
  console.log("  ok   keine");
} else {
  for (const todo of todos) console.warn(`  TODO ${todo}`);
  if (process.env.CV_STRICT === "1") {
    failures++;
    console.error(`  FAIL ${todos.length} offene Platzhalter (CV_STRICT=1)`);
  } else {
    console.warn(`  WARN ${todos.length} offene Platzhalter — vor dem Versand füllen`);
  }
}

/* -------------------------------------------------------------------------- */
if (failures > 0) {
  console.error(`\nValidierung fehlgeschlagen: ${failures} Datei(en) ungültig.`);
  process.exit(1);
}
console.log("\nValidierung erfolgreich – alle Dateien sind schema-konform.");
