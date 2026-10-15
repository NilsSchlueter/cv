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
  Kompetenzen-Belege, keine `[[TODO]]`, Technologien aus dem Text in den
  Tags).
- `npm run check:pdf` muss grün sein: 4 Seiten, keine Zeile beginnt mit `·`
  oder `—`, keine zerrissenen Komposita, keine Zeile mit nur einem Wort,
  Tech-Zeilen höchstens 2 Zeilen (BMW: 3), jeder Tag/Zeitraum kommt bei
  pdftotext, pypdf und pdfminer unversehrt an. Einmalig `npm run check:setup`.
- Inhaltliche Prüfung: Skill `/cv-review` (fünf blinde Reviewer-Agents,
  `.claude/agents/cv-*.md`). Deren Befunde gegen diese Datei filtern.

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

- „Bewährt sowohl in eigenverantwortlicher Arbeit als auch in großen,
  verteilten Teams“ (EN „Equally effective working autonomously and …“).
- „von der Konzeption bis zum Go-live“ (nicht „Architektur“ — in
  Kundenprojekten nur als Mitgestaltung belegt); BMW als „SSE-Streaming“, nicht
  „LLM-Streaming“ (gebaut wurde das Rendering).
- ~5 Zeilen: Erfahrung + Stack, AI-Schwerpunkt mit BMW und der
  KI-Trainingsplan-Software (continuum) als Beleg — nicht ARD Sounds (dort nur
  Frontend, zwei Reviews hielten das für überverkauft). „eigenverantwortlich
  wie im großen Team, Startup bis Konzern“ — nicht „allein-“ oder
  „hauptverantwortlich“, das decken die Bullets nicht durchgehend.
- Keine Kundenaufzählung, keine Kennzahlen ohne Kontext (die stehen im
  Projekt), keine Floskeln („letzte Meile“).
- „TypeScript/JavaScript“ steht im Profil und im Opitz-Bullet: Parser rechnen
  Erfahrungsjahre nur aus den Stationen, das Profil zählt dafür nicht.
- „seit 2018 professionell mit TypeScript/JavaScript, heute vor allem mit
  React/Next.js und Angular“ — die Jahreszahl hängt nur an
  TypeScript/JavaScript (Opitz 2018), die Frameworks stehen ohne Jahr: Vier
  Reviews lasen „seit 2018 … React/Next.js“ als Behauptung (React/Next.js
  erst ab 2021). Kein „über 8 Jahre Erfahrung“ (Reviews rechnen die
  Werkstudentenzeit heraus), keine zwei Jahreszahlen im Satz.

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
- „EU AI Act“ steht nur im BMW-Bullet, nicht unter Kompetenzen (ist keine
  Kompetenz; Parser finden es im Fließtext).
- Keine Guardrails, weder im BMW-Bullet noch unter Kompetenzen: Das Frontend
  hat einen Stream gerendert, und Guardrails im Angular-Client hielten zwei
  Reviews für ein Warnsignal.
- „AI-Assisted Development (Claude Code / GitHub Copilot)“ bleibt, auch für
  Enterprise-Kunden (Copilot hat Interhyp bereitgestellt). Schrägstrich statt
  Komma: Die PDF-Keywords sind kommagetrennt.
- Produktnamen wie beim Hersteller („NgRx SignalStore“).
- Englische Fachbegriffe ohne Bindestrich in beiden Sprachen: „LLM
  Integration“, „CMS Migration“ (Tags sind sprachneutral).

## Projekte & Tech-Zeilen

- Tech-Zeile = die wichtigsten Technologien, max. 2 Zeilen. Reihenfolge:
  prägende Technologien zuerst (AI-Tags bei AI-Projekten, CMS bei
  CMS-Projekten, Angular · TypeScript · NgRx · RxJS bei Angular-Projekten),
  danach wie unter Kompetenzen.
- **Jede Technologie aus Titel oder Bullets steht auch in der Tech-Zeile**
  desselben Eintrags bzw. Teilprojekts — Leser nehmen die Tech-Zeile als
  Stack des Projekts, drei Reviews bemängelten die Lücken. `validate.ts` (e)
  bricht sonst ab. Ausnahme: Grundlagen (JavaScript, REST APIs, HTML, CSS,
  Git) stehen nur unter Kompetenzen.
- Wird eine Tech-Zeile dadurch zu lang, fliegen Tags, die der Text nicht
  nennt und die andere Projekte schon belegen (Interhyp ohne GROQ/Live
  Preview/ISR, continuum ohne Generative AI/Tailwind/TypeScript).
- ISR nur bei Content-Websites, Chatbot nur bei BMW — jeder Tag dort, wo er
  am meisten aussagt. Claude Code steht bei abo-store (eigenes Unternehmen,
  keine Compliance-Frage); bei Kunden nur, was der Kunde bereitgestellt hat
  (Interhyp: GitHub Copilot).
- Kennzahlen nur mit Kontext; keine KI-klingenden Nachsätze
  („— niedrigere Kosten, schnellere Ladezeiten“).
- „Weiterentwicklung“, wo eine Vorversion existierte (ARD Sounds,
  hilfe.ard.de) — nicht „Entwicklung“/„Aufbau“.
- Keine Zukunft als Fakt: BMW-US-Rollout steht als „Vorbereitung … (geplant
  für Ende Oktober 2026)“. Nach dem Go-live aktualisieren.
- Keine Vertragsdetails in Projektbeschreibungen (Vertragsende, Laufzeit,
  Konditionen) — auch nicht als Entschärfung („planmäßiges Vertragsende zum
  Go-live“). Die Frage „warum nicht bis zum US-Rollout?“ wird im Gespräch
  beantwortet.
- Fullstack-Projekte nennen je ein konkretes Backend-Detail.
- pub.tech (ARD) ist **ein** Engagement mit drei Teilprojekten — als
  getrennte Einträge wirkte es wie vier parallele Projekte. Teilprojekte
  bekommen **kein eigenes Datum**: Parser lesen datierte Zeilen als eigene
  Station ohne Arbeitgeber, und die Zeiträume machten die Parallelität zu BMW
  sichtbar. Die Reihenfolge (tagesschau zuerst, ARD Sounds 2026) erklärt das
  Gespräch.
- ARD Sounds: Titel „(Frontend für ein AI-Produkt)“ — Nische „Frontend für
  AI-Produkte“, ehrlich formuliert; „AI-Produkt & Multi-Sender-Rollout“
  hielten zwei Reviews für AI-Washing (gebaut wurde nur das Frontend). Der
  Rollout steht im Ergebnis-Bullet.
- ARD-CMS-Migration: Das neue CMS heißt Unified Sophora — im Bullet und als
  Tag „Sophora“ (Tech-Zeilen-Regel). Handlebars erklärt der Komponenten-Bullet
  („serverseitige Handlebars-Templates, React für interaktive Komponenten“),
  sonst fragt jeder Tech Lead nach der Rendering-Architektur.
- „einziger Entwickler“ nur, wo es keine Referenz widerlegen kann: eco.income
  (nur fürs Frontend). Bei pub.tech keine Rollen-Claims („haupt-“, „allein-“),
  nur die Arbeit — andere haben mitcommittet, und zwei „Hauptrollen“ neben
  BMW wirkten überbucht.
- Nur mit Beitrag, nicht mit Team-Ergebnis werben: Interhyp „Mitarbeit an der
  Migration“ (kam während des Projekts dazu; Go-live erst nach dem Ausstieg,
  daher nicht „termingerecht“), BMW „Entwicklung von Komponenten“ und
  „Mitarbeit am internen CMS“ (Team mit rund 20 Entwicklern; EN Bullet 2
  nominal „Frontend development of …“, nicht „Developed the frontend of …“ —
  las sich als Verantwortung fürs ganze Frontend), eco.income
  „Mitarbeit an … Node.js-Backend (Koa, TypeORM)“.
- eco.income: Frontend ist React (CRA), nicht Next.js. Ein TÜV-geprüfter
  Algorithmus schätzt Scope 1–3 allein aus Bankdaten — das war der USP
  („ohne Verbrauchsdaten“). Der wiederkehrende Einwand „Scope 1/2 geht nicht
  aus Bankdaten“ ist damit beantwortet; so stehen lassen. Firebase war dort
  nur Auth → Tag „Firebase Authentication“ (Produktname; die Kompetenz
  „Firebase“ belegt continuum). Nicht „Firebase Auth“: Das steht im
  continuum-Bullet, und `validate.ts` (e) verlangte den Tag dann auch dort.
- continuum: LLM-Teil konkret benennen (zweistufig: Vorschläge per
  Structured Outputs, dann Scoring; Ersatzübungen bei Verletzungen). AI
  Agents/Tool Calling bestätigt der Inhaber. Die 60 % sind die
  Generierungszeit der Trainingspläne (optimierte Algorithmen); das
  Frontend-Caching steht als Ergänzung dahinter, nicht als Quelle der Zahl.
  „Backend-Entwicklung“ bleibt — der MVP hatte so gut wie keins.
- Vidlab7: Titel bleibt „Frontend“ (wie beauftragt), Prisma/PostgreSQL steht
  als Backend-Detail im Bullet. Tag „MediaStream API“ (MDN-Name), nicht
  „getUserMedia“ (Methode, keine Technologie) und nicht „WebRTC“ (überzogen).
- BMW: Das Frontend rendert die per SSE gestreamten Antworten — kein Tool
  Calling/Structured Outputs bei BMW (das belegt continuum). Preise und
  Verbrauchs-/Emissionswerte kommen deterministisch aus Fahrzeugdaten, nicht
  vom LLM. Payload CMS: eigene Collections, Lokalisierung je Markt. Voice
  ohne „Web Speech API“ (nicht bestätigt).
- continuum „agentisch“: Ein Agent passt bestehende Trainingspläne im
  Chat per Tool Calling an; dazu automatische Tageszusammenfassungen aus
  Vortagstraining und Gesundheitswerten mehrerer Quellen.
- Interhyp: Backend-Detail ist die Caching-Strategie (Next.js Data Cache,
  tag-basierte Revalidierung per Sanity-Webhook).
- Opitz: Java als Bullet und Tag („Mitarbeit an Java-Backends (Spring Boot,
  Microservices)“), nicht unter Kompetenzen — Angular + Java ist der
  klassische Enterprise-Stack und Backend-Beleg im Konzern.
- Infrastruktur nur, wo genutzt: Kubernetes, Docker, Keycloak, Jenkins hat der
  Inhaber benutzt (Pods deployen, Skalierung prüfen, Logs in Pods lesen,
  Login anbinden), nie aufgesetzt — so im Gespräch. Der Kubernetes-Bullet
  steht bei ista; Micro Frontends dort mit Module Federation. Kein Terraform
  (IaC nie geschrieben).
- Schaeffler: Die Code-Standards galten konzernweit (bestätigt).
- Für die Kennzahlen (ista 80 %, Interhyp 50 %, continuum 60 %) gibt es keine
  Vorher-/Nachher-Werte — nicht erneut erfragen. Formulierung wie DE („Ergebnis
  der Migration …: bis zu 80 %“), kein Doppel-Hedge („Helped cut … by up to“).
- Kein Anschein von Weisungsbefugnis über Festangestellte
  (Scheinselbstständigkeit — Vermittler prüfen das): ista „technischer
  Ansprechpartner eines der beiden Entwicklungsteams“, Vidlab7
  „Wissenstransfer an die ersten festen Teammitglieder“.
- abo-store: Titel ohne „& Mitgründer“ (die einzige laufende Station wird im
  ATS zur aktuellen Position), „als Mitgründer“ steht im Bullet. „06/2021 –
  heute“ bleibt — die 2025-Versionen bei den Vermittlern zeigen die Station
  als laufend; der Bullet „Aktive Entwicklung bis 2023, seitdem nur Betrieb“
  (Jahr im Bullet, nicht in der Firmenzeile — Opitz-Muster) markiert sie als
  keine parallele Arbeit. Besucherzahl „zeitweise über 10.000“ — heute
  niedriger, und Sistrix prüft das in 30 Sekunden.
- Ergebnisse nach dem eigenen Ausstieg nicht als eigenes Ergebnis: Interhyp
  „mit Fokus auf den Erhalt der SEO-Assets“ statt „ohne Verlust“; BMW EN
  „Supported the go-live“; ARD Sounds „Umsetzung der Ausweitung“ (die
  Ausweitung haben die Sender entschieden).
- Kurzeinsätze ohne Mehrwert dürfen fehlen: Studio Lenzing/Dash0 (04/2024)
  steht bewusst nicht im CV (Überschneidung mit ista; Sanity/Next.js belegen
  Interhyp und abo-store). Die Daten bleiben als Stammdatum erhalten
  (`data/projects/2024-04-studio-lenzing.json`, `"hidden": true`) – nicht
  löschen, nicht einblenden.
- Firmennamen wie vom Unternehmen geschrieben: „ista SE“.
- BMW: AI-Fokus im Titel („AI Assistant … (Generative UI)“), Angular steht
  im Bullet.
- Firmenzeile = nur der Vertragspartner mit Rechtsnamen („Interone
  (Omnicom-Gruppe)“, „Public Value Technologies GmbH (pub.tech)“), nicht die
  Holding; der Endkunde steht im Titel („AI Assistant für BMW“,
  „ARD-Digitalangebote“). Parser speichern die Firmenzeile als Arbeitgeber.
  Vermittler/Recruiter stehen nicht in der Firmenzeile: BMW lief über einen
  Vermittler, die Firmenzeile bleibt Interone — so wenig, wie man Hays als
  Arbeitgeber nennt; Referenzen sind die Projektbeteiligten, nicht der Einkauf.
- Umbenannte Firmen: damaliger Name, heutiger in Klammern („continuum (heute
  House 120)“) — passt zu älteren CV-Versionen und zur Referenzprüfung.
  Vidlab7 GmbH heißt rechtlich weiter so, nur die Marke heißt heute moonscale:
  Hinweis im ersten Bullet („(heute moonscale)“), nicht in der Firmenzeile.
- „(remote)“ an allen Remote-Stationen (BMW, Interhyp, pub.tech, continuum,
  Vidlab7, eco.income, Schaeffler) — sonst wirken parallele Projekte in
  verschiedenen Städten unmöglich.

## Zeiträume & Auslastung

- **Daten sind faktisch und werden nie verschoben**, um Überschneidungen zu
  glätten. Vermittler speichern alte CV-Versionen, Daten sind über Verträge
  und Referenzen prüfbar.
- Es lief immer ein Vollzeit- und höchstens ein Teilzeitprojekt.
  Teilzeitprojekte (ARD, Vidlab7, eco.income) tragen `workload`
  „Teilzeit“ / „part-time“ — bewusst ohne Tage/Woche (mehr Spielraum).
  abo-store: „nebenberuflich“.
- Opitz: „Werkstudent bis 09/2019 (parallel zum Master), danach
  Festanstellung“ als erster Bullet, nicht in der Firmenzeile — dort liest
  pdfminer „09/2019“ vor dem Zeitraum.
- Laufende Einträge enden mit „heute“ / „present“, nicht mit dem Build-Monat.
- Maßgeblich sind Vertragsdaten, nicht Commit-Daten: continuum bleibt
  12/2025, pub.tech beginnt 09/2025 (vom Inhaber bestätigt, trotz früherer
  bzw. späterer Commits). pub.tech endete 10/2026.

## Sprache & Ausbildung

- Durchgehend generisches Maskulinum (keine Gender-Doppelpunkte).
- „AI“ in Titeln und Tags; „KI“ darf im deutschen Fließtext stehen (beides
  wird gesucht) — aber nie beides im selben Satz.
- Bachelor: „Bachelor of Science (Ingenieur)“ — der Titel steht so im
  Zeugnis.
- Noten genau wie im Zeugnis: Master „sehr gut (1,4)“, Bachelor „sehr gut
  (86 %)“. Die unterschiedlichen Skalen stammen von den Hochschulen und
  werden nicht umgerechnet oder angeglichen.
- Sektionsname „Projekthistorie“ / „Project Experience“ (ohne „(Auszug)“ —
  es fehlt nur der Kurzeinsatz Studio Lenzing).
- Gedankenstrich-Dichte: Doppelpunkt, Komma oder „sowie“/„and“, wo es
  natürlich liest; Gedankenstriche nur, wo sie Arbeit leisten (Profil, Rolle
  als Nachsatz). 31 Striche auf vier Seiten lasen zwei Reviews als
  KI-Schreibstil; Stand 10/2026: 19 je Sprache (10 davon in Titeln, 2 bei
  Sprachen).
- EN: „Further developed“ nicht viermal (Germanismus) — Enhanced / Extended /
  Continued development of; DE „Weiterentwicklung“ bleibt.

## Layout & Maschinenlesbarkeit

- 4 Seiten. **Geschützte Umbrüche:** Einträge mit ≥ 3 Bullets dürfen
  umbrechen, aber Kopf + erste zwei Bullets und letzter Bullet + Tech-Zeile
  bleiben zusammen; Teilprojekte brechen nur zwischeneinander.
- Schriften: Instrument Sans für Text, Geist Mono nur für Daten/Tech-Zeilen/
  Labels/Footer, Space Grotesk nur für den Namen. Fünf Größen, ein Akzent
  (Terrakotta), weißer Seitenhintergrund.
- Keine U+2011-Bindestriche (fehlen in den Fonts, brechen die Suche) —
  Bindestrich-Komposita hält eine Box-Regel im Template zusammen, ebenso
  Ergänzungsstriche („Bestell- und“), die sonst als „Bestellund“ extrahiert
  werden.
- Versalien-Tracking ≤ 0.08em, genau ein Leerzeichen um Trenner. In den
  Daten steht „CO2“; das Template setzt die Tiefstellung (Text und
  eingebettetes JSON bleiben „CO2“).
- Deutscher Gedankenstrich ist der Halbgeviertstrich mit Leerzeichen („ – “),
  im Englischen der Geviertstrich („ — “).
- **Kerning aus:** Mit Kerning zerlegt pypdf (Basis vieler AI-Screenings)
  Wörter an Kerning-Paaren („T ailwind“, „T erraform“). Prüfen mit pypdf,
  pdfminer und pdftotext — Parsing-Behauptungen aus AI-Reviews erst
  nachstellen, viele waren erfunden („Angular“ im Interhyp-Kopf, verklebte
  Daten/Tags; 10/2026: kyrillisches „№х (Мопотеро)“ für „Nx (Monorepo)“, „Al“
  statt „AI“, fehlendes „use“ in „use-case-specific“, Tags in fremden
  Kopfzeilen, fehlende Datums-Striche — alles in allen drei Extraktoren
  widerlegt).
- `pdfinfo` meldet „Suspects object is wrong type (boolean)“ — Eigenheit des
  Tagged PDF aus Typst 0.15, nur poppler, Extraktion unberührt. Kein
  Handlungsbedarf.
- Eingebettetes JSON: `image` nur, wenn das Foto im PDF ist (`build.ts` passt
  die generierte Datei je Sprache an) — die Anlage soll zum sichtbaren
  Dokument passen.
- Keine einzelnen Wörter in der letzten Zeile eines Bullets (DE und EN).
- Parser-Struktur (Review-Schleife 10/2026, mit pdfminer nachgestellt):
  Bullet-Marker als normaler Text mit normalem Wortabstand im selben Absatz
  (jede breitere Lücke lesen pdftotext/pdfminer als Spaltengrenze); Footer nur
  mit Seitenzahl (Name oder Berufsbezeichnung mitten in einer Station werden
  zur Blockgrenze bzw. Phantom-Station); Teilprojekte mit Label
  „Teilprojekt:“ (sonst eigene datumslose Station); E-Mail/Telefon als
  mailto:/tel:-Links; Ausbildungs-Zeitraum in
  der Hochschulzeile (rechts ohne Bullets darunter sortiert pdfminer ihn
  hinter „Sprachen“); Komposita mit Punkt („Node.js-Backend“) hält die
  Box-Regel ebenfalls zusammen.

## Abgelehnt — nicht erneut vorschlagen

Skill-Jahre · kein Foto in DE · GitHub-Link · U+2011 · Synonymblöcke im
Profil · „jeder Tag aus ≥ 2 Projekten muss unter Kompetenzen“ · Ista auf 12
Tags kürzen · „Angular 2+“ · HTML/CSS/Git in jeder Tech-Zeile ·
„AI-Augmented Engineering Workflows“ statt Claude Code · Headline „Frontend
für AI“ · Daten verschieben · Auslastung als „2–3 Tage/Woche“ ·
Bachelor-Note in eine Dezimalnote umrechnen · „(Ingenieur)“/„(86 %)“
weglassen · Vidlab7-Onboarding-Bullet streichen ·
pub.tech zu einem Eintrag ohne Teilprojekte zusammenfassen · BMW-US-Rollout
streichen · Verfügbarkeit „ab 11/2026“ statt „ab sofort“ · eingebettetes
JSON aus dem PDF entfernen · Profil entkoppeln („(TypeScript, React,
Angular), seit 2018 in der Softwareentwicklung“) · „laut Zeugnis“ an die
Bachelor-Note · Auslastung in Prozent · „Vollzeit“-Label an Hauptprojekten ·
Headline „Senior Frontend- & Fullstack“ · „(Ingenieur)“ in die Fachrichtung
verschieben · „Lead“ aus dem ista-Titel · Infra-Tags bei Opitz/Schaeffler
kürzen · ARD-Bullets kürzen · Kompetenzen auf ~35 · abo-store mit Enddatum
2023 · Vertragsdetails („planmäßiges Vertragsende“) im BMW-Bullet · zwei
Jahreszahlen im Profilsatz („Angular seit 2018, React seit 2021“) ·
Vermittler in der Firmenzeile.
