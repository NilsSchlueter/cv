/**
 * Merge-Schritt: liest die zweisprachigen Quelldaten aus `data/` und erzeugt
 * pro Sprache eine schema-konforme JSON-Resume-Datei unter `generated/`.
 *
 *   data/basics.json, skills.json, education.json, projects/*.json
 *        -> generated/resume.de.json
 *        -> generated/resume.en.json
 *
 * Freelance-Engagements (data/projects/*) werden auf JSON-Resume `work`
 * gemappt – das ist die von ATS-Systemen erwartete Standardsektion
 * "Work Experience" / "Berufserfahrung". Der Tech-Stack landet als
 * `keywords` am Work-Eintrag (vom offiziellen Schema als Zusatzfeld erlaubt).
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import { Basics, SkillsFile, EducationFile, Project } from "./types";
import {
  DATA,
  GENERATED_DIR,
  LANGS,
  type Lang,
  listProjectFiles,
  pick,
  readJson,
} from "./lib";

const JSON_RESUME_SCHEMA =
  "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json";

// Quelldaten einlesen + validieren (zod wirft bei Fehlern mit klarer Meldung).
const basics = Basics.parse(readJson(join(DATA, "basics.json")));
const skillsFile = SkillsFile.parse(readJson(join(DATA, "skills.json")));
const educationFile = EducationFile.parse(readJson(join(DATA, "education.json")));
const projects = listProjectFiles().map((f) => Project.parse(readJson(f)));

// Chronologisch absteigend (neuestes Projekt zuerst). "YYYY-MM" sortiert lexikografisch korrekt.
projects.sort((a, b) => b.startDate.localeCompare(a.startDate));

function buildResume(lang: Lang) {
  return {
    $schema: JSON_RESUME_SCHEMA,
    basics: {
      name: basics.name,
      label: pick(basics.label, lang),
      image: "assets/photo.jpg",
      email: basics.email,
      phone: basics.phone,
      url: basics.url,
      summary: pick(basics.summary, lang),
      location: {
        address: basics.location.address,
        postalCode: basics.location.postalCode,
        city: basics.location.city,
        region: basics.location.region,
        countryCode: basics.location.countryCode,
      },
      profiles: basics.profiles.map((p) => ({
        network: p.network,
        username: p.username,
        url: p.url,
      })),
    },
    work: projects.map((p) => ({
      name: pick(p.client, lang),
      position: pick(p.role, lang),
      location: p.location,
      url: p.url,
      startDate: p.startDate,
      endDate: p.endDate, // undefined => laufend
      summary: pick(p.summary, lang),
      highlights: p.highlights.map((h) => pick(h, lang)),
      keywords: p.stack, // Tech-Stack (Zusatzfeld, offiziell additionalProperties: true)
    })),
    skills: skillsFile.skills.map((s) => ({
      name: pick(s.name, lang),
      level: s.level ? pick(s.level, lang) : undefined,
      keywords: s.keywords,
    })),
    education: educationFile.education.map((e) => ({
      institution: e.institution,
      url: e.url,
      area: pick(e.area, lang),
      studyType: pick(e.studyType, lang),
      startDate: e.startDate,
      endDate: e.endDate,
      score: e.score,
    })),
    languages: basics.languages.map((l) => ({
      language: pick(l.language, lang),
      fluency: pick(l.fluency, lang),
    })),
    meta: {
      language: lang,
      canonical: basics.url,
    },
  };
}

mkdirSync(GENERATED_DIR, { recursive: true });
for (const lang of LANGS) {
  const resume = buildResume(lang);
  // JSON.stringify verwirft `undefined`-Felder automatisch -> saubere Ausgabe.
  const file = join(GENERATED_DIR, `resume.${lang}.json`);
  writeFileSync(file, JSON.stringify(resume, null, 2) + "\n");
  console.log(`  generated/resume.${lang}.json  (${resume.work.length} Projekte)`);
}

console.log("Merge abgeschlossen.");
