# CV — Wissensbasis für Agents

Zweisprachiger Lebenslauf (DE/EN) für die Bewerbung über IT-Vermittler
(Hays, GULP, freelancermap, Solcom). Deren Parser (Textkernel/Bullhorn) lesen
das PDF — **ATS-Tauglichkeit hat Vorrang**, danach Lesbarkeit für Menschen.
Pipeline und Datenformat: siehe `README.md`.

Die folgenden Entscheidungen wurden mit dem Inhaber getroffen (Stand 10/2026).
**Nicht ohne Rückfrage ändern und abgelehnte Vorschläge nicht erneut
vorschlagen.** Neue Grundsatzentscheidungen hier ergänzen.

## Prüfen vor jedem Commit

- `CV_STRICT=1 npm run build` muss grün sein (Schema, JSON Resume,
  Kompetenzen-Belege, keine `[[TODO]]`).
- Beide PDFs haben **4 Seiten**.
- `pdftotext` sauber: keine Zeile beginnt mit `·` oder `—`, keine zerrissenen
  Komposita, keine gesperrten Einzelbuchstaben.
- Profiltext endet nicht mit einem einzelnen Wort in der letzten Zeile.
- Tech-Zeilen: höchstens 2 Zeilen je Projekt (BMW: höchstens 3).

## Positionierung & Kopf

- Headline: „Senior Fullstack-Entwickler · Webanwendungen · AI-Integration ·
  Headless CMS“ — Leistungen, keine Einzeltechnologien, kein „(Freelance)“.
- **Fullstack statt Frontend:** AI-Integration ist Fullstack-Arbeit (Streaming,
  Tool-Ausführung, Route Handler); Frontend-Suchen finden das Profil über die
  Projekttitel. Projekttitel bleiben, wie beauftragt (Frontend bleibt
  Frontend) — Referenzen bestätigen sie.
- Kontakt: Stadt statt Adresse (keine Straße/PLZ, auch nicht im eingebetteten
  JSON — das Repo ist öffentlich). Website `nilsschlueter.de`, LinkedIn,
  **kein GitHub-Link** (kaum eigene Repos).
- Verfügbarkeit („ab sofort · 100 % · remote, vor Ort in NRW, bundesweit
  reisebereit“) als dritte Zeile im grauen Kontaktblock, nicht abgesetzt.
- DE mit Foto, EN ohne.

## Profil

- ~5 Zeilen: Erfahrung + Stack, AI-Schwerpunkt mit BMW/ARD Sounds als Beleg,
  „alleinverantwortlich wie im großen Team, Startup bis Konzern“.
- Keine Kundenaufzählung, keine Kennzahlen ohne Kontext (die stehen im
  Projekt), keine Floskeln („letzte Meile“).
- „TypeScript/JavaScript“ steht im Profil, weil JavaScript in keiner
  Tech-Zeile steht (Parser rechnen Erfahrungsjahre aus dem Werdegang).
- „über 8 Jahre Erfahrung“ zählt die Werkstudentenzeit mit; sie ist bei Opitz
  offen ausgewiesen.

## Kompetenzen

- **Keine Skill-Jahre** — wirkt veraltet, Parser leiten Dauer selbst ab,
  aus Tags berechnete Jahre übertreiben.
- Drei Gruppen: **Webentwicklung · AI-Integration · Headless CMS & SEO**,
  jeweils nach Wichtigkeit sortiert (Frameworks vor Sprachen, Grundlagen
  JavaScript/HTML/CSS/Git am Ende). Keine Aufteilung nach Schichten.
- Jede Kompetenz ist in mindestens einem Projekt belegt — als Tag oder im
  Fließtext (`src/validate.ts`, Prüfung c). Ausnahme: JavaScript, REST APIs,
  HTML, CSS, Git.
- HTML, CSS, Git bleiben (ATS-Mussbegriffe in Stellenanzeigen), am Ende.
- AI nur mit Projektbeleg: RAG, pgvector, Anthropic wurden mangels Beleg
  entfernt. ARD Sounds = Frontend für ein AI-Backend → keine AI-Tags.
- „AI-Assisted Development (Claude Code)“ bleibt, auch für
  Enterprise-Kunden.

## Projekte & Tech-Zeilen

- Tech-Zeile = die wichtigsten Technologien, max. 2 Zeilen. Reihenfolge:
  prägende Technologien zuerst (AI-Tags bei AI-Projekten, CMS bei
  CMS-Projekten, Angular · TypeScript · NgRx · RxJS bei Angular-Projekten),
  danach wie unter Kompetenzen.
- Nicht in Tech-Zeilen: Grundlagen (JavaScript, REST APIs, HTML, CSS, Git)
  und Begriffe, die Titel oder Bullets schon nennen — Parser lesen den
  Fließtext mit. Kern-Tags dürfen doppelt stehen.
- ISR nur bei Content-Websites, Claude Code nur bei Interhyp, Chatbot nur bei
  BMW — jeder Tag dort, wo er am meisten aussagt.
- Kennzahlen nur mit Kontext; keine KI-klingenden Nachsätze
  („— niedrigere Kosten, schnellere Ladezeiten“).
- „Weiterentwicklung“, wo eine Vorversion existierte (ARD Sounds,
  hilfe.ard.de) — nicht „Entwicklung“/„Aufbau“.
- Keine Zukunft als Fakt: BMW-US-Rollout steht als „Vorbereitung … (geplant
  für Ende Oktober 2026)“. Nach dem Go-live aktualisieren.
- Fullstack-Projekte nennen je ein konkretes Backend-Detail.
- pub.tech (ARD) ist **ein** Engagement mit drei Teilprojekten.
- BMW: AI-Fokus im Titel („AI Assistant … (Generative UI)“), Angular steht
  im Bullet.

## Zeiträume & Auslastung

- **Daten sind faktisch und werden nie verschoben**, um Überschneidungen zu
  glätten. Vermittler speichern alte CV-Versionen, Daten sind über Verträge
  und Referenzen prüfbar.
- Es lief immer ein Vollzeit- und höchstens ein Teilzeitprojekt.
  Teilzeitprojekte (ARD, Vidlab7, Dash0, eco.income) tragen `workload`
  „Teilzeit“ / „part-time“ — bewusst ohne Tage/Woche (mehr Spielraum).
  abo-store: „nebenberuflich“.
- Opitz: „Werkstudent bis 09/2019, danach Festanstellung“ (überschneidet sich
  mit dem Master).
- Laufende Einträge enden mit „heute“ / „present“, nicht mit dem Build-Monat.

## Sprache & Ausbildung

- Durchgehend generisches Maskulinum (keine Gender-Doppelpunkte).
- „AI“ in Titeln und Tags; „KI“ darf im deutschen Fließtext stehen (beides
  wird gesucht).
- Bachelor: „Bachelor of Science (Ingenieur)“ — der Titel steht so im
  Zeugnis.
- Noten genau wie im Zeugnis: Master „sehr gut (1,4)“, Bachelor „sehr gut
  (86 %)“. Die unterschiedlichen Skalen stammen von den Hochschulen und
  werden nicht umgerechnet oder angeglichen.
- Sektionsname „Projekthistorie“ / „Project Experience“ (ohne „(Auszug)“,
  alle Projekte sind gelistet).

## Layout & Maschinenlesbarkeit

- 4 Seiten. **Geschützte Umbrüche:** Einträge mit ≥ 3 Bullets dürfen
  umbrechen, aber Kopf + erste zwei Bullets und letzter Bullet + Tech-Zeile
  bleiben zusammen; Teilprojekte brechen nur zwischeneinander.
- Schriften: Instrument Sans für Text, Geist Mono nur für Daten/Tech-Zeilen/
  Labels/Footer, Space Grotesk nur für den Namen. Fünf Größen, ein Akzent
  (Terrakotta), weißer Seitenhintergrund.
- Keine U+2011-Bindestriche (fehlen in den Fonts, brechen die Suche) —
  Bindestrich-Komposita hält eine Box-Regel im Template zusammen.
- Versalien-Tracking ≤ 0.08em, genau ein Leerzeichen um Trenner, `CO₂` als
  CO + Tiefstellung (extrahiert als „CO2“).

## Abgelehnt — nicht erneut vorschlagen

Skill-Jahre · kein Foto in DE · GitHub-Link · U+2011 · Synonymblöcke im
Profil · „jeder Tag aus ≥ 2 Projekten muss unter Kompetenzen“ · Ista auf 12
Tags kürzen · „Angular 2+“ · HTML/CSS/Git in jeder Tech-Zeile ·
„AI-Augmented Engineering Workflows“ statt Claude Code · Headline „Frontend
für AI“ · Daten verschieben · Auslastung als „2–3 Tage/Woche“ ·
Bachelor-Note in eine Dezimalnote umrechnen.
