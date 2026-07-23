/**
 * Quellschema für die zweisprachigen CV-Daten.
 *
 * Diese zod-Schemata sind die *einzige Wahrheitsquelle*:
 *  - `z.infer` liefert die TypeScript-Typen (Editor-Autocomplete in den Scripts).
 *  - `src/gen-schema.ts` erzeugt daraus die JSON-Schemata unter `schema/`,
 *    die per `$schema`-Referenz Autocomplete/Validierung in VS Code liefern
 *    und in `src/validate.ts` (Stufe a) gegen die Quelldateien geprüft werden.
 *
 * Sprachspezifische Texte werden NICHT doppelt gepflegt: Ein Feld ist entweder
 * ein einfacher, sprachneutraler String (z. B. Firmenname) ODER ein
 * `{ de, en }`-Objekt. Der Merge-Schritt löst das pro Zielsprache auf.
 */
import { z } from "zod";

/** Ein Text, der sich je Sprache unterscheidet. */
export const LocalizedString = z
  .object({
    de: z.string().min(1),
    en: z.string().min(1),
  })
  .strict();
export type LocalizedString = z.infer<typeof LocalizedString>;

/**
 * "Localized or plain": entweder ein sprachneutraler String (wird für DE und EN
 * gleichermaßen verwendet) oder ein `{ de, en }`-Paar. Vermeidet Duplikate bei
 * Werten wie Firmennamen und erlaubt Lokalisierung, wo sie nötig ist.
 */
export const L = z.union([z.string().min(1), LocalizedString]);
export type L = z.infer<typeof L>;

/** Datumsformat der Quelldaten: "YYYY-MM" (z. B. "2024-07"). */
const YearMonth = z
  .string()
  .regex(/^\d{4}-(0[1-9]|1[0-2])$/, 'Erwartet wird "YYYY-MM", z. B. "2024-07".');

/** Erlaubt eine optionale `$schema`-Zeile in jeder Quelldatei (für VS Code). */
const withSchemaRef = { $schema: z.string().optional() };

/* -------------------------------------------------------------------------- */
/* basics.json                                                                */
/* -------------------------------------------------------------------------- */

export const Profile = z
  .object({
    network: z.string().min(1), // "GitHub", "LinkedIn", ...
    username: z.string().min(1),
    url: z.string().url(),
  })
  .strict();

export const SpokenLanguage = z
  .object({
    language: L, // "Deutsch" / "German"
    fluency: L, // "Muttersprache" / "Native speaker"
  })
  .strict();

export const Location = z
  .object({
    address: z.string().optional(),
    postalCode: z.string().optional(),
    city: z.string().min(1),
    region: z.string().optional(),
    countryCode: z.string().length(2), // ISO 3166-1 alpha-2, z. B. "DE"
  })
  .strict();

export const Basics = z
  .object({
    ...withSchemaRef,
    name: z.string().min(1), // sprachneutral, z. B. "Nils Schlüter"
    label: L, // Jobtitel, z. B. "Freelance Fullstack-Entwickler"
    email: z.string().email(),
    phone: z.string().optional(),
    url: z.string().url().optional(),
    location: Location,
    summary: L, // Profiltext / Kurzprofil
    profiles: z.array(Profile).default([]),
    languages: z.array(SpokenLanguage).default([]),
  })
  .strict();
export type Basics = z.infer<typeof Basics>;

/* -------------------------------------------------------------------------- */
/* skills.json                                                                */
/* -------------------------------------------------------------------------- */

export const Skill = z
  .object({
    name: L, // Gruppenname, z. B. "Frontend"
    level: L.optional(), // z. B. "Experte" / "Expert"
    keywords: z.array(z.string().min(1)).default([]), // sprachneutrale Tech-Begriffe
  })
  .strict();

export const SkillsFile = z
  .object({
    ...withSchemaRef,
    skills: z.array(Skill),
  })
  .strict();
export type SkillsFile = z.infer<typeof SkillsFile>;

/* -------------------------------------------------------------------------- */
/* education.json                                                             */
/* -------------------------------------------------------------------------- */

export const EducationItem = z
  .object({
    institution: z.string().min(1),
    url: z.string().url().optional(),
    area: L, // Fachrichtung, z. B. "Informatik"
    studyType: L, // Abschluss, z. B. "Bachelor of Science"
    startDate: YearMonth,
    endDate: YearMonth.optional(),
    score: z.string().optional(), // Note / GPA
    location: z.string().optional(),
  })
  .strict();

export const EducationFile = z
  .object({
    ...withSchemaRef,
    education: z.array(EducationItem),
  })
  .strict();
export type EducationFile = z.infer<typeof EducationFile>;

/* -------------------------------------------------------------------------- */
/* projects/*.json  (eine Datei pro Projekt/Engagement)                       */
/* -------------------------------------------------------------------------- */

export const Project = z
  .object({
    ...withSchemaRef,
    client: L, // Kunde/Auftraggeber (ggf. "unter NDA")
    role: L, // eigene Rolle, z. B. "Lead Fullstack-Entwickler"
    location: z.string().optional(), // "Remote", "Berlin", ...
    url: z.string().url().optional(),
    startDate: YearMonth,
    endDate: YearMonth.optional(), // weglassen => laufend ("heute"/"Present")
    summary: L, // 1-2 Sätze Kontext
    highlights: z.array(L).default([]), // Ergebnisse/Verantwortlichkeiten
    stack: z.array(z.string().min(1)).default([]), // eingesetzte Technologien
  })
  .strict();
export type Project = z.infer<typeof Project>;
