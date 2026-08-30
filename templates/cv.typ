// ---------------------------------------------------------------------------
// cv.typ — zweisprachiger, ATS-orientierter Lebenslauf
//
// Design-Sprache: übernommen von der eigenen Landing Page (nils.fyi) —
// "warm editorial" statt Corporate-Navy:
//   - Farbwelt:   warmes Papier (#f6f3ed), warme Tinte (#241e1a),
//                 Terrakotta-Akzent (#a33e25), Ton/Clay-Konturen (#c69889)
//   - Schriften:  Space Grotesk (Display/Name/Titel), Instrument Sans (Text),
//                 Geist Mono (Daten, Labels, Tech-Stack) — alle SIL OFL,
//                 gebündelt unter fonts/
//   - Elemente:   Punkt-Marks an Sektionslabels und im Footer,
//                 Timeline-Schiene mit Terrakotta-Knoten für Projekte und
//                 Ausbildung, Tech-Keywords als stille Mono-Zeilen
//
// ATS-Prinzipien bleiben unangetastet: Single-Column-Flow, echte Textebene,
// keine Tabellen für Struktur, lineare Lesereihenfolge. Schiene und Punkte
// sind reine Dekoration ohne Textinhalt; die JSON-Resume-Daten sind
// weiterhin als Attachment eingebettet (pdf.attach).
//
// Aufruf (siehe src/build.ts):
//   typst compile --root . --font-path fonts \
//     --input lang=de --input photo=true templates/cv.typ dist/CV-...-DE.pdf
//
// Inputs:
//   lang  = "de" | "en"        (Sprache + passende generated/resume.<lang>.json)
//   photo = "true" | "false"   (Profilfoto im Kopf ein-/ausblenden)
// ---------------------------------------------------------------------------

#let lang = sys.inputs.at("lang", default: "de")
#let show-photo = sys.inputs.at("photo", default: "true") == "true"
#let data = json("/generated/resume." + lang + ".json")
#let b = data.basics

// ---- i18n: Section-Labels & Begriffe --------------------------------------
#let i18n = (
  de: (
    profile: "Profil", experience: "Projekthistorie", skills: "Kompetenzen",
    education: "Ausbildung", languages: "Sprachen",
    grade: "Note", focus: "Fokus", doc: "Lebenslauf",
  ),
  en: (
    profile: "Profile", experience: "Project History", skills: "Skills",
    education: "Education", languages: "Languages",
    grade: "Grade", focus: "Focus", doc: "CV",
  ),
)
#let t = i18n.at(lang, default: i18n.de)

// ---- Farben (Design-Tokens von nils.fyi) ----------------------------------
#let paper = rgb("#f6f3ed") // --background
#let card = rgb("#fbfaf7") // --card
#let ink = rgb("#241e1a") // --foreground
#let muted = rgb("#5f5650") // --muted-foreground
#let rail = rgb("#cdc5ba") // --border, eine Nuance kräftiger für den Druck
#let clay = rgb("#c69889") // --ton (Konturlinien)
#let terra = rgb("#a33e25") // --primary
#let terra-deep = rgb("#852917") // --primary-deep

// ---- Schriften ------------------------------------------------------------
#let sans = "Instrument Sans"
#let display = "Space Grotesk"
#let mono = "Geist Mono"

// ---- Layout-Konstanten ----------------------------------------------------
#let photo-size = 80pt
#let rail-indent = 16pt // Einzug der Einträge rechts der Timeline-Schiene

// ---- Datumsformatierung ---------------------------------------------------
#let months-en = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#let fmt-ym(y, m) = {
  if lang == "de" {
    (if m < 10 { "0" } else { "" }) + str(m) + "/" + str(y) // 07/2026
  } else {
    months-en.at(m - 1) + " " + str(y) // Jul 2026
  }
}
#let fmt-month(s) = {
  let p = s.split("-")
  fmt-ym(int(p.at(0)), int(p.at(1)))
}
// Laufende Projekte (ohne endDate) zeigen bewusst NICHT "heute"/"Present",
// sondern den Monat, in dem das PDF generiert wurde — so trägt jedes Datum
// eine konkrete, maschinenlesbare Angabe.
#let fmt-range(start, end) = {
  let today = datetime.today()
  fmt-month(start) + " – " + (
    if end == none { fmt-ym(today.year(), today.month()) } else { fmt-month(end) }
  )
}

// ---- kleine Helfer --------------------------------------------------------
// Der Punkt: das Logo-Mark der Landing Page (kleiner Terrakotta-Kreis).
#let dot(r: 2.2pt, fill: terra, baseline: -1pt) = box(
  baseline: baseline,
  circle(radius: r, fill: fill),
)
#let sep = text(fill: clay)[ · ]

// Mono-Metadaten (Daten, Kontakt, Stack) — die "Maschinen-Schicht" des Designs.
#let meta-text(body, size: 7.5pt, fill: muted) = text(
  font: mono, size: size, weight: 400, fill: fill, body,
)

// Mono-Uppercase-Label mit Letterspacing (wie "| WEB & AI ENGINEERING").
// Tracking bewusst <= 1.2pt: ab ~1.5pt (bei 8pt) zerfallen die Wörter bei
// Raw-Order-Textextraktion in Einzelbuchstaben ("P R O F I L") — schlecht
// für ATS-Section-Erkennung. 1.2pt ist der verifizierte sichere Wert.
#let mono-label(body, size: 8pt, fill: ink, tracking: 1.2pt) = text(
  font: mono, size: size, weight: 500, tracking: tracking, fill: fill, upper(body),
)

// Bulletliste im Eintrag — Ton-Marker, ruhige, gleichmäßige Zeilen.
#let entry-list(items) = {
  set text(size: 9.5pt)
  list(
    marker: text(fill: clay, size: 9pt)[•],
    spacing: 4.5pt,
    body-indent: 7pt,
    ..items.map(it => [#it]),
  )
}

// Mono-Zeile mit Terrakotta-Label, z. B. "STACK  Next.js · TypeScript · …"
// Grid mit Label-Spalte -> Folgezeilen hängen sauber unter dem Inhalt.
#let labeled-meta(label, items) = grid(
  columns: (auto, 1fr),
  column-gutter: 7pt,
  align: (left + top, left + top),
  // Tracking 1pt: bei 6.8pt Labelgröße der sichere Wert für die Extraktion
  // (die Schwelle skaliert mit der Schriftgröße).
  mono-label(label, size: 6.8pt, fill: terra, tracking: 1pt),
  {
    set par(leading: 0.7em)
    meta-text(items.join(" · "), size: 7pt)
  },
)

// Keyword-Zeile: stille Mono-Metadaten (Tech-Stack der Einträge und
// Keywords der Kompetenz-Gruppen teilen sich dieses Styling).
#let meta-line(items) = {
  set par(leading: 0.7em)
  meta-text(items.join(" · "), size: 7pt)
}

// ---- Ort (Kontaktzeile) ---------------------------------------------------
// Bewusst kompakt: Stadt + Land. Die volle Anschrift bleibt in den Daten und
// damit im maschinenlesbaren JSON-Anhang erhalten.
#let country-names = ("DE": (de: "Deutschland", en: "Germany"))
#let location-str = {
  let code = b.location.countryCode
  let name = country-names.at(code, default: (:)).at(lang, default: code)
  b.location.city + ", " + name
}

// URLs ohne Protokoll/www anzeigen ("nils.fyi") — als Terrakotta-Akzent.
#let display-url(u) = u.replace("https://", "").replace("http://", "").replace("www.", "").trim("/")

// Reihenfolge: Ort · Arbeitsmodus · E-Mail · Telefon · Website · Profile.
#let contact-items = {
  let items = (text(location-str),)
  let avail = b.at("availability", default: none)
  if avail != none and avail != "" { items.push(text(avail)) }
  items.push(text(b.email))
  let phone = b.at("phone", default: none)
  if phone != none and phone != "" { items.push(text(phone)) }
  let site = b.at("url", default: none)
  if site != none {
    items.push(link(site, text(fill: terra, weight: 500, display-url(site))))
  }
  for p in b.at("profiles", default: ()) {
    items.push(link(p.url, text(fill: terra, weight: 500, display-url(p.url))))
  }
  items
}

// ---- Eintrags-Kopf --------------------------------------------------------
// Typo-Hierarchie: Titel (Space Grotesk) > Firma > Mono-Metadaten (Datum/Ort).
#let entry-header(title, org, dates, location) = block(below: 0pt, breakable: false, {
  set par(leading: 0.5em)
  grid(
    columns: (1fr, auto),
    column-gutter: 12pt,
    row-gutter: 5.5pt,
    align: (left + horizon, right + horizon),
    text(font: display, size: 11pt, weight: 600, fill: ink, title),
    meta-text(dates),
    text(size: 9pt, weight: 600, fill: terra-deep, org),
    meta-text(location),
  )
})

// ---- Timeline-Eintrag -----------------------------------------------------
// Jeder Eintrag hängt an einer durchgehenden Schiene (linker Hairline-Strich)
// mit Terrakotta-Knoten auf Titelhöhe — das Prozess-/Timeline-Motiv der
// Landing Page. breakable: false -> ein Eintrag bricht nie über Seiten.
#let rail-entry(body) = block(
  breakable: false,
  above: 0pt,
  below: 0pt,
  inset: (left: rail-indent, top: 17pt),
  stroke: (left: 0.8pt + rail),
  {
    place(dx: -rail-indent - 2.8pt, dy: 3pt, circle(
      radius: 2.8pt,
      fill: paper,
      stroke: 1.2pt + terra,
    ))
    body
  },
)

#let work-entry(w) = rail-entry({
  entry-header(
    w.position,
    w.name,
    fmt-range(w.startDate, w.at("endDate", default: none)),
    w.at("location", default: ""),
  )
  let bullets = w.at("responsibilities", default: ()) + w.at("achievements", default: ())
  if bullets.len() > 0 {
    block(above: 8pt, below: 0pt, entry-list(bullets))
  }
  if w.at("keywords", default: ()).len() > 0 {
    // Tech-Stack ohne Label — der Inhalt erklärt sich selbst.
    block(above: 8pt, below: 0pt, meta-line(w.keywords))
  }
})

#let edu-entry(e) = rail-entry({
  let meta = ()
  if e.at("location", default: none) != none { meta.push(e.location) }
  if e.at("score", default: none) != none { meta.push(t.grade + ": " + e.score) }
  entry-header(
    e.studyType + " · " + e.area,
    e.institution,
    fmt-range(e.startDate, e.at("endDate", default: none)),
    meta.join("  ·  "),
  )
  let courses = e.at("courses", default: ())
  if courses.len() > 0 {
    block(above: 7pt, below: 0pt, labeled-meta(t.focus, courses))
  }
})

// ===========================================================================
// Dokument-Setup
// ===========================================================================
#set document(
  author: b.name,
  // Aussagekräftiger Dokumenttitel für ATS-/Mail-/Tab-Anzeige
  // (statt nur des Jobtitels).
  title: b.name + " – " + t.doc,
  description: b.summary,
  keywords: data.skills.map(s => s.keywords).flatten(),
)
// hyphenate: false ist eine Invarianten-Absicherung für die Maschinen-
// lesbarkeit: Bei justify: false ist automatische Silbentrennung ohnehin aus,
// aber falls jemand später Blocksatz aktiviert, würde Typst sonst still Soft
// Hyphens einfügen — das echte ATS-Problem. Zeilenumbrüche an vorhandenen
// Kompositum-Bindestrichen ("Headless-CMS-System") verhindert das Flag NICHT
// (dort wird kein Zeichen eingefügt; das ist normales, verlustfreies Umbrechen).
#set text(font: sans, size: 10pt, lang: lang, ligatures: false, hyphenate: false, fill: ink)
#set par(justify: false, leading: 0.62em)
#set page(
  paper: "a4",
  fill: paper,
  margin: (top: 1.2cm, bottom: 1.7cm, left: 1.35cm, right: 1.35cm),
  footer: context {
    set text(font: mono, size: 6.8pt, fill: muted)
    grid(
      columns: (1fr, auto),
      align: (left, right),
      {
        dot(r: 1.7pt, baseline: -1.2pt)
        h(5pt)
        text(tracking: 1pt, upper(b.name))
        text(fill: clay, "  ·  ")
        // Nur der erste Label-Abschnitt — das volle Label (mit Tech-Keywords)
        // wäre für den Footer zu lang.
        text(tracking: 1pt, upper(b.label.split("·").at(0).trim()))
      },
      counter(page).display("1 / 1", both: true),
    )
  },
)

// Section-Überschrift: Punkt + Mono-Uppercase-Label + Hairline nach rechts.
#show heading.where(level: 2): it => block(above: 26pt, below: 13pt, {
  grid(
    columns: (auto, auto, 1fr),
    column-gutter: 9pt,
    align: (left + horizon, left + horizon, left + horizon),
    circle(radius: 2.2pt, fill: terra),
    mono-label(it.body),
    line(length: 100%, stroke: 0.6pt + rail),
  )
})

// ---- Kopf -----------------------------------------------------------------
// Kein Banner mehr: Name gross auf Papier, Mono-Label und Mono-Kontaktzeile
// darunter — die Kopfzeile der Landing Page als Briefkopf.
#block(below: 0pt, {
  grid(
    columns: if show-photo { (1fr, auto) } else { (1fr,) },
    column-gutter: 28pt,
    align: horizon,
    {
      text(font: display, size: 27pt, weight: 700, tracking: -0.3pt, b.name)
      v(7pt)
      // 8pt/1pt Tracking: das lange Label (inkl. Tech-Keywords) bleibt auch
      // neben dem Foto einzeilig; 1pt ist zudem extraktionssicher.
      mono-label(b.label, size: 8pt, fill: terra, tracking: 1pt)
      v(9pt)
      meta-text(contact-items.join(sep + " "))
    },
    ..if show-photo {(
      block(
        clip: true,
        radius: 100%,
        width: photo-size,
        height: photo-size,
        stroke: 1.2pt + clay,
        image("/assets/photo.jpg", width: photo-size, height: photo-size, fit: "cover"),
      ),
    )} else { () },
  )
})

// ===========================================================================
// Profil
// ===========================================================================
#heading(level: 2, t.profile)
#block(above: 0pt, text(size: 9.8pt, b.summary))

// ===========================================================================
// Berufserfahrung
// ===========================================================================
#if data.at("work", default: ()).len() > 0 {
  heading(level: 2, t.experience)
  for w in data.work { work-entry(w) }
}

// ===========================================================================
// Ausbildung
// ===========================================================================
#if data.at("education", default: ()).len() > 0 {
  heading(level: 2, t.education)
  for e in data.education { edu-entry(e) }
}

// ===========================================================================
// Kompetenzen
// ===========================================================================
// Kompakt mit Kategorien: Gruppenname als Mono-Uppercase-Label (Terrakotta),
// darunter die Keywords als stille Mono-Zeile — gleiche Optik wie die
// Stack-Zeilen der Projekte. Tracking 1pt = sicherer Wert für die Extraktion.
// Die ganze Sektion bricht geschlossen um: passt sie nicht mehr auf die
// Seite, wandert sie komplett auf die nächste — so endet keine Seite mitten
// in den Kompetenz-Gruppen und eine Folgeseite wirkt nicht verwaist.
#if data.at("skills", default: ()).len() > 0 {
  block(breakable: false, {
    heading(level: 2, t.skills)
    for (i, s) in data.skills.enumerate() {
      block(above: if i == 0 { 0pt } else { 10pt }, below: 0pt, breakable: false, {
        mono-label(s.name, size: 6.8pt, fill: terra, tracking: 1pt)
        block(above: 4.5pt, below: 0pt, meta-line(s.keywords))
      })
    }
  })
}

// ===========================================================================
// Sprachen
// ===========================================================================
#if data.at("languages", default: ()).len() > 0 {
  heading(level: 2, t.languages)
  block(above: 0pt, {
    for (i, l) in data.languages.enumerate() {
      if i > 0 { h(9pt); text(fill: clay)[·]; h(9pt) }
      text(weight: 600, l.language)
      meta-text(" — " + l.fluency, size: 8pt)
    }
  })
}

// ---- Rohdaten als maschinenlesbaren Anhang einbetten ----------------------
// (ATS/Weiterverarbeitung: JSON-Resume-Daten direkt im PDF.)
#pdf.attach(
  "/resume." + lang + ".json",
  read("/generated/resume." + lang + ".json", encoding: none),
  relationship: "supplement",
  mime-type: "application/json",
  description: "Machine-readable résumé data (JSON Resume schema)",
)
