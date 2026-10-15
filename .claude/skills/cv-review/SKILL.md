---
name: cv-review
description: Lokale Review-Schleife für den Lebenslauf — baut die PDFs, prüft sie deterministisch, lässt fünf blinde Reviewer-Agents (Hiring Manager, Zeitstrahl, Tech Lead, ATS-Parser, Lektorat) parallel prüfen, konsolidiert ihre Befunde gegen CLAUDE.md, behebt Eindeutiges und fragt den Inhaber nur nach echten Entscheidungen. Verwenden, wenn der Lebenslauf geprüft, kritisch bewertet oder für eine Bewerbung fertig gemacht werden soll.
---

# CV-Review-Schleife

Ersetzt das Kopieren externer AI-Reviews. Die Reviewer sind **blind**: Sie
sehen nur, was ein Empfänger bekommt (PDFs, Textlayer). Das Wissen über
getroffene Entscheidungen bringst **du** beim Konsolidieren ein — aus
`CLAUDE.md`. Lies `CLAUDE.md` vollständig, bevor du anfängst.

## 1. Bauen und deterministisch prüfen

```bash
CV_STRICT=1 npm run build && npm run check:pdf
```

`check:pdf` extrahiert beide PDFs nach `dist/text/` (pdftotext, pypdf,
pdfminer) und prüft die Layout-Regeln. Fehlt `.venv/`, zuerst
`npm run check:setup`. Rote Prüfungen sind Regelverstöße: erst beheben, dann
weiter.

## 2. Reviewer starten — alle fünf in **einer** Nachricht, parallel

| Agent | Blickwinkel |
| ----- | ----------- |
| `cv-hiring-manager` | Glaubwürdigkeit, Red Flags, Einladungsentscheidung |
| `cv-timeline-auditor` | Monatsrechnung, Überschneidungen, Erfahrungsjahre |
| `cv-tech-lead` | technische Plausibilität, Tiefe, Tags vs. Text |
| `cv-ats-parser` | Felder und Zeichen aus echten Extraktionen |
| `cv-language-editor` | DE/EN-Lektorat, Konsistenz, Abweichungen |

Agent-Tool mit `subagent_type` = Agent-Name; Prompt: „Prüfe den aktuellen
Stand in dist/ und berichte im vorgegebenen Format." Sind die Typen in der
Sitzung (noch) nicht verfügbar, `general-purpose` mit dem Inhalt der Datei
`.claude/agents/<name>.md` (ohne Frontmatter) als Prompt. Erzähl den
Reviewern nichts über frühere Runden oder Entscheidungen. Hinweis:
Subagents bekommen `CLAUDE.md` trotzdem in den Kontext (ggf. in einem
älteren Stand) — sie sind nur weitgehend blind; Verweise auf die
Wissensbasis in Berichten ignorieren, Befunde trotzdem filtern.

## 3. Konsolidieren

1. **Zusammenführen:** gleiche Stelle + gleiches Problem aus mehreren
   Berichten = ein Befund; notiere, wie viele Agents ihn melden.
2. **Prüfen:** Steht das Zitat wirklich in `dist/text/`? Lässt sich ein
   Parsing-Befund in den Extrakten oder per Befehl nachstellen? Nicht
   Nachstellbares verwerfen.
3. **Einordnen** — jeder Befund in genau eine Gruppe:
   - **Erledigt/abgelehnt:** widerspricht einer Entscheidung in `CLAUDE.md`
     oder steht unter „Abgelehnt". Nicht umsetzen, nicht erneut vorschlagen;
     nur im Abschlussbericht kurz nennen. Wiederkehrende Punkte wandern in
     die Liste der Interviewfragen.
   - **Direkt beheben:** Formulierung, Grammatik, Konsistenz DE/EN,
     Typografie, Layout, Tags vs. Text, Regelverstöße — alles, was keine
     Entscheidung aus `CLAUDE.md` ändert und keine neuen Fakten braucht.
   - **Inhaber fragen:** ändert eine Entscheidung aus `CLAUDE.md`, braucht
     Fakten, die nur der Inhaber kennt (was er gebaut hat, Auslastung,
     Zahlen, Vertragspartner), oder fügt Behauptungen hinzu bzw. streicht
     Inhalte.
4. **Nie:** Daten verschieben, Zahlen, Auslastungen oder Behauptungen
   erfinden, unbestätigte Fakten ergänzen.

## 4. Beheben

Änderungen in `data/` (Layout in `templates/cv.typ`), immer DE und EN
gemeinsam. Danach Schritt 1 erneut — beides muss grün sein.

## 5. Schleife

Hat die Runde etwas behoben, startet die nächste Runde mit Schritt 2 — höchstens
**drei Runden**. Schluss, sobald eine Runde keine neuen behebbaren Befunde ab
**Medium** mehr liefert. Jede Runde kostet fünf Agent-Läufe.

## 6. Inhaber fragen

Alle offenen Entscheidungen gesammelt per AskUserQuestion, höchstens vier je
Aufruf, deine Empfehlung als erste Option mit „(Recommended)". Antworten
umsetzen, dann Schritt 1.

## 7. Festhalten

Neue Entscheidungen in die passende Sektion von `CLAUDE.md`, abgelehnte
Vorschläge in „Abgelehnt — nicht erneut vorschlagen". So meldet die nächste
Schleife sie zwar wieder, du filterst sie aber sofort.

## 8. Abschlussbericht an den Inhaber

- was geändert wurde (Runde, Befund, Änderung)
- was verworfen wurde und warum (Entscheidung, nicht nachstellbar, falsch)
- offene Entscheidungen
- Interviewfragen, die bleiben, weil der Lebenslauf bewusst so ist
- Stand: Build und `check:pdf` grün, Seitenzahl
