/**
 * Markdown-Export des Lebenslaufs — gleiche Quelle wie das PDF
 * (generated/resume.<lang>.json), aber ohne Layout. Gedacht für Vermittler,
 * die ein Word-Dokument wollen:
 *
 *   npm run docx    # pandoc dist/*.md -> dist/*.docx
 */
import type { Lang } from "./lib";

interface Entry {
  responsibilities?: string[];
  achievements?: string[];
  keywords?: string[];
}
interface Subproject extends Entry {
  title: string;
}
interface Work extends Entry {
  name: string;
  position: string;
  location?: string;
  workload?: string;
  startDate: string;
  endDate?: string;
  subprojects?: Subproject[];
}
interface Education {
  institution: string;
  area: string;
  studyType: string;
  startDate: string;
  endDate?: string;
  score?: string;
  courses?: string[];
}
/** Der Teil von generated/resume.<lang>.json, den der Export liest. */
export interface Resume {
  basics: {
    name: string;
    label: string;
    image?: string;
    email: string;
    phone?: string;
    url?: string;
    availability?: string;
    summary: string;
    location: { city: string; countryCode: string };
    profiles: { url: string }[];
  };
  work: Work[];
  skills: { name: string; keywords: string[] }[];
  education: Education[];
  languages: { language: string; fluency: string }[];
}

// Spiegelt die i18n-Labels und die Datumsformate von templates/cv.typ.
const LABELS = {
  de: {
    profile: "Profil", skills: "Kompetenzen", experience: "Projekthistorie",
    education: "Ausbildung", languages: "Sprachen", grade: "Note",
    focus: "Fokus", tech: "Technologien", subproject: "Teilprojekt", dash: "–", countries: { DE: "Deutschland" },
  },
  en: {
    profile: "Profile", skills: "Skills", experience: "Project Experience",
    education: "Education", languages: "Languages", grade: "Grade",
    focus: "Focus", tech: "Technologies", subproject: "Sub-project", dash: "—", countries: { DE: "Germany" },
  },
} as const;
const MONTHS_EN = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];

/** Markdown-Steuerzeichen im Fließtext entschärfen. */
const esc = (s: string) => s.replace(/([\\`*_])/g, "\\$1");

function fmtMonth(ym: string, lang: Lang): string {
  const [y, m] = ym.split("-");
  return lang === "de" ? `${m}/${y}` : `${MONTHS_EN[Number(m) - 1]} ${y}`;
}

/** Laufende Einträge enden — wie im PDF — mit "heute"/"present". */
function fmtRange(start: string, end: string | undefined, lang: Lang): string {
  return `${fmtMonth(start, lang)} – ${end ? fmtMonth(end, lang) : lang === "de" ? "heute" : "present"}`;
}

const displayUrl = (u: string) => u.replace(/^https?:\/\//, "").replace(/^www\./, "").replace(/\/$/, "");

const bulletList = (items: string[]) => items.map((b) => `- ${esc(b)}`).join("\n");
const bulletsOf = (e: Entry) => [...(e.responsibilities ?? []), ...(e.achievements ?? [])];
const techLine = (keywords: string[], lang: Lang) =>
  keywords.length > 0 ? `*${LABELS[lang].tech}:* ${esc(keywords.join(" · "))}` : "";

// Kleine Bausteine je Abschnitt; leere Teile fallen über filter(Boolean) weg.
function entryBody(e: Entry, lang: Lang): string[] {
  const bullets = bulletsOf(e);
  return [bullets.length > 0 ? bulletList(bullets) : "", techLine(e.keywords ?? [], lang)].filter(Boolean);
}

function contactLines(b: Resume["basics"], lang: Lang): string[] {
  const countries: Record<string, string> = LABELS[lang].countries;
  const country = countries[b.location.countryCode] ?? b.location.countryCode;
  const contact = [`${b.location.city}, ${country}`, b.email, b.phone].filter(Boolean).join(" · ");
  const links = [b.url, ...b.profiles.map((p) => p.url)]
    .filter((u): u is string => Boolean(u))
    .map((u) => `[${displayUrl(u)}](${u})`)
    .join(" · ");
  return [esc(contact), links, b.availability ? `**${esc(b.availability)}**` : ""].filter(Boolean);
}

function workEntry(w: Work, lang: Lang): string[] {
  const meta = [`**${esc(w.name)}**`, w.location, w.workload, fmtRange(w.startDate, w.endDate, lang)];
  const head = [`### ${esc(w.position)}`, meta.filter(Boolean).join(" · ")];
  const subprojects = w.subprojects ?? [];
  if (subprojects.length === 0) return [...head, ...entryBody(w, lang)];
  // Engagement mit Teilprojekten: eigene Bullets ohne Tech-Zeile, dann je Teilprojekt ein Block.
  return [
    ...head,
    ...entryBody({ ...w, keywords: [] }, lang),
    ...subprojects.flatMap((s) => [`#### ${LABELS[lang].subproject}: ${esc(s.title)}`, ...entryBody(s, lang)]),
  ];
}

function educationEntry(e: Education, lang: Lang): string[] {
  const t = LABELS[lang];
  const meta = [`**${esc(e.institution)}**`, fmtRange(e.startDate, e.endDate, lang), e.score ? `${t.grade}: ${esc(e.score)}` : ""];
  const courses = e.courses ?? [];
  return [
    `### ${esc(e.studyType)} · ${esc(e.area)}`,
    meta.filter(Boolean).join(" · "),
    courses.length > 0 ? `*${t.focus}:* ${esc(courses.join(" · "))}` : "",
  ].filter(Boolean);
}

export function toMarkdown(r: Resume, lang: Lang): string {
  const t = LABELS[lang];
  const b = r.basics;
  const parts = [
    `# ${b.name}`, `**${esc(b.label)}**`, ...contactLines(b, lang),
    `## ${t.profile}`, esc(b.summary),
    `## ${t.skills}`, r.skills.map((s) => `- **${esc(s.name)}:** ${esc(s.keywords.join(" · "))}`).join("\n"),
    `## ${t.experience}`, ...r.work.flatMap((w) => workEntry(w, lang)),
    `## ${t.education}`, ...r.education.flatMap((e) => educationEntry(e, lang)),
    `## ${t.languages}`, r.languages.map((l) => `- **${esc(l.language)}** ${t.dash} ${esc(l.fluency)}`).join("\n"),
  ];
  return parts.join("\n\n") + "\n";
}
