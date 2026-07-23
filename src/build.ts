/**
 * Build-Schritt: kompiliert die versandfertigen Distributions-PDFs nach `dist/`.
 * Läuft nach `prebuild` (gen:schema -> merge -> validate).
 *
 *   dist/CV-<Slug>-DE.pdf
 *   dist/CV-<Slug>-EN.pdf
 *
 * Der Dateiname-Slug wird aus data/basics.json (`name`) abgeleitet.
 *
 * Foto-Steuerung (Standard: DE mit Foto, EN ohne – DACH vs. international):
 *   npm run build                     # Defaults
 *   npm run build -- --photo=false    # beide ohne Foto
 *   npm run build -- --photo-en=true  # EN ausnahmsweise mit Foto
 *   CV_PHOTO_DE=false npm run build   # via Umgebungsvariable
 */
import { execFileSync } from "node:child_process";
import { mkdirSync } from "node:fs";
import { join } from "node:path";
import { Basics } from "./types";
import { ROOT, DATA, DIST_DIR, LANGS, type Lang, readJson, slugify } from "./lib";

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
const slug = slugify(basics.name);

mkdirSync(DIST_DIR, { recursive: true });

for (const lang of LANGS) {
  const photo = photoFor(lang);
  const fileName = `CV-${slug}-${lang.toUpperCase()}.pdf`;
  execFileSync(
    "typst",
    [
      "compile",
      "--root", ROOT,
      "--font-path", join(ROOT, "fonts"),
      "--input", `lang=${lang}`,
      "--input", `photo=${photo}`,
      join(ROOT, "templates", "cv.typ"),
      join(DIST_DIR, fileName),
    ],
    { stdio: "inherit" },
  );
  console.log(`  dist/${fileName}  (Foto: ${photo ? "an" : "aus"})`);
}

console.log("Build fertig.");
