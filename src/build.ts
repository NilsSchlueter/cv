/**
 * Build-Schritt: kompiliert die versandfertigen Distributions-PDFs nach `dist/`
 * und legt daneben je einen Markdown-Export (Basis für DOCX via pandoc) ab.
 * Läuft nach `prebuild` (gen:schema -> merge -> validate).
 *
 *   dist/Schlueter_Nils_Senior-Fullstack_Profil_DE_2026-10.pdf (+ .md)
 *   dist/Schlueter_Nils_Senior-Fullstack_Profile_EN_2026-10.pdf (+ .md)
 *
 * Nachname/Vorname stammen aus data/basics.json (`name`), das Datum ist der
 * Build-Monat — so ist in Vermittler-Ablagen sofort sichtbar, wie aktuell
 * ein Profil ist.
 *
 * Foto-Steuerung (Standard: DE mit Foto, EN ohne – DACH vs. international):
 *   npm run build                     # Defaults
 *   npm run build -- --photo=false    # beide ohne Foto
 *   npm run build -- --photo-en=true  # EN ausnahmsweise mit Foto
 *   CV_PHOTO_DE=false npm run build   # via Umgebungsvariable
 */
import { execFileSync } from "node:child_process";
import { mkdirSync, readdirSync, rmSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { Basics } from "./types";
import { ROOT, DATA, DIST_DIR, GENERATED_DIR, LANGS, type Lang, readJson, slugify } from "./lib";
import { toMarkdown, type Resume } from "./markdown";

// Rollen-Teil des Dateinamens und Dokumentbezeichnung je Sprache.
const ROLE_SLUG = "Senior-Fullstack";
const DOC_LABEL: Record<Lang, string> = { de: "Profil", en: "Profile" };

// Foto-Default je Sprache.
const photoDefaults: Record<Lang, boolean> = { de: true, en: false };

const args = process.argv.slice(2);

function argVal(name: string): string | undefined {
  const hit = args.find((a) => a.startsWith(`--${name}=`));
  return hit ? hit.slice(name.length + 3) : undefined;
}

function parseBool(v: string | undefined): boolean | undefined {
  if (v === undefined) return undefined;
  const s = v.toLowerCase();
  if (["true", "1", "yes", "on"].includes(s)) return true;
  if (["false", "0", "no", "off"].includes(s)) return false;
  throw new Error(`Ungültiger Boolescher Wert: "${v}" (erwartet true/false).`);
}

const photoAll = parseBool(argVal("photo") ?? process.env.CV_PHOTO);

function photoFor(lang: Lang): boolean {
  const perLang = parseBool(
    argVal(`photo-${lang}`) ?? process.env[`CV_PHOTO_${lang.toUpperCase()}`],
  );
  return perLang ?? photoAll ?? photoDefaults[lang];
}

// Sicherstellen, dass Typst verfügbar ist.
try {
  execFileSync("typst", ["--version"], { stdio: "ignore" });
} catch {
  console.error(
    "Fehler: 'typst' nicht gefunden.\n" +
      "Bitte Typst >= 0.14 installieren, z. B.: brew install typst",
  );
  process.exit(1);
}

const basics = Basics.parse(readJson(join(DATA, "basics.json")));
const nameParts = basics.name.split(" ");
const surname = nameParts.pop() ?? basics.name;
const namePrefix = `${slugify(surname)}_${slugify(nameParts.join(" "))}_`;

const now = new Date();
const buildMonth = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}`;

mkdirSync(DIST_DIR, { recursive: true });

// Ältere Builds (z. B. Vormonat) entfernen, damit dist/ nur den aktuellen
// Stand enthält. Selbst erzeugte .docx-Dateien bleiben unangetastet.
for (const f of readdirSync(DIST_DIR)) {
  if (f.startsWith(namePrefix) && /\.(pdf|md)$/.test(f)) rmSync(join(DIST_DIR, f));
}

for (const lang of LANGS) {
  const photo = photoFor(lang);
  const baseName = `${namePrefix}${ROLE_SLUG}_${DOC_LABEL[lang]}_${lang.toUpperCase()}_${buildMonth}`;
  execFileSync(
    "typst",
    [
      "compile",
      "--root", ROOT,
      "--font-path", join(ROOT, "fonts"),
      "--input", `lang=${lang}`,
      "--input", `photo=${photo}`,
      join(ROOT, "templates", "cv.typ"),
      join(DIST_DIR, `${baseName}.pdf`),
    ],
    { stdio: "inherit" },
  );
  const resume = readJson<Resume>(join(GENERATED_DIR, `resume.${lang}.json`));
  writeFileSync(join(DIST_DIR, `${baseName}.md`), toMarkdown(resume, lang));
  console.log(`  dist/${baseName}.pdf (+ .md)  (Foto: ${photo ? "an" : "aus"})`);
}

console.log("Build fertig.");
