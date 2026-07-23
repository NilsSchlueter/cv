/** Gemeinsame Helfer für die Merge-/Validierungs-/Build-Scripts. */
import { readFileSync, readdirSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, join, resolve } from "node:path";
import type { L } from "./types";

/** Projekt-Wurzelverzeichnis (ein Level über src/). */
export const ROOT = resolve(dirname(fileURLToPath(import.meta.url)), "..");
export const DATA = join(ROOT, "data");
export const PROJECTS_DIR = join(DATA, "projects");
export const SCHEMA_DIR = join(ROOT, "schema");
export const GENERATED_DIR = join(ROOT, "generated");
export const DIST_DIR = join(ROOT, "dist");
export const ASSETS_DIR = join(ROOT, "assets");

export const LANGS = ["de", "en"] as const;
export type Lang = (typeof LANGS)[number];

/** JSON-Datei einlesen und parsen. */
export function readJson<T = unknown>(path: string): T {
  return JSON.parse(readFileSync(path, "utf8")) as T;
}

/** Alle Projektdateien (data/projects/*.json), alphabetisch sortiert. */
export function listProjectFiles(): string[] {
  return readdirSync(PROJECTS_DIR)
    .filter((f) => f.endsWith(".json"))
    .sort()
    .map((f) => join(PROJECTS_DIR, f));
}

/** Löst ein `L`-Feld (String oder `{ de, en }`) für eine Zielsprache auf. */
export function pick(value: L, lang: Lang): string {
  return typeof value === "string" ? value : value[lang];
}

/**
 * Erzeugt einen dateisystem-tauglichen Slug aus dem Namen.
 * Umlaute werden ausgeschrieben ("Schlüter" -> "Schlueter").
 */
export function slugify(input: string): string {
  const umlauts: Record<string, string> = {
    ä: "ae", ö: "oe", ü: "ue", Ä: "Ae", Ö: "Oe", Ü: "Ue", ß: "ss",
  };
  return input
    .replace(/[äöüÄÖÜß]/g, (c) => umlauts[c] ?? c)
    .normalize("NFKD")
    .replace(/[̀-ͯ]/g, "") // übrige diakritische Zeichen entfernen
    .replace(/[^a-zA-Z0-9]+/g, "-")
    .replace(/^-+|-+$/g, "");
}
