// ---------------------------------------------------------------------------
// cv.typ — zweisprachiger, ATS-orientierter Lebenslauf
//
// Design-Sprache: übernommen von der eigenen Landing Page (nils.fyi) —
// "warm editorial" statt Corporate-Navy:
//   - Farbwelt:   weißes Papier (Druck, Dark-Mode-Viewer), warme Tinte (#241e1a),
//                 Terrakotta-Akzent (#a33e25), Ton/Clay-Konturen (#c69889)
//   - Schriften:  Instrument Sans für allen Text; Geist Mono NUR für Daten in
//                 festen Positionen (Zeitraum, Tech-Zeilen, Sektionslabels,
//                 Footer) und nie innerhalb einer Textzeile gemischt; Space
//                 Grotesk nur für den Namen (Marke) — alle SIL OFL, unter fonts/
//   - Typo-Skala: 5 Größen (26 / 11.5 / 10 / 8.5 / 7.5pt), ein Akzent,
//                 Versalien nur für kurze Labels — siehe "Typografie" unten
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
    grade: "Note", focus: "Fokus", doc: "Profil",
  ),
  en: (
    profile: "Profile", experience: "Project Experience", skills: "Skills",
    education: "Education", languages: "Languages",
    grade: "Grade", focus: "Focus", doc: "Profile",
  ),
)
#let t = i18n.at(lang, default: i18n.de)

// ---- Farben (Design-Tokens von nils.fyi) ----------------------------------
// Seitenhintergrund bewusst weiß statt des Landing-Page-Papiertons (#f6f3ed):
// druckt ohne Farbrand und invertiert sauber in Dark-Mode-Viewern.
#let paper = white
#let card = rgb("#fbfaf7") // --card
#let ink = rgb("#241e1a") // --foreground
#let muted = rgb("#5f5650") // --muted-foreground
#let rail = rgb("#cdc5ba") // --border, eine Nuance kräftiger für den Druck
#let clay = rgb("#c69889") // --ton (Konturlinien) — nur Trenner & Marker
// Einziger Akzent (Kontrast 6.4:1 auf Weiß). Rollen: Titelzeile im Kopf,
// Firmennamen, Links, Punkte/Knoten — sonst trägt Gewicht die Hierarchie.
#let terra = rgb("#a33e25") // --primary

// ---- Schriften ------------------------------------------------------------
#let sans = "Instrument Sans"
#let display = "Space Grotesk"
#let mono = "Geist Mono"

// ---- Typografie -----------------------------------------------------------
// Fünf klar getrennte Größen statt acht dicht beieinander liegender.
#let size-name = 26pt
#let size-title = 11.5pt // Eintragstitel; 11.5pt ist das Maximum, bei dem der
// längste Titel bei 1.8cm Rand einzeilig bleibt (gemessen: 371 von 378pt).
#let size-body = 10pt // Fließtext, Firmenzeile, Kompetenzen, Kontakt
#let size-meta = 8.5pt // Mono: Zeitraum, Tech-Zeilen, Sektionslabels
#let size-fine = 7.5pt // Footer
// Ein Zeilenabstand für allen Fließtext (~1.3 Zeilenhöhe) und ein Tracking
// für alle Versalien-Labels.
#let lead-body = 0.6em
#let lead-meta = 0.6em
#let track-caps = 0.08em

// ---- Layout-Konstanten ----------------------------------------------------
#let photo-size = 80pt
#let rail-indent = 16pt // Einzug der Einträge rechts der Timeline-Schiene
#let section-above = 22pt // Abstand über jeder Sektionsüberschrift

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
// Laufende Projekte (ohne endDate) enden mit "heute"/"present": Der Build-
// Monat an dieser Stelle las sich wie ein Projektende. Parser erkennen
// "heute"/"present" als laufend.
#let fmt-range(start, end) = {
  fmt-month(start) + " – " + (
    if end == none { if lang == "de" { "heute" } else { "present" } } else { fmt-month(end) }
  )
}

// ---- kleine Helfer --------------------------------------------------------
// Der Punkt: das Logo-Mark der Landing Page (kleiner Terrakotta-Kreis).
#let dot(r: 2.2pt, fill: terra, baseline: -1pt) = box(
  baseline: baseline,
  circle(radius: r, fill: fill),
)
// Trenner mit genau EINEM Leerzeichen je Seite: Doppelte Leerzeichen erzeugt
// eine Lücke, die pdftotext & Co. als Spaltengrenze deuten (die Telefonnummer
// landete dadurch als eigener Block hinter den Links). In der Proportional-
// schrift wirkt ein normales Leerzeichen um den Punkt gequetscht, daher dort
// breitere Wortabstände (echte Leerzeichen bleiben erhalten); Mono hat von
// Haus aus breite Leerzeichen.
#let sep-style(body, mono: false) = text(fill: clay, spacing: if mono { 100% } else { 170% }, body)
#let sep = sep-style[ · ]
#let sep-mono = sep-style(mono: true)[ · ]
// Datenfelder mit " · " (Label, Eckdaten) mit denselben Trennern setzen.
#let with-seps(s) = s.split(" · ").join(sep)

// Mono-Metadaten (Zeitraum, Tech-Zeilen) — die "Maschinen-Schicht" des
// Designs, immer in eigener Zeile/Spalte, nie mitten in einer Sans-Zeile.
// 8.5pt ist die Untergrenze für Lesbarkeit auf dem Handy und im Druck.
#let meta-text(body, size: size-meta, fill: muted) = text(
  font: mono, size: size, weight: 400, fill: fill, body,
)

// Mono-Versalien-Label (Sektionsüberschriften). Tracking bewusst klein:
// ab ~0.18em zerfallen Wörter bei der Textextraktion in Einzelbuchstaben
// ("P R O F I L") — schlecht für die ATS-Sektionserkennung.
#let mono-label(body, size: size-meta, fill: ink) = text(
  font: mono, size: size, weight: 500, tracking: track-caps, fill: fill, upper(body),
)

// Bulletliste im Eintrag — Ton-Marker, ruhige, gleichmäßige Zeilen.
// Wichtig für die Gruppierung: Der Abstand ZWISCHEN zwei Bullets (7pt) muss
// größer sein als der Zeilenabstand INNERHALB eines Bullets (6pt), sonst
// kleben umbrechende Bullets optisch am Nachbarn.
#let entry-list(items) = {
  set par(leading: lead-body)
  list(
    marker: text(fill: clay, size: 9pt)[•],
    spacing: 7pt,
    body-indent: 7pt,
    ..items.map(it => [#it]),
  )
}

// Keyword-Folge: jedes Keyword ist unteilbar ("TanStack Query" bricht nie in
// der Mitte) und hält seinen nachfolgenden Trenner fest, damit keine Zeile
// mit "·" beginnt — umbrochen wird nur NACH einem Trenner. Schriftneutral;
// rein inline (kein `set par` hier, das würde einen eigenen Absatz erzwingen).
#let keyword-list(items, mono: false) = {
  let head = sep-style(mono: mono)[ ·]
  let tail = sep-style(mono: mono)[ ]
  items.enumerate().map(((i, it)) => {
    if i + 1 < items.len() { box[#it#head] + tail } else { box(it) }
  }).join()
}
#let meta-line(items) = meta-text(keyword-list(items, mono: true))

// Keyword-Zeile mit Label im selben Absatz, z. B.
// "Fokus: Webentwicklung · Machine Learning". Bewusst ohne Label-Spalte,
// ohne Versalien-Tracking und ohne Extra-Abstand: Spalten und Lücken deutet
// pdftotext als Spalten- bzw. Buchstabengrenzen ("F O K U S", Label landet
// hinter der Sektion).
#let labeled-keywords(label, items, fill: ink) = text(fill: fill, {
  set par(leading: lead-body)
  text(weight: 600, label + ":")
  [ ]
  keyword-list(items)
})

// ---- Ort (Kontaktzeile) ---------------------------------------------------
// Bewusst kompakt: Stadt + Land (keine Straße — weder hier noch im JSON-Anhang).
#let country-names = ("DE": (de: "Deutschland", en: "Germany"))
#let location-str = {
  let code = b.location.countryCode
  let name = country-names.at(code, default: (:)).at(lang, default: code)
  b.location.city + ", " + name
}

// URLs ohne Protokoll/www anzeigen ("nilsschlueter.de") — als Terrakotta-Akzent.
#let display-url(u) = u.replace("https://", "").replace("http://", "").replace("www.", "").trim("/")

// Feste Zeilen statt freiem Umbruch, damit die Lesereihenfolge stabil bleibt:
//   1. Ort · E-Mail · Telefon   (Kontaktdaten in EINER Textfolge)
//   2. Website · Profile        (Links)
#let contact-lines = {
  let direct = (location-str, b.email)
  let phone = b.at("phone", default: none)
  if phone != none and phone != "" { direct.push(phone) }
  let links = ()
  let site = b.at("url", default: none)
  if site != none {
    links.push(link(site, text(fill: terra, display-url(site))))
  }
  for p in b.at("profiles", default: ()) {
    links.push(link(p.url, text(fill: terra, display-url(p.url))))
  }
  (direct.join(sep), links.join(sep))
}

// ---- Eintrags-Kopf --------------------------------------------------------
// Typo-Hierarchie über Größe/Gewicht/Farbe derselben Schrift:
// Titel (11.5pt, 600) > Firma (10pt, 600, Akzent) > Ort/Note (10pt, gedämpft).
// Zeile 1: Titel | Zeitraum (Mono, eigene Spalte). Zeile 2: Firma · Ort über
// die volle Breite — so bleibt die Datumsspalte schmal und der Titel einzeilig.
#let entry-header(title, org, dates, details) = block(below: 0pt, breakable: false, {
  set par(leading: lead-body)
  grid(
    columns: (1fr, auto),
    column-gutter: 12pt,
    row-gutter: 6pt,
    align: (left + horizon, right + horizon),
    text(size: size-title, weight: 600, title),
    meta-text(dates),
    grid.cell(colspan: 2, {
      text(weight: 600, fill: terra, org)
      for d in details { text(fill: muted, sep + d) }
    }),
  )
})

// ---- Timeline-Eintrag -----------------------------------------------------
// Jeder Eintrag hängt an einer durchgehenden Schiene (linker Hairline-Strich)
// mit Terrakotta-Knoten auf Titelhöhe — das Prozess-/Timeline-Motiv der
// Landing Page. Umbrüche nur geschützt (siehe work-entry): nie ein Kopf allein
// am Seitenende, nie eine Tech-Zeile allein am Seitenanfang. Ganz unteilbare
// Einträge hinterließen bis zu 160pt Lücke je Seite (und eine 5. Seite).
#let rail-entry(body, breakable: false) = block(
  breakable: breakable,
  above: 0pt,
  below: 0pt,
  inset: (left: rail-indent, top: 13pt),
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

// Bullets + Tech-Zeile — gemeinsam für Einträge und Teilprojekte.
#let bullets-of(x) = x.at("responsibilities", default: ()) + x.at("achievements", default: ())

// Tech-Stack ohne Label — der Inhalt erklärt sich selbst.
#let tag-line(keywords) = if keywords.len() > 0 {
  block(above: 8pt, below: 0pt, { set par(leading: lead-meta); meta-line(keywords) })
}

#let entry-body(x, keywords) = {
  let bullets = bullets-of(x)
  if bullets.len() > 0 {
    block(above: 8pt, below: 0pt, entry-list(bullets))
  }
  tag-line(keywords)
}

#let subproject-block(s) = block(above: 12pt, below: 0pt, breakable: false, {
  text(weight: 600, s.title)
  entry-body(s, s.keywords)
})

#let work-entry(w) = {
  let subprojects = w.at("subprojects", default: ())
  let header = {
    entry-header(
      w.position,
      w.name,
      fmt-range(w.startDate, w.at("endDate", default: none)),
      ("location", "workload").map(k => w.at(k, default: none)).filter(v => v != none),
    )
  }
  let bullets = bullets-of(w)
  let keywords = w.at("keywords", default: ())
  if subprojects.len() == 0 and bullets.len() <= 2 {
    rail-entry({
      header
      entry-body(w, keywords)
    })
  } else if subprojects.len() == 0 {
    // Geschützter Umbruch zwischen Bullets: Kopf + erste zwei Bullets und
    // letzter Bullet + Tech-Zeile sind jeweils unteilbar, Bullets selbst auch.
    // Abstände = die der ungeteilten Liste (8pt nach Kopf, 7pt zwischen Bullets).
    let item(b) = block(above: 7pt, below: 0pt, breakable: false, entry-list((b,)))
    rail-entry(breakable: true, {
      block(breakable: false, below: 0pt, {
        header
        block(above: 8pt, below: 0pt, entry-list(bullets.slice(0, 2)))
      })
      for b in bullets.slice(2, -1) { item(b) }
      block(above: 7pt, below: 0pt, breakable: false, {
        entry-list((bullets.last(),))
        tag-line(keywords)
      })
    })
  } else {
    // Kopf + erstes Teilprojekt unteilbar, damit der Kopf nie allein am
    // Seitenende steht; danach darf zwischen Teilprojekten umbrochen werden.
    rail-entry(breakable: true, {
      block(breakable: false, below: 0pt, {
        header
        entry-body(w, ())
        subproject-block(subprojects.first())
      })
      for s in subprojects.slice(1) { subproject-block(s) }
    })
  }
}

#let edu-entry(e) = rail-entry({
  let meta = ()
  if e.at("location", default: none) != none { meta.push(e.location) }
  if e.at("score", default: none) != none { meta.push(t.grade + ": " + e.score) }
  entry-header(
    [#e.studyType#sep#e.area],
    e.institution,
    fmt-range(e.startDate, e.at("endDate", default: none)),
    meta,
  )
  let courses = e.at("courses", default: ())
  if courses.len() > 0 {
    block(above: 6pt, below: 0pt, labeled-keywords(t.focus, courses, fill: muted))
  }
})

// ===========================================================================
// Dokument-Setup
// ===========================================================================
// Rolle = erster Label-Abschnitt ohne Klammerzusatz ("Senior Fullstack-Entwickler").
#let role = b.label.split("·").at(0).replace(regex("\s*\(.*?\)"), "").trim()
#set document(
  author: b.name,
  // Aussagekräftiger Dokumenttitel für ATS-/Mail-/Tab-Anzeige, mit Stand
  // (Build-Monat): "Nils Schlüter – Senior Fullstack-Entwickler – Profil 2026-10".
  title: b.name + " – " + role + " – " + t.doc + " " + datetime.today().display("[year]-[month]"),
  description: b.summary,
  keywords: data.skills.map(s => s.keywords).flatten(),
)
// hyphenate: false ist eine Invarianten-Absicherung für die Maschinen-
// lesbarkeit: Bei justify: false ist automatische Silbentrennung ohnehin aus,
// aber falls jemand später Blocksatz aktiviert, würde Typst sonst still Soft
// Hyphens einfügen — das echte ATS-Problem.
#set text(font: sans, size: size-body, lang: lang, ligatures: false, hyphenate: false, fill: ink)
#set par(justify: false, leading: lead-body)

// Komposita mit Bindestrich ("Bank-Transaktionsdaten", "UI-Komponenten")
// nie am Bindestrich umbrechen: Extraktoren (pdftotext, viele ATS-Parser)
// entfernen einen Bindestrich am Zeilenende und kleben die Teile zusammen
// ("BankTransaktionsdaten"). Die Box hält das Wort zusammen, der Text bleibt
// unverändert — anders als U+2011 (geschützter Bindestrich), das die Suche
// nach "Multi-Sender" bricht und in den eingebetteten Fonts fehlt.
#show regex("[\p{L}\p{N}]+(?:-[\p{L}\p{N}]+)+"): box
// Gedankenstrich nie am Zeilenanfang: hängt am vorherigen Wort (normales
// Leerzeichen bleibt erhalten, anders als ein geschütztes Leerzeichen).
#show regex("\S+ —"): box
// Instrument Sans hat kein "₂" (sonst Fallback auf eine Serifen-Schrift).
// Als Tiefstellung gesetzt landet zudem ein suchbares "CO2" in der Textebene.
#show "CO₂": [CO#sub[2]]
#set page(
  paper: "a4",
  fill: paper,
  // 1.8cm seitlich: begrenzt die Zeilen auf ~90 Zeichen (vorher ~100) und ist
  // das Maximum, bei dem alle Eintragstitel einzeilig bleiben.
  margin: (top: 1.6cm, bottom: 1.8cm, left: 1.8cm, right: 1.8cm),
  footer: context {
    set text(font: mono, size: size-fine, fill: muted, tracking: track-caps)
    grid(
      columns: (1fr, auto),
      align: (left, right),
      {
        dot(r: 1.7pt, baseline: -1.2pt)
        h(5pt)
        upper(b.name)
        sep-mono
        // Nur der erste Label-Abschnitt — das volle Label (mit Tech-Keywords)
        // wäre für den Footer zu lang.
        upper(b.label.split("·").at(0).trim())
      },
      counter(page).display("1 / 1", both: true),
    )
  },
)

// Section-Überschrift: Punkt + Mono-Uppercase-Label + Hairline nach rechts.
#show heading.where(level: 2): it => block(above: section-above, below: 12pt, {
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
// Name in Space Grotesk (einziger Einsatz, Marke der Landing Page), alles
// darunter in Instrument Sans: Titelzeile (Akzent), Kontakt (gedämpft),
// Links (Akzent), Eckdaten (Tinte).
#block(below: 0pt, {
  grid(
    columns: if show-photo { (1fr, auto) } else { (1fr,) },
    column-gutter: 24pt,
    align: horizon,
    {
      // Absatzabstand aus, damit nur die v()-Werte zählen — sonst addiert
      // Typst je Absatzgrenze 1.2em und der Untertitel rückt ~30pt vom Namen
      // ab. Gemessen wird jeweils von Grundlinie zu Versalhöhe.
      set par(spacing: 0pt)
      text(font: display, size: size-name, weight: 700, tracking: -0.01em, b.name)
      // Name + Titelzeile bilden eine Einheit, Kontakt/Eckdaten eine zweite.
      v(9pt)
      // Gemischte Schreibung statt 80 Zeichen Versalien (lesbarer, und passt
      // auch neben dem Foto einzeilig).
      text(fill: terra, with-seps(b.label))
      v(15pt)
      // Kontakt, Links und Eckdaten (Verfügbarkeit · Auslastung · Einsatzort)
      // als ein Block in einem Stil: Eine abgesetzte dritte Zeile in Tinte
      // wirkte wie ein Fremdkörper zwischen Kopf und Profil.
      let (direct, links) = contact-lines
      let avail = b.at("availability", default: none)
      text(fill: muted, {
        direct; linebreak(); links
        if avail != none { linebreak(); with-seps(avail) }
      })
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
#block(above: 0pt, b.summary)

// ===========================================================================
// Kompetenzen — direkt nach dem Profil: Vermittler lesen zuerst die Top-Skills.
// ===========================================================================
// Kompakt mit Kategorien: Gruppenname fett, direkt gefolgt von den Keywords
// in derselben Textzeile, in der Textschrift — hier liest der Mensch, anders
// als bei den Tech-Zeilen der Projekte (Extraktions-Hinweise siehe
// labeled-keywords).
#if data.at("skills", default: ()).len() > 0 {
  // Der Wrapper trägt den Sektionsabstand: Am Anfang eines Blocks verfällt
  // das `above` der Überschrift, die Sektion klebte sonst am Profil.
  block(breakable: false, above: section-above, {
    heading(level: 2, t.skills)
    for (i, s) in data.skills.enumerate() {
      // 10pt zwischen den Gruppen, deutlich mehr als der Zeilenabstand (6pt)
      // innerhalb einer Gruppe — sonst verschwimmen mehrzeilige Gruppen.
      block(above: if i == 0 { 0pt } else { 10pt }, below: 0pt, labeled-keywords(s.name, s.keywords))
    }
  })
}

// ===========================================================================
// Projekthistorie (JSON Resume: work)
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
// Sprachen
// ===========================================================================
#if data.at("languages", default: ()).len() > 0 {
  heading(level: 2, t.languages)
  block(above: 0pt, {
    for (i, l) in data.languages.enumerate() {
      if i > 0 { sep }
      text(weight: 600, l.language)
      text(fill: muted, " — " + l.fluency)
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
