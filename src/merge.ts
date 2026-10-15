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
 * (im PDF als "Projekthistorie" / "Project Experience"). Der Tech-Stack landet als
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
  loadProjects,
  pick,
  projectTags,
  readJson,
} from "./lib";

const JSON_RESUME_SCHEMA =
  "https://raw.githubusercontent.com/jsonresume/resume-schema/v1.0.0/schema.json";

// Quelldaten einlesen + validieren (zod wirft bei Fehlern mit klarer Meldung).
const basics = Basics.parse(readJson(join(DATA, "basics.json")));
const skillsFile = SkillsFile.parse(readJson(join(DATA, "skills.json")));
const educationFile = EducationFile.parse(readJson(join(DATA, "education.json")));
// Jede Datei muss parsen (klare Fehlermeldung); in den Lebenslauf kommen nur
// die sichtbaren (`hidden: true` bleibt Stammdatum, siehe lib.ts).
for (const f of listProjectFiles()) Project.parse(readJson(f));
const projects = loadProjects();

// Chronologisch absteigend (neuestes Projekt zuerst). "YYYY-MM" sortiert
// lexikografisch korrekt. Bei gleichem Startmonat entscheidet das Enddatum
// (laufende Projekte zuerst, dann spätere Enden) — statt zufällig der Dateiname.
const endKey = (p: Project) => p.endDate ?? "9999-99";
projects.sort(
  (a, b) =>
    b.startDate.localeCompare(a.startDate) || endKey(b).localeCompare(endKey(a)),
);

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
      // Kein offizielles JSON-Resume-Feld, aber schema-konform (das offizielle
      // Schema erlaubt Zusatzfelder) und so auch im PDF-Anhang maschinenlesbar.
      availability: basics.availability ? pick(basics.availability, lang) : undefined,
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
    work: projects.map((p) => {
      const responsibilities = p.responsibilities.map((h) => pick(h, lang));
      const achievements = p.achievements.map((h) => pick(h, lang));
      const subprojects = p.subprojects.map((s) => ({
        title: pick(s.title, lang),
        responsibilities: s.responsibilities.map((h) => pick(h, lang)),
        achievements: s.achievements.map((h) => pick(h, lang)),
        keywords: s.stack,
      }));
      return {
        name: pick(p.client, lang),
        position: pick(p.role, lang),
        location: p.location ? pick(p.location, lang) : undefined,
        url: p.url,
        startDate: p.startDate,
        endDate: p.endDate, // undefined => laufend
        // JSON-Resume-Standard: alle Punkte in `highlights` (ATS/generische Tools).
        // Teilprojekt-Punkte tragen ihren Titel als Präfix, damit sie flach
        // gelesen noch zuordenbar sind.
        highlights: [
          ...responsibilities,
          ...achievements,
          ...subprojects.flatMap((s) =>
            [...s.responsibilities, ...s.achievements].map((h) => `${s.title}: ${h}`),
          ),
        ],
        // Zusatzfelder (additionalProperties: true) für die strukturierte
        // Darstellung im Typst-Template und im Markdown-Export:
        workload: p.workload ? pick(p.workload, lang) : undefined,
        responsibilities,
        achievements,
        subprojects,
        keywords: projectTags(p), // Tech-Stack inkl. Teilprojekte
      };
    }),
    skills: skillsFile.skills.map((s) => ({
      name: pick(s.name, lang),
      level: s.level ? pick(s.level, lang) : undefined,
      keywords: s.keywords,
    })),
    education: educationFile.education.map((e) => ({
      institution: pick(e.institution, lang),
      url: e.url,
      area: pick(e.area, lang),
      studyType: pick(e.studyType, lang),
      startDate: e.startDate,
      endDate: e.endDate,
      score: e.score ? pick(e.score, lang) : undefined,
      courses: e.courses.map((c) => pick(c, lang)), // Schwerpunkte (JSON-Resume: courses)
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
