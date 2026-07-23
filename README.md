# Lebenslauf (CV)

Zweisprachiger (DE/EN), **ATS-optimierter** Lebenslauf. Strukturierte Quelldaten
werden zu schema-konformen [JSON-Resume](https://jsonresume.org)-Dateien gemerged
und mit [Typst](https://typst.app) zu versandfertigen PDFs gerendert.

```
data/*.json  ──merge──▶  generated/resume.<de|en>.json  ──typst──▶  dist/CV-<Name>-<DE|EN>.pdf
 (zweisprachig)            (JSON Resume, je Sprache)                  (+ eingebettete resume.json)
```

Kernmerkmale:

- **Maschinenlesbar:** Single-Column-Layout, echte Textebene, keine Tabellen für
  Struktur, Standard-Überschriften, lineare Lesereihenfolge. Zusätzlich ist die
  passende `resume.<lang>.json` als **Attachment im PDF eingebettet** (`pdf.attach`),
  sodass ATS-Systeme und KI-Tools die strukturierten Rohdaten direkt auslesen können.
- **Mehrsprachig ohne Duplikate:** Gemeinsame Daten werden einmal gepflegt;
  sprachspezifische Texte liegen als `{ "de": "…", "en": "…" }` in derselben Datei.
- **Einfach pflegbar:** Neues Projekt = eine neue JSON-Datei, dann `npm run build`.
  Autocomplete & Validierung im Editor via JSON Schema + TypeScript.

## Voraussetzungen

| Tool  | Version   | Installation                                  |
| ----- | --------- | --------------------------------------------- |
| Node  | ≥ 20      | <https://nodejs.org>                          |
| Typst | ≥ 0.14 \* | `brew install typst` (macOS) · [Releases][tr] |

\* `pdf.attach` (das PDF-Attachment) gibt es ab Typst 0.14. In Typst 0.13 hieß die
Funktion noch `pdf.embed`; sie wurde in 0.14 in `pdf.attach` umbenannt. Getestet mit 0.15.

[tr]: https://github.com/typst/typst/releases

## Schnellstart

```bash
npm install        # einmalig
npm run build      # baut beide PDFs nach dist/
```

Ergebnis:

- `dist/CV-Nils-Schlueter-DE.pdf` — Deutsch, **mit** Foto
- `dist/CV-Nils-Schlueter-EN.pdf` — Englisch, **ohne** Foto

Der Dateiname-Slug wird automatisch aus `data/basics.json` (`name`) abgeleitet
(Umlaute werden ausgeschrieben, z. B. „Schlüter" → `Schlueter`).

## Daten pflegen

Alle Inhalte liegen unter `data/`. Sprachspezifische Felder sind `{ de, en }`-Objekte;
sprachneutrale Werte (z. B. Firmennamen, Technologien) sind einfache Strings.

| Datei                | Inhalt                                        |
| -------------------- | --------------------------------------------- |
| `data/basics.json`   | Name, Kontakt, Kurzprofil, Profile, Sprachen  |
| `data/skills.json`   | Skill-Gruppen mit Keywords                    |
| `data/education.json`| Ausbildung                                    |
| `data/projects/*.json` | **eine Datei pro Projekt/Engagement**       |

Beim Editieren in VS Code liefert die `$schema`-Zeile am Dateianfang Autocomplete
und Inline-Validierung.

### Neues Projekt hinzufügen

1. Neue Datei in `data/projects/` anlegen, z. B. `2026-neues-projekt.json`
   (Dateiname egal – Sortierung erfolgt automatisch chronologisch absteigend).
2. Als Vorlage eine bestehende Datei kopieren. Minimalstruktur:

   ```json
   {
     "$schema": "../../schema/project.schema.json",
     "client": { "de": "Kunde GmbH", "en": "Client Ltd." },
     "role": { "de": "Fullstack-Entwickler", "en": "Full-Stack Developer" },
     "location": "Remote",
     "startDate": "2026-01",
     "endDate": "2026-06",
     "summary": { "de": "Kurzbeschreibung.", "en": "Short description." },
     "highlights": [
       { "de": "Ergebnis 1.", "en": "Achievement 1." }
     ],
     "stack": ["Next.js", "TypeScript"]
   }
   ```

   - `endDate` **weglassen** = laufendes Projekt (zeigt „heute" / „Present").
   - `client` darf auch ein einfacher String sein, wenn sprachneutral (`"LogTech GmbH"`).
3. `npm run build`.

### Profilbild tauschen

Das echte Foto einfach unter **gleichem Namen** `assets/photo.jpg` ablegen – sonst
muss nichts angepasst werden. Empfohlen: Hochformat, ca. 3:4, mind. ~600 px hoch.
Aktuell liegt dort ein grauer Platzhalter.

> Wichtig: Das Foto ist ein reines Bild-Element. Es darf **keine** Informationen
> (Name, Kontakt) enthalten, die nicht auch als echter Text im PDF stehen – sonst
> leidet die Maschinenlesbarkeit.

### Foto pro Build an-/abschalten

Standard: DE **mit**, EN **ohne** Foto (außerhalb des DACH-Raums, v. a. US/UK, sind
Fotos im Lebenslauf unüblich bis nachteilig).

```bash
npm run build                     # Defaults (DE an, EN aus)
npm run build -- --photo=false    # beide ohne Foto
npm run build -- --photo=true     # beide mit Foto
npm run build -- --photo-en=true  # nur EN ausnahmsweise mit Foto
CV_PHOTO_DE=false npm run build    # alternativ via Umgebungsvariable
```

## Pipeline & Scripts

`npm run build` führt automatisch zuerst `prebuild` aus:

| Script            | Aufgabe                                                                        |
| ----------------- | ----------------------------------------------------------------------------- |
| `gen:schema`      | JSON-Schemata (`schema/`) aus den TypeScript-Typen (`src/types.ts`) generieren |
| `merge`           | `data/` → `generated/resume.de.json` + `resume.en.json` (JSON Resume)          |
| `validate`        | (a) Quelldaten gegen eigenes Schema, (b) generierte Dateien gegen offizielles JSON-Resume-Schema |
| `build`           | `templates/cv.typ` → beide PDFs nach `dist/`                                    |
| `watch`           | baut bei jeder Änderung automatisch neu                                         |
| `typecheck`       | `tsc --noEmit` über die Scripts                                                 |
| `clean`           | löscht `dist/` und `generated/`                                                 |

Die TypeScript-Typen in `src/types.ts` (mit [zod](https://zod.dev)) sind die
**einzige Wahrheitsquelle**: Daraus werden sowohl die Editor-Schemata als auch die
Laufzeit-Validierung abgeleitet. Der Font (`fonts/Inter.ttf`, [SIL OFL][ofl]) ist im
Repo gebündelt, damit lokale und CI-Builds identisch aussehen.

[ofl]: fonts/OFL.txt

## Continuous Integration & Releases

`.github/workflows/build.yml`:

- **Push / Pull Request:** validieren, beide PDFs bauen, als **Artifacts** anhängen.
- **Version-Tag** (`v*`, z. B. `v2026-07`): zusätzlich ein **GitHub Release** mit den
  beiden PDFs – für versionierte, teilbare Stände.

```bash
git tag v2026-07
git push origin v2026-07   # löst Release-Build aus
```

## Projektstruktur

```
data/               Quelldaten (zweisprachig, DRY)
  basics.json, skills.json, education.json
  projects/*.json   eine Datei pro Projekt
assets/photo.jpg    Profilbild (Platzhalter – austauschen)
fonts/              gebündelter Font (Inter, OFL) für reproduzierbare Builds
schema/             generierte JSON-Schemata (Editor-Vertrag)
src/
  types.ts          zod-Typen = Wahrheitsquelle (LocalizedString etc.)
  gen-schema.ts     Typen  -> schema/
  merge.ts          data/  -> generated/resume.*.json
  validate.ts       zweistufige Validierung
  build.ts          Typst-Compile beider Sprachen -> dist/
  watch.ts          optionaler Watch-Modus
  lib.ts            gemeinsame Helfer
templates/cv.typ    Typst-Template (i18n, Foto-Flag, PDF-Metadaten, Attachment)
generated/          (git-ignored) schema-konforme JSON-Resume-Dateien
dist/               (git-ignored) fertige PDFs – Distribution via lokalen Build / Releases
```

## Verifikation der Maschinenlesbarkeit

Nützliche Checks (benötigt `poppler`, macOS: `brew install poppler`):

```bash
pdftotext dist/CV-Nils-Schlueter-DE.pdf -   # Textebene + Lesereihenfolge prüfen
pdfdetach -list dist/CV-Nils-Schlueter-DE.pdf   # eingebettete resume.json anzeigen
pdffonts  dist/CV-Nils-Schlueter-DE.pdf     # Font-Einbettung prüfen
```
