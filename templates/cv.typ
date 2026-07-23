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
    stack: "Tech-Stack", grade: "Note",
  ),
  en: (
    profile: "Profile", experience: "Experience", skills: "Skills",
    education: "Education", languages: "Languages", present: "Present",
    stack: "Tech Stack", grade: "Grade",
  ),
)
#let t = i18n.at(lang, default: i18n.de)

// ---- Farben & Maße --------------------------------------------------------
#let ink = rgb("#1f2328")
#let accent = rgb("#274060")
#let muted = rgb("#5a626b")
#let rule-color = rgb("#d4d8dd")
#let photo-h = 3.2cm

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
#set page(paper: "a4", margin: (x: 1.7cm, top: 1.4cm, bottom: 1.3cm))
#set text(font: "Inter", lang: lang, size: 10pt, fill: ink, hyphenate: false)
#set par(justify: false, leading: 0.62em, spacing: 0.82em)
#show link: set text(fill: accent)

// Standardisierte Abschnittsüberschriften (echte headings -> PDF-Outline)
#show heading.where(level: 1): it => block(above: 11pt, below: 6pt, breakable: false)[
  #text(size: 10.5pt, weight: 700, fill: accent, tracking: 0.8pt)[#upper(it.body)]
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
    text(size: 22pt, weight: 700, fill: ink, b.name)
    v(3pt)
    text(size: 11pt, weight: 500, fill: accent, b.label)
    v(6pt)
    // Kontaktzeilen als reiner, extrahierbarer Text
    set text(size: 9pt, fill: muted)
    // Zeile 1: E-Mail · Telefon · Ort
    {
      link("mailto:" + b.email)[#b.email]
      if b.at("phone", default: none) != none { sep; b.phone }
      sep
      b.location.city + ", " + b.location.countryCode
    }
    linebreak()
    // Zeile 2: Website · Profile (URLs ohne Schema, gut lesbar & parsebar)
    {
      let links = ()
      if b.at("url", default: none) != none { links.push(link(b.url)[#strip-scheme(b.url)]) }
      for p in b.profiles { links.push(link(p.url)[#strip-scheme(p.url)]) }
      for (i, l) in links.enumerate() {
        if i > 0 { sep }
        l
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
#let work-entry(w) = block(breakable: false, below: 8pt, {
  // Kopfzeile: Rolle · Kunde .................... Zeitraum  (eine Textzeile)
  text(weight: 700, w.position)
  sep
  w.name
  h(1fr)
  text(size: 9pt, fill: muted, fmt-range(w.startDate, w.at("endDate", default: none)))
  // Ort
  let loc = w.at("location", default: none)
  if loc != none {
    linebreak()
    text(size: 9pt, fill: muted, loc)
  }
  parbreak()
  // Kurzbeschreibung
  w.summary
  // Ergebnisse / Verantwortlichkeiten
  if w.highlights.len() > 0 {
    list(marker: text(fill: accent)[•], spacing: 4pt, ..w.highlights.map(h => [#h]))
  }
  // Tech-Stack (wichtige Keywords für ATS)
  if w.at("keywords", default: ()).len() > 0 {
    v(2pt)
    block({
      set text(size: 9pt, fill: muted)
      text(weight: 600, t.stack + ": ")
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
    block(below: 5pt, {
      text(weight: 700, s.name)
      let lvl = s.at("level", default: none)
      if lvl != none { text(fill: muted, size: 9pt)[ (#lvl)] }
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
      text(weight: 700, e.studyType)
      sep
      e.area
      h(1fr)
      text(size: 9pt, fill: muted, fmt-range(e.startDate, e.at("endDate", default: none)))
      linebreak()
      let parts = (e.institution,)
      if e.at("location", default: none) != none { parts.push(e.location) }
      if e.at("score", default: none) != none { parts.push(t.grade + " " + e.score) }
      text(size: 9pt, fill: muted, parts.join(" · "))
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
      text(weight: 600, l.language)
      text(fill: muted)[ — #l.fluency]
    }
  })
}
