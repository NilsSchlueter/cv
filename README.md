# Lebenslauf (CV)

Zweisprachiger (DE/EN), **ATS-optimierter** Lebenslauf. Die Quelldaten, die
Prüfungen und der PDF-Build liegen im **Freelancing Hub** (privates Repo
`freelance-hub`, Bereich `cv`). Dieses Repo enthält die Wissensbasis
([`CLAUDE.md`](CLAUDE.md)), die Review-Schleife und die deterministische
PDF-Prüfung, dazu einen Lesespiegel der Quelldaten unter `data/`.

```
Hub (Postgres)  ──build_cv──▶  PDF + Markdown + JSON Resume je Sprache  ──npm run pull──▶  dist/  +  data/ (Spiegel)
```

Inhaltliche Grundsatzentscheidungen (Positionierung, Kompetenzen, Tech-Zeilen,
Auslastung, Layout) und abgelehnte Vorschläge stehen in [`CLAUDE.md`](CLAUDE.md).

Kernmerkmale:

- **Maschinenlesbar:** einspaltiger, linearer Fließtext (der Briefkopf trägt
  Name/Kontakt neben einem optionalen Foto), echte Textebene, keine Tabellen für
  Struktur, Standard-Überschriften. Zusätzlich ist die passende `resume.<lang>.json`
  ([JSON Resume](https://jsonresume.org)) als **Attachment im PDF eingebettet**,
  sodass ATS-Systeme und KI-Tools die strukturierten Rohdaten direkt auslesen können.
- **Mehrsprachig ohne Duplikate:** Gemeinsame Daten werden einmal gepflegt;
  sprachspezifische Texte liegen als `{ "de": "…", "en": "…" }` im selben Feld.

## Ablauf

Inhalte ändern sich nur über die MCP-Tools des Hubs (z. B. aus Claude Code mit
verbundenem Hub):

1. **Lesen:** `get_cv` (ohne Argumente: Übersicht; mit `slug` oder `section`:
   vollständiges JSON).
2. **Ändern:** `save_cv_entry` (eine Station, vollständig) bzw.
   `update_cv_section` (`basics`, `skills`, `education`, vollständig). DE und EN
   immer gemeinsam. Die Reihenfolge der Stationen im Lebenslauf ist gespeichert:
   `reorder_cv_entries` (oder `/cv` → „Reihenfolge“ im Hub); neue Stationen
   ordnet der Hub chronologisch ein.
3. **Bauen:** `build_cv` (`strict: true` vor dem Versand). Fehler blockieren den
   Build, Warnungen (z. B. Seitenzahl ≠ 4) werden genannt. Das Tool liefert eine
   signierte Pull-URL, 15 Minuten gültig; `list_cv_builds` liefert frische URLs.
4. **Holen:** `npm run pull -- '<pull_url>'` lädt PDFs, Markdown und JSON Resume
   nach `dist/` und schreibt die Quelldaten des Builds nach `data/`.
5. **Prüfen:** `npm run check:pdf` (einmalig vorher `npm run check:setup`).
6. `data/` committen, wenn sich etwas geändert hat.

Ergebnis in `dist/` (Datum = Build-Monat):

- `Schlueter_Nils_Senior-Fullstack_Profil_DE_<YYYY-MM>.pdf` und `.md`
- `Schlueter_Nils_Senior-Fullstack_Profile_EN_<YYYY-MM>.pdf` und `.md`
- `resume.de.json`, `resume.en.json` (dieselben Daten, die im PDF eingebettet sind)

Die Web-Oberfläche des Hubs (`/cv`) zeigt dieselben Daten mit Prüfhinweisen und
baut ebenfalls; Downloads dort brauchen keinen Pull.

### Word-Version für Vermittler

Manche Agenturen wollen DOCX. Aus dem Markdown-Export (benötigt
[pandoc](https://pandoc.org), macOS: `brew install pandoc`):

```bash
npm run docx       # dist/*.md -> dist/*.docx
```

### Foto

Das Foto liegt im Hub. Tauschen: MCP-Tool `cv_photo_upload_url` liefert einen
fertigen `curl`-Befehl, der `assets/photo.jpg` hochlädt (JPEG, max. 5 MB), oder
in der Web-Oberfläche unter „Foto“. Standard: beide Sprachen **mit** Foto; für
Bewerbungen außerhalb des DACH-Raums `build_cv` mit `photo_en: false`.

> Wichtig: Das Foto ist ein reines Bild-Element. Es darf **keine** Informationen
> (Name, Kontakt) enthalten, die nicht auch als echter Text im PDF stehen.

### Offene Platzhalter `[[TODO: …]]`

Fehlende Fakten stehen als `[[TODO: Frage]]` direkt in den Quelldaten und sind
im PDF sichtbar. Der Build nennt sie als Warnung; mit `strict: true` blockieren
sie ihn.

## Datenformat

`data/` spiegelt die Quelldaten des letzten Builds. **Nicht von Hand
bearbeiten** — der nächste Pull überschreibt es.

| Datei                  | Inhalt im Hub                                  |
| ---------------------- | ---------------------------------------------- |
| `data/basics.json`     | Abschnitt `basics`: Name, Kontakt, Verfügbarkeit, Kurzprofil, Profile, Sprachen |
| `data/skills.json`     | Abschnitt `skills`: Kompetenz-Gruppen mit Keywords |
| `data/education.json`  | Abschnitt `education`: Ausbildung              |
| `data/projects/<slug>.json` | eine Station je `slug` (Konvention `YYYY-MM-name`) |
| `data/order.json`      | Reihenfolge der Stationen im Lebenslauf (oben zuerst), versteckte eingeschlossen |

Sprachspezifische Felder sind `{ de, en }`-Objekte, sprachneutrale Werte (z. B.
Firmennamen, Technologien) einfache Strings. Eine Station:

```json
{
  "client": { "de": "Kunde GmbH", "en": "Client Ltd." },
  "role": { "de": "Fullstack-Entwickler", "en": "Full-Stack Developer" },
  "location": "Remote",
  "workload": { "de": "Teilzeit", "en": "part-time" },
  "startDate": "2026-01",
  "endDate": "2026-06",
  "responsibilities": [{ "de": "Aufgabe.", "en": "Responsibility." }],
  "achievements": [{ "de": "Ergebnis.", "en": "Achievement." }],
  "stack": ["Next.js", "TypeScript"]
}
```

- `endDate` **weglassen** = laufende Station, angezeigt als „06/2021 – heute“
  bzw. „Jun 2021 – present“.
- `hidden: true`: Station als Stammdatum behalten, aber nicht in den Lebenslauf
  aufnehmen – erscheint weder im PDF noch im eingebetteten JSON und belegt keine
  Kompetenz (z. B. `2024-04-studio-lenzing`).
- `workload`: Auslastung — wichtig bei parallel laufenden Stationen, sonst wirkt
  der Zeitstrahl überbucht.
- `subprojects`: mehrere parallele Projekte beim selben Kunden als **eine**
  Station mit Unterblöcken (`title`, `responsibilities`, `achievements`,
  `stack`) — siehe `2025-09-pub-tech`. Teilprojekte bekommen bewusst kein
  eigenes Datum.
- `stack` = die wichtigsten Technologien, **höchstens 2 Zeilen** im PDF
  (Aushängeschild-Projekt: 3), Begriffe exakt wie unter Kompetenzen. Jede
  Technologie, die Titel oder Bullets nennen, steht auch in `stack` — sonst
  blockiert der Build. Ausnahme: Grundlagen (JavaScript, REST APIs, HTML, CSS,
  Git) stehen nur unter Kompetenzen.

Zeiträume und Firmenzeile sind Vertragsdaten (Vertragspartner, nicht
Vermittler); sie werden nie aus den Projekten des Hubs übernommen. Im Hub lassen
sich Stationen zusätzlich mit Hub-Projekten verknüpfen.

## Prüfungen

Im Hub (`freelance-hub/src/areas/cv/domain/validate.ts`), bei jedem Build:
(a) Quelldaten gegen das Schema, (b) JSON Resume gegen das offizielle Schema,
(c) Kompetenzen gegen Stationen (Tags und Text), (d) offene `[[TODO]]`, (e)
Technologien aus Titel und Bullets in der Tech-Zeile. Dazu die Seitenzahl.

Hier im Repo:

```bash
npm run check:setup   # einmalig: .venv/ mit pypdf + pdfminer.six
npm run check:pdf     # nach jedem Pull
```

`check:pdf` extrahiert beide PDFs mit pdftotext, pypdf und pdfminer nach
`dist/text/` und prüft die Layout-Regeln (Seitenzahl, Trenner am
Zeilenanfang, zerrissene Komposita, einzelne Wörter, Länge der Tech-Zeilen,
jeder Tag und Zeitraum unversehrt in jeder Extraktion) gegen
`dist/resume.<lang>.json`.

Inhaltlich prüft der Claude-Code-Skill **`/cv-review`**: fünf blinde
Reviewer-Agents (`.claude/agents/cv-*.md` — Hiring Manager, Zeitstrahl, Tech
Lead, ATS-Parser, Lektorat) bewerten die PDFs parallel; der Skill
konsolidiert ihre Befunde gegen `CLAUDE.md`, behebt Eindeutiges per MCP und
fragt nur bei echten Entscheidungen nach.

## Layout

Template und Schriften liegen im Hub unter
`freelance-hub/src/areas/cv/typst/` (`cv.typ`, Typst 0.15.1). Layout-Änderungen
dort committen; wirksam werden sie nach dem Deploy des Hubs.

Die Design-Sprache ist von der eigenen Landing Page ([nils.fyi](https://www.nils.fyi))
übernommen – "warm editorial" statt Corporate-Look:

- **Farbwelt:** weißes Papier (druckt ohne Farbrand, invertiert sauber in
  Dark-Mode-Viewern), warme Tinte (`#241e1a`), **ein** Akzent Terrakotta
  (`#a33e25`: Titelzeile, Firmennamen, Links, Punkte), Ton/Clay nur für
  Trenner, Marker und Hairlines.
- **Schriften:** Instrument Sans für allen Text (400/600); Geist Mono nur für
  Daten in festen Positionen – Zeitraum, Tech-Zeilen, Sektionslabels, Footer –
  und nie mitten in einer Textzeile; Space Grotesk nur für den Namen. Alle SIL
  OFL.
- **Typo-Skala:** 26 / 11.5 / 10 / 8.5 / 7.5pt, ein Zeilenabstand für
  Fließtext, Versalien nur für kurze Labels, Seitenrand 1.8cm.
- **Elemente:** Mono-Versalien-Sektionslabels mit Punkt-Mark und Hairline,
  eine Timeline-Schiene mit Terrakotta-Knoten für Projekthistorie und
  Ausbildung; Tech-Keywords als stille Mono-Zeilen.
- **Reihenfolge:** Profil → Kompetenzen → Projekthistorie → Ausbildung → Sprachen
  (Vermittler lesen zuerst die Top-Skills).

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

## Projektstruktur

```
data/               Lesespiegel der Quelldaten (npm run pull, nicht bearbeiten)
  basics.json, skills.json, education.json
  projects/<slug>.json
assets/photo.jpg    Profilbild (Vorlage für cv_photo_upload_url)
scripts/
  pull.mjs          Build aus dem Hub holen (dist/ + data/)
  check_pdf.py      deterministische PDF-Prüfung
  setup-check.sh    .venv/ für check_pdf.py
.claude/            Review-Skill /cv-review und Reviewer-Agents
dist/               (git-ignored) PDFs, Markdown, JSON Resume des letzten Pulls
```
