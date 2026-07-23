/**
 * Erzeugt die JSON-Schemata unter `schema/` aus den zod-Typen (src/types.ts).
 *
 * Diese Schemata sind der Editor-Vertrag: Jede Quelldatei referenziert per
 * `$schema` das passende Schema und bekommt so in VS Code Autocomplete +
 * Inline-Validierung. `src/validate.ts` (Stufe a) prüft dieselben Schemata
 * per ajv in der CI, damit Editor und Pipeline exakt übereinstimmen.
 */
import { mkdirSync, writeFileSync } from "node:fs";
import { join } from "node:path";
import type { ZodTypeAny } from "zod";
import { zodToJsonSchema } from "zod-to-json-schema";
import { Basics, SkillsFile, EducationFile, Project } from "./types";
import { SCHEMA_DIR } from "./lib";

const targets: Array<{ file: string; schema: ZodTypeAny; title: string }> = [
  { file: "basics.schema.json", schema: Basics, title: "CV-Quelldaten: Stammdaten (basics.json)" },
  { file: "skills.schema.json", schema: SkillsFile, title: "CV-Quelldaten: Skills (skills.json)" },
  { file: "education.schema.json", schema: EducationFile, title: "CV-Quelldaten: Ausbildung (education.json)" },
  { file: "project.schema.json", schema: Project, title: "CV-Quelldaten: einzelnes Projekt (projects/*.json)" },
];

mkdirSync(SCHEMA_DIR, { recursive: true });

for (const { file, schema, title } of targets) {
  const jsonSchema = zodToJsonSchema(schema, {
    target: "jsonSchema7",
    // Union `L` (string | {de,en}) wiederholt sich oft -> als Definition auslagern,
    // damit die Schemadateien kompakt und lesbar bleiben.
    $refStrategy: "root",
  });
  (jsonSchema as Record<string, unknown>).title = title;
  writeFileSync(join(SCHEMA_DIR, file), JSON.stringify(jsonSchema, null, 2) + "\n");
  console.log(`  schema/${file}`);
}

console.log("JSON-Schemata generiert.");
