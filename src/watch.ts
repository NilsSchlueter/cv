/**
 * Optionaler Watch-Modus: beobachtet Quelldaten, Template, Foto und Types und
 * baut bei Änderungen automatisch neu (npm run build inkl. prebuild).
 *
 *   npm run watch
 */
import { execSync } from "node:child_process";
import { watch } from "node:fs";
import { ASSETS_DIR, DATA, ROOT } from "./lib";
import { join } from "node:path";

const watched = [
  DATA,
  ASSETS_DIR,
  join(ROOT, "templates"),
  join(ROOT, "src"),
];

let timer: NodeJS.Timeout | undefined;
let building = false;

function rebuild(reason: string): void {
  if (building) return;
  building = true;
  console.log(`\n[watch] Änderung erkannt (${reason}) – baue neu ...`);
  try {
    execSync("npm run build", { cwd: ROOT, stdio: "inherit" });
    console.log("[watch] Fertig. Warte auf Änderungen ... (Strg+C zum Beenden)");
  } catch {
    console.error("[watch] Build fehlgeschlagen – warte auf nächste Änderung.");
  } finally {
    building = false;
  }
}

function schedule(reason: string): void {
  clearTimeout(timer);
  timer = setTimeout(() => rebuild(reason), 200); // debounce
}

for (const dir of watched) {
  watch(dir, { recursive: true }, (_event, file) => schedule(file ?? "unbekannt"));
}

console.log("[watch] Beobachte data/, assets/, templates/, src/ ...");
rebuild("Initialer Build");
