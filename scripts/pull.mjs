/**
 * Holt einen Build aus dem Freelancing Hub, der Quelle des Lebenslaufs:
 *
 *   npm run pull -- '<pull_url>'
 *
 * Die pull_url liefern die MCP-Tools build_cv und list_cv_builds (15 Minuten
 * gültig). Das Skript lädt PDFs, Markdown und JSON Resume nach dist/ und
 * schreibt die Quelldaten des Builds als Lesespiegel nach data/. data/ wird
 * nicht von Hand bearbeitet; Inhalte ändern sich nur per MCP im Hub.
 */
import { execFileSync } from "node:child_process";
import { mkdir, readdir, rm, writeFile } from "node:fs/promises";
import { basename, dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = join(dirname(fileURLToPath(import.meta.url)), "..");
const DIST = join(ROOT, "dist");
const DATA = join(ROOT, "data");
const PROJECTS = join(DATA, "projects");
const SLUG = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

const url = process.argv[2];
if (!url) {
  console.error("Aufruf: npm run pull -- '<pull_url>'  (pull_url aus build_cv oder list_cv_builds)");
  process.exit(1);
}

async function get(target) {
  const res = await fetch(target);
  if (!res.ok) {
    const hint = res.status === 401 ? " — Link abgelaufen? Neue pull_url per list_cv_builds holen." : "";
    throw new Error(`${res.status} bei ${new URL(target).pathname}${hint}`);
  }
  return res;
}

const json = (value) => JSON.stringify(value, null, 2) + "\n";

try {
  const manifest = await (await get(url)).json();
  const { source } = manifest;
  if (!source.basics || !source.skills || !source.education) throw new Error("Build ohne vollständige Quelldaten.");
  for (const f of manifest.files) if (basename(f.name) !== f.name) throw new Error(`Ungültiger Dateiname: ${f.name}`);
  for (const e of source.entries) if (!SLUG.test(e.slug)) throw new Error(`Ungültiger slug: ${e.slug}`);

  // Alles erst laden, dann schreiben: Ein abgebrochener Pull lässt dist/ unverändert.
  const files = await Promise.all(manifest.files.map(async (f) => ({ name: f.name, data: Buffer.from(await (await get(f.url)).arrayBuffer()) })));

  await mkdir(DIST, { recursive: true });
  for (const f of await readdir(DIST)) {
    if (/^Schlueter_Nils_.*\.(pdf|md)$/.test(f) || /^resume\..+\.json$/.test(f)) await rm(join(DIST, f));
  }
  for (const f of files) await writeFile(join(DIST, f.name), f.data);

  await writeFile(join(DATA, "basics.json"), json(source.basics));
  await writeFile(join(DATA, "skills.json"), json(source.skills));
  await writeFile(join(DATA, "education.json"), json(source.education));
  await mkdir(PROJECTS, { recursive: true });
  const keep = new Set(source.entries.map((e) => `${e.slug}.json`));
  for (const e of source.entries) await writeFile(join(PROJECTS, `${e.slug}.json`), json(e.data));
  for (const f of await readdir(PROJECTS)) if (f.endsWith(".json") && !keep.has(f)) await rm(join(PROJECTS, f));

  console.log(`Build ${manifest.id} (${manifest.month}): DE ${manifest.pages.de} Seiten, EN ${manifest.pages.en} Seiten`);
  for (const f of files) console.log(`  dist/${f.name}`);
  const levels = { error: "Fehler", warning: "Warnung", info: "Hinweis" };
  for (const i of manifest.issues) console.log(`  ${levels[i.level] ?? i.level} · ${i.check}${i.slug ? ` · ${i.slug}` : ""}: ${i.message}`);
  if (manifest.issues.length === 0) console.log("  Prüfhinweise: keine");
  const status = execFileSync("git", ["status", "--short", "data/"], { cwd: ROOT, encoding: "utf8" });
  console.log(status ? `\ndata/ geändert:\n${status}` : "\ndata/ unverändert");
} catch (error) {
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
}
