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
 * Bricht mit Exit-Code 1 ab, sobald irgendeine Datei fehlschlägt.
 */
import { createRequire } from "node:module";
import { join } from "node:path";
import Ajv, { type ErrorObject } from "ajv";
import addFormats from "ajv-formats";
import {
  DATA,
  GENERATED_DIR,
  LANGS,
  PROJECTS_DIR,
  SCHEMA_DIR,
  listProjectFiles,
  readJson,
} from "./lib";

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
if (failures > 0) {
  console.error(`\nValidierung fehlgeschlagen: ${failures} Datei(en) ungültig.`);
  process.exit(1);
}
console.log("\nValidierung erfolgreich – alle Dateien sind schema-konform.");
