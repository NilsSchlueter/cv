# Lebenslauf (CV)

Zweisprachiger (DE/EN), **ATS-optimierter** Lebenslauf. Strukturierte Quelldaten
werden zu schema-konformen [JSON-Resume](https://jsonresume.org)-Dateien gemerged
und mit [Typst](https://typst.app) zu versandfertigen PDFs gerendert.

```
data/*.json  ──merge──▶  generated/resume.<de|en>.json  ──typst──▶  dist/Schlueter_Nils_…_<DE|EN>_<YYYY-MM>.pdf
 (zweisprachig)            (JSON Resume, je Sprache)                  (+ .md, eingebettete resume.json)
```

Inhaltliche Grundsatzentscheidungen (Positionierung, Kompetenzen, Tech-Zeilen,
Auslastung, Layout) und abgelehnte Vorschläge stehen in [`CLAUDE.md`](CLAUDE.md).

Kernmerkmale:

- **Maschinenlesbar:** einspaltiger, linearer Fließtext (der Briefkopf trägt
  Name/Kontakt neben einem optionalen Foto), echte Textebene, keine Tabellen für
  Struktur, Standard-Überschriften. Zusätzlich ist die passende `resume.<lang>.json`
  als **Attachment im PDF eingebettet** (`pdf.attach`), sodass ATS-Systeme und
  KI-Tools die strukturierten Rohdaten direkt auslesen können.
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

Die Design-Sprache ist von der eigenen Landing Page ([nils.fyi](https://www.nils.fyi))
übernommen – "warm editorial" statt Corporate-Look:

- **Farbwelt:** weißes Papier (druckt ohne Farbrand, invertiert sauber in
  Dark-Mode-Viewern), warme Tinte (`#241e1a`), **ein** Akzent Terrakotta
  (`#a33e25`: Titelzeile, Firmennamen, Links, Punkte), Ton/Clay nur für
  Trenner, Marker und Hairlines.
- **Schriften:** Instrument Sans für allen Text (400/600); Geist Mono nur für
  Daten in festen Positionen – Zeitraum, Tech-Zeilen, Sektionslabels, Footer –
  und nie mitten in einer Textzeile; Space Grotesk nur für den Namen. Alle SIL
  OFL, gebündelt unter `fonts/`.
- **Typo-Skala:** 26 / 11.5 / 10 / 8.5 / 7.5pt, ein Zeilenabstand für
  Fließtext, Versalien nur für kurze Labels, Seitenrand 1.8cm (Zeilen ~95
  statt ~100 Zeichen; breiter geht nicht, ohne dass Titel umbrechen).
- **Elemente:** Mono-Versalien-Sektionslabels mit Punkt-Mark und Hairline,
  eine Timeline-Schiene mit Terrakotta-Knoten für Projekthistorie und
  Ausbildung; Tech-Keywords als stille Mono-Zeilen, Kompetenz-Gruppen als
  „**Gruppe:** Keywords“ in der Textschrift.
- **Reihenfolge:** Profil → Kompetenzen → Projekthistorie → Ausbildung → Sprachen
  (Vermittler lesen zuerst die Top-Skills).

Es wird **kein externes Typst-Paket** geladen, Builds laufen also ohne
Netzzugang. Schiene und Punkte sind reine Dekoration ohne Textinhalt –
die ATS-Prinzipien oben bleiben unberührt.

## Schnellstart

```bash
npm install        # einmalig
npm run build      # baut beide PDFs (+ Markdown) nach dist/
```

Ergebnis (Datum = Build-Monat):

- `dist/Schlueter_Nils_Senior-Fullstack_Profil_DE_2026-10.pdf` — Deutsch, **mit** Foto
- `dist/Schlueter_Nils_Senior-Fullstack_Profile_EN_2026-10.pdf` — Englisch, **ohne** Foto
- daneben je eine `.md` mit demselben Inhalt ohne Layout (Basis für Word, s. u.)

Nachname/Vorname kommen aus `data/basics.json` (`name`, Umlaute ausgeschrieben:
„Schlüter" → `Schlueter`). Ältere Builds in `dist/` werden dabei entfernt.

### Word-Version für Vermittler

Manche Agenturen wollen DOCX. Aus dem Markdown-Export (benötigt
[pandoc](https://pandoc.org), macOS: `brew install pandoc`):

```bash
npm run docx       # dist/*.md -> dist/*.docx
```

### Offene Platzhalter `[[TODO: …]]`

Fehlende Fakten stehen als `[[TODO: Frage]]` direkt in den Quelldaten und sind
im PDF sichtbar. `npm run build` listet alle mit Datei:Zeile auf (Validierung,
Schritt d). Release-Builds (Version-Tags) brechen ab, solange welche offen sind
(`CV_STRICT=1`).

## Daten pflegen

Alle Inhalte liegen unter `data/`. Sprachspezifische Felder sind `{ de, en }`-Objekte;
sprachneutrale Werte (z. B. Firmennamen, Technologien) sind einfache Strings.

| Datei                | Inhalt                                        |
| -------------------- | --------------------------------------------- |
| `data/basics.json`   | Name, Kontakt, Eckdaten (Verfügbarkeit), Kurzprofil, Profile, Sprachen |
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

   - `endDate` **weglassen** = laufendes Projekt, angezeigt als
     „06/2021 – heute" bzw. „Jun 2021 – present".
   - `client` darf auch ein einfacher String sein, wenn sprachneutral (`"LogTech GmbH"`).
   - `hidden` (optional, `true`): Projekt als Stammdatum behalten, aber nicht in
     den Lebenslauf aufnehmen – erscheint weder im PDF noch im eingebetteten
     JSON und belegt keine Kompetenz (z. B. `2024-04-studio-lenzing.json`).
     Die Datei wird weiterhin gegen das Schema geprüft.
   - `workload` (optional): Auslastung, z. B. `"60 %"` oder `{ "de": "nebenberuflich", … }` —
     wichtig bei parallel laufenden Projekten, sonst wirkt der Zeitstrahl überbucht.
   - `subprojects` (optional): mehrere parallele Projekte beim selben Kunden als
     **ein** Engagement mit Unterblöcken (`title`, `responsibilities`,
     `achievements`, `stack`) — siehe `2025-09-pub-tech.json`. Teilprojekte
     bekommen bewusst kein eigenes Datum: Parser lesen datierte Zeilen als
     eigene Station ohne Arbeitgeber.
   - Tech-Begriffe in `stack` exakt so schreiben wie in `data/skills.json`
     (z. B. `Tailwind CSS`, `NgRx`): Die Validierung prüft, dass jede Kompetenz
     in mindestens einem Projekt belegt ist.
   - `stack` = die wichtigsten Technologien des Projekts, **höchstens 2 Zeilen**
     im PDF (Ausnahme: max. 3 beim Aushängeschild-Projekt). Reihenfolge nach
     Wichtigkeit: zuerst die prägenden Technologien (AI-Tags bei AI-Projekten,
     das CMS bei CMS-Projekten, Angular · TypeScript · NgRx · RxJS bei
     Angular-Projekten), danach wie unter Kompetenzen.
   - Jede Technologie, die Titel oder Bullets nennen, steht auch in `stack`
     (bzw. im `stack` des Teilprojekts) — die Validierung bricht sonst ab.
     Ausnahme: Grundlagen (JavaScript, REST APIs, HTML, CSS, Git) stehen nur
     unter Kompetenzen.
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
| `validate`        | (a) Quelldaten gegen eigenes Schema, (b) generierte Dateien gegen offizielles JSON-Resume-Schema, (c) Kompetenzen gegen Projekt-Tags, (d) offene `[[TODO]]`-Platzhalter, (e) Technologien aus Titel/Bullets in den Tags |
| `build`           | `templates/cv.typ` → beide PDFs nach `dist/`, plus Markdown-Export              |
| `check:setup`     | einmalig: `.venv/` mit pypdf + pdfminer.six für `check:pdf`                     |
| `check:pdf`       | beide PDFs extrahieren (`dist/text/`) und Layout-Regeln prüfen                  |
| `docx`            | `dist/*.md` → `dist/*.docx` via pandoc                                          |
| `watch`           | baut bei jeder Änderung automatisch neu                                         |
| `typecheck`       | `tsc --noEmit` über die Scripts                                                 |
| `clean`           | löscht `dist/` und `generated/`                                                 |

Die TypeScript-Typen in `src/types.ts` (mit [zod](https://zod.dev)) sind die
**einzige Wahrheitsquelle**: Daraus werden sowohl die Editor-Schemata als auch die
Laufzeit-Validierung abgeleitet. Die Schriften (Instrument Sans, Space Grotesk,
Geist Mono – alle SIL OFL, Lizenztexte unter `fonts/`) sind im Repo gebündelt,
damit lokale und CI-Builds identisch aussehen.

## Continuous Integration & Releases

`.github/workflows/build.yml`:

- **Push / Pull Request:** validieren, beide PDFs (+ Markdown) bauen, als **Artifacts** anhängen.
- **Version-Tag** (`v*`, z. B. `v2026-07`): zusätzlich ein **GitHub Release** mit den
  Dateien – für versionierte, teilbare Stände. Bricht ab, solange `[[TODO]]`-Platzhalter
  offen sind.

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
fonts/              gebündelte Schriften (Instrument Sans, Space Grotesk, Geist Mono; OFL)
schema/             generierte JSON-Schemata (Editor-Vertrag)
src/
  types.ts          zod-Typen = Wahrheitsquelle (LocalizedString etc.)
  gen-schema.ts     Typen  -> schema/
  merge.ts          data/  -> generated/resume.*.json
  validate.ts       zweistufige Validierung
  build.ts          Typst-Compile beider Sprachen -> dist/ (+ Markdown-Export)
  markdown.ts       resume.<lang>.json -> Markdown (Basis für DOCX)
  watch.ts          optionaler Watch-Modus
  lib.ts            gemeinsame Helfer
templates/cv.typ    eigenständiges Typst-Template (nils.fyi-Design-Sprache, Timeline-Einträge, i18n, Foto-Flag, Metadaten, Attachment)
generated/          (git-ignored) schema-konforme JSON-Resume-Dateien
dist/               (git-ignored) fertige PDFs – Distribution via lokalen Build / Releases
```

## Prüfen: deterministisch und per Review-Schleife

```bash
npm run check:setup   # einmalig: .venv/ mit pypdf + pdfminer.six
npm run check:pdf     # nach jedem Build
```

`check:pdf` extrahiert beide PDFs mit pdftotext, pypdf und pdfminer nach
`dist/text/` und prüft die Layout-Regeln (Seitenzahl, Trenner am
Zeilenanfang, zerrissene Komposita, einzelne Wörter, Länge der Tech-Zeilen,
jeder Tag und Zeitraum unversehrt in jeder Extraktion).

Inhaltlich prüft der Claude-Code-Skill **`/cv-review`**: fünf blinde
Reviewer-Agents (`.claude/agents/cv-*.md` — Hiring Manager, Zeitstrahl, Tech
Lead, ATS-Parser, Lektorat) bewerten die PDFs parallel; der Skill
konsolidiert ihre Befunde gegen `CLAUDE.md`, behebt Eindeutiges und fragt nur
bei echten Entscheidungen nach.

## Verifikation der Maschinenlesbarkeit

Nützliche Checks (benötigt `poppler`, macOS: `brew install poppler`):

```bash
pdftotext dist/Schlueter_Nils_*_DE_*.pdf -        # Textebene + Lesereihenfolge prüfen
pdfdetach -list dist/Schlueter_Nils_*_DE_*.pdf    # eingebettete resume.json anzeigen
pdffonts  dist/Schlueter_Nils_*_DE_*.pdf          # Font-Einbettung prüfen
```

Typische Fallen, die das Template bereits abfängt: Zeilenumbruch an
Kompositum-Bindestrichen (Extraktoren machen aus „Bank-|Transaktionsdaten"
„BankTransaktionsdaten"), Letterspacing und große Lücken in einer Textzeile
(werden als Einzelbuchstaben bzw. Spaltengrenzen gelesen) sowie Zeichen, die
in den gebündelten Fonts fehlen (z. B. „₂" → Fallback-Schrift).
