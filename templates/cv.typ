// ---------------------------------------------------------------------------
// cv.typ — zweisprachiges, ATS-optimiertes Lebenslauf-Template
//
// Aufruf (siehe src/build.ts):
//   typst compile --root . --font-path fonts \
//     --input lang=de --input photo=true templates/cv.typ dist/CV-...-DE.pdf
//
// Inputs:
//   lang  = "de" | "en"   (Sprache + passende generated/resume.<lang>.json)
//   photo = "true" | "false"   (Profilfoto im Kopf ein-/ausblenden)
//
// ATS-Prinzipien: Single-Column-Flow, echte Textebene (kein Text in Grafiken),
// keine Tabellen/Textboxen für Struktur, Standard-Section-Überschriften,
// lineare Lesereihenfolge. Das Foto ist ein reines, aus dem Textfluss
// herausgelöstes Bild-Element (place) ohne inhaltstragenden Text.
// ---------------------------------------------------------------------------

#let lang = sys.inputs.at("lang", default: "de")
#let show-photo = sys.inputs.at("photo", default: "true") == "true"
#let data = json("/generated/resume." + lang + ".json")
#let b = data.basics

// ---- i18n: Section-Labels & Begriffe --------------------------------------
#let i18n = (
  de: (
    profile: "Profil", experience: "Berufserfahrung", skills: "Kompetenzen",
    education: "Ausbildung", languages: "Sprachen", present: "heute",
    stack: "Tech-Stack", grade: "Note", responsibilities: "Aufgaben",
    achievements: "Erfolge", focus: "Schwerpunkte",
  ),
  en: (
    profile: "Profile", experience: "Experience", skills: "Skills",
    education: "Education", languages: "Languages", present: "Present",
    stack: "Tech Stack", grade: "Grade", responsibilities: "Responsibilities",
    achievements: "Achievements", focus: "Focus",
  ),
)
#let t = i18n.at(lang, default: i18n.de)

// ---- Farben & Maße --------------------------------------------------------
#let ink = rgb("#1f2328")
#let accent = rgb("#274060")
#let muted = rgb("#5a626b")
#let rule-color = rgb("#d4d8dd")
#let photo-h = 3.2cm

// ---- Typografie: feste Skala (NUR diese Größen & Gewichte verwenden) -------
// Vier Größen, drei Gewichte – bewusst knapp gehalten, damit das Dokument ruhig
// wirkt und nicht "mischt".
#let size-name = 20pt // Name
#let size-head = 11pt // Section-Überschriften + Jobtitel
#let size-body = 10pt // Fließtext, Bullets, Eintrags-Titel
#let size-small = 9pt // alle Sekundärangaben (Daten, Ort, Sub-Labels, Stack, Kontakt, Fußzeile)
#let w-bold = 700 // Name, Überschriften, Eintrags-Titel
#let w-semi = 600 // Sub-Labels, Präfixe, Sprachnamen
#let w-reg = 400 // Fließtext & Sekundärangaben
// Einheitlicher Stil für Sekundärtext (grau, klein):
#let small(body) = text(size: size-small, fill: muted, weight: w-reg, body)

// ---- Datumsformatierung ---------------------------------------------------
#let months-en = ("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")
#let fmt-month(s) = {
  let p = s.split("-")
  let y = p.at(0)
  let m = int(p.at(1))
  if lang == "de" {
    (if m < 10 { "0" } else { "" }) + str(m) + "/" + y // 07/2026
  } else {
    months-en.at(m - 1) + " " + y // Jul 2026
  }
}
#let fmt-range(start, end) = {
  fmt-month(start) + " – " + (if end == none { t.present } else { fmt-month(end) })
}

// ---- kleine Helfer --------------------------------------------------------
#let sep = text(fill: muted)[ · ]
#let strip-scheme(u) = u.replace("https://", "").replace("http://", "")

// ---- Dokument-Metadaten ---------------------------------------------------
#set document(
  title: b.name + " — " + b.label,
  author: b.name,
  description: b.summary,
  keywords: data.skills.map(s => s.keywords).flatten(),
)

// ---- Seiten- & Textlayout -------------------------------------------------
#set page(
  paper: "a4",
  margin: (x: 1.7cm, top: 1.4cm, bottom: 1.5cm),
  // Dezente Seitenzahl nur bei mehrseitigen Lebensläufen.
  footer: context {
    let total = counter(page).final().first()
    if total > 1 {
      set text(size: size-small, fill: muted)
      align(center)[#counter(page).display() / #total]
    }
  },
)
#set text(font: "Inter", lang: lang, size: size-body, fill: ink, hyphenate: false)
#set par(justify: false, leading: 0.6em, spacing: 0.78em)
#show link: set text(fill: accent)

// Standardisierte Abschnittsüberschriften (echte headings -> PDF-Outline).
// Viel Abstand nach OBEN (klare Trennung vom vorigen Abschnitt), wenig nach
// UNTEN (Überschrift bleibt eng bei ihrem Inhalt).
#show heading.where(level: 1): it => block(above: 14pt, below: 4pt, breakable: false)[
  #text(size: size-head, weight: w-bold, fill: accent, tracking: 0.8pt)[#upper(it.body)]
  #v(3pt)
  #line(length: 100%, stroke: 0.6pt + rule-color)
]

// ---- Rohdaten als maschinenlesbaren Anhang einbetten ----------------------
// (Typst 0.13: pdf.embed; ab 0.14 umbenannt in pdf.attach — hier 0.15+.)
// Bytes explizit lesen, damit der Anhang einen sauberen Basename bekommt
// (statt "generated/resume.de.json" mit Pfad-Slash).
#pdf.attach(
  "/resume." + lang + ".json",
  read("/generated/resume." + lang + ".json", encoding: none),
  relationship: "supplement",
  mime-type: "application/json",
  description: "Machine-readable résumé data (JSON Resume schema)",
)

// ===========================================================================
// Kopfbereich: Name/Kontakt links, Foto (optional) rechts
// ===========================================================================
#block(width: 100%, breakable: false, {
  if show-photo {
    place(
      top + right,
      box(clip: true, radius: 5pt, image("/assets/photo.jpg", height: photo-h)),
    )
  }
  block(inset: (right: if show-photo { photo-h + 0.5cm } else { 0cm }), {
    text(size: size-name, weight: w-bold, fill: ink, b.name)
    v(3pt)
    text(size: size-head, weight: w-reg, fill: accent, b.label)
    v(6pt)
    // Kontaktzeilen als reiner, extrahierbarer Text
    set text(size: size-small, fill: muted)
    // Zeile 1: E-Mail · Telefon · Adresse (alles als reiner Text)
    {
      link("mailto:" + b.email)[#b.email]
      if b.at("phone", default: none) != none { sep; b.phone }
      let loc = b.location
      let addr = ()
      if loc.at("address", default: none) != none { addr.push(loc.address) }
      let cityparts = ()
      if loc.at("postalCode", default: none) != none { cityparts.push(loc.postalCode) }
      cityparts.push(loc.city)
      addr.push(cityparts.join(" "))
      sep
      addr.join(", ")
    }
    // Zeile 2 (nur falls vorhanden): Website · Profile (URLs ohne Schema)
    {
      let links = ()
      if b.at("url", default: none) != none { links.push(link(b.url)[#strip-scheme(b.url)]) }
      for p in b.profiles { links.push(link(p.url)[#strip-scheme(p.url)]) }
      if links.len() > 0 {
        linebreak()
        for (i, l) in links.enumerate() {
          if i > 0 { sep }
          l
        }
      }
    }
  })
})

#v(2pt)

// ===========================================================================
// Profil
// ===========================================================================
#if b.at("summary", default: "") != "" {
  heading(t.profile)
  b.summary
}

// ===========================================================================
// Berufserfahrung (Freelance-Projekte, chronologisch absteigend)
// ===========================================================================
#let bullets(items) = list(
  marker: text(fill: accent)[•],
  spacing: 2.5pt,
  ..items.map(it => [#it]),
)
#let sub-label(txt) = block(above: 3pt, below: 1pt)[
  #text(size: size-small, weight: w-semi, fill: muted)[#txt]
]

// breakable: false -> ein Projekt wird nie über einen Seitenumbruch getrennt;
// passt es unten nicht mehr hin, wandert es komplett auf die nächste Seite.
#let work-entry(w) = block(breakable: false, below: 6.5pt, {
  // Kopfzeile: Rolle · Kunde .................... Zeitraum  (eine Textzeile)
  text(weight: w-bold, w.position)
  sep
  w.name
  h(1fr)
  small(fmt-range(w.startDate, w.at("endDate", default: none)))
  // Ort
  let loc = w.at("location", default: none)
  if loc != none {
    linebreak()
    small(loc)
  }
  // Aufgaben
  let resp = w.at("responsibilities", default: ())
  if resp.len() > 0 {
    sub-label(t.responsibilities)
    bullets(resp)
  }
  // Erfolge
  let ach = w.at("achievements", default: ())
  if ach.len() > 0 {
    sub-label(t.achievements)
    bullets(ach)
  }
  // Tech-Stack (wichtige Keywords für ATS)
  if w.at("keywords", default: ()).len() > 0 {
    v(3pt)
    block({
      set text(size: size-small, fill: muted, weight: w-reg)
      text(weight: w-semi, t.stack + ": ")
      w.keywords.join(" · ")
    })
  }
})

#if data.at("work", default: ()).len() > 0 {
  heading(t.experience)
  for w in data.work { work-entry(w) }
}

// ===========================================================================
// Kompetenzen
// ===========================================================================
#if data.at("skills", default: ()).len() > 0 {
  heading(t.skills)
  for s in data.skills {
    block(below: 4pt, {
      text(weight: w-bold, s.name)
      let lvl = s.at("level", default: none)
      if lvl != none { text(fill: muted, size: size-small)[ (#lvl)] }
      text(fill: muted)[ — ]
      s.keywords.join(" · ")
    })
  }
}

// ===========================================================================
// Ausbildung
// ===========================================================================
#if data.at("education", default: ()).len() > 0 {
  heading(t.education)
  for e in data.education {
    block(breakable: false, below: 6pt, {
      text(weight: w-bold, e.studyType)
      sep
      e.area
      h(1fr)
      small(fmt-range(e.startDate, e.at("endDate", default: none)))
      linebreak()
      let parts = (e.institution,)
      if e.at("location", default: none) != none { parts.push(e.location) }
      if e.at("score", default: none) != none { parts.push(t.grade + ": " + e.score) }
      small(parts.join(" · "))
      let courses = e.at("courses", default: ())
      if courses.len() > 0 {
        linebreak()
        text(size: size-small, fill: muted)[#text(weight: w-semi)[#(t.focus + ": ")]#courses.join(" · ")]
      }
    })
  }
}

// ===========================================================================
// Sprachen
// ===========================================================================
#if data.at("languages", default: ()).len() > 0 {
  heading(t.languages)
  block({
    for (i, l) in data.languages.enumerate() {
      if i > 0 { sep }
      text(weight: w-semi, l.language)
      text(fill: muted)[ — #l.fluency]
    }
  })
}
