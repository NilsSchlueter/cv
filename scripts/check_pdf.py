"""
Deterministische PDF-Prüfung nach dem Build (`npm run check:pdf`).

Extrahiert beide PDFs mit den Extraktoren, mit denen ATS-Parser und
AI-Screenings lesen, nach dist/text/<LANG>.<tool>.txt und prüft die
Layout-Regeln aus CLAUDE.md:

  - Seitenzahl
  - keine Zeile beginnt mit einem Trenner (·, —, –, |)
  - kein Bullet-Marker allein auf einer Zeile (Marker als eigene Spalte)
  - kein Bindestrich am Zeilenende (zerrissene Komposita)
  - keine Zeile mit nur einem Wort (Profil, Bullets, Tech-Zeilen)
  - Tech-Zeilen höchstens 2 Zeilen (Aushängeschild-Projekt 3)
  - jeder Tag, jede Kompetenz, jeder Zeitraum und jedes Kompositum aus dem
    Fließtext ("Node.js-Backend") kommt bei jedem Extraktor unversehrt an

pypdf und pdfminer sind optional (`npm run check:setup`); ohne sie laufen nur
die pdftotext-Prüfungen. Exit-Code 1, sobald eine Regel verletzt ist.
"""
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
DIST = ROOT / "dist"
TEXT_DIR = DIST / "text"
GENERATED = ROOT / "generated"

PAGES = 4
MAX_TECH_LINES = 2
# Das Aushängeschild-Projekt darf eine dritte Tech-Zeile haben (CLAUDE.md).
FLAGSHIP, MAX_TECH_LINES_FLAGSHIP = "BMW", 3
MONTHS_EN = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]

failures = 0


def fail(msg: str) -> None:
    global failures
    failures += 1
    print(f"  FAIL {msg}")


def run(*cmd: str) -> str:
    return subprocess.run(cmd, capture_output=True, text=True, check=True).stdout


def extract(pdf: Path, lang: str) -> dict[str, str]:
    """Alle verfügbaren Extraktionen; schreibt sie zum Nachlesen nach dist/text/."""
    texts = {
        "layout": run("pdftotext", "-layout", str(pdf), "-"),
        "pdftotext": run("pdftotext", str(pdf), "-"),
    }
    try:
        from pypdf import PdfReader

        texts["pypdf"] = "\n".join(p.extract_text() for p in PdfReader(pdf).pages)
    except ImportError:
        print("  WARN pypdf fehlt — npm run check:setup")
    try:
        from pdfminer.high_level import extract_text

        texts["pdfminer"] = extract_text(pdf)
    except ImportError:
        print("  WARN pdfminer.six fehlt — npm run check:setup")
    TEXT_DIR.mkdir(exist_ok=True)
    for tool, text in texts.items():
        (TEXT_DIR / f"{lang.upper()}.{tool}.txt").write_text(text)
    return texts


def fmt_month(ym: str, lang: str) -> str:
    y, m = ym.split("-")
    return f"{m}/{y}" if lang == "de" else f"{MONTHS_EN[int(m) - 1]} {y}"


def fmt_range(start: str, end: str | None, lang: str) -> str:
    until = fmt_month(end, lang) if end else ("heute" if lang == "de" else "present")
    return f"{fmt_month(start, lang)} – {until}"


def tech_lines(resume: dict) -> list[tuple[str, list[str]]]:
    """Gerenderte Tech-Zeilen: je Eintrag bzw. je Teilprojekt (das Dach hat keine)."""
    lines = []
    for w in resume["work"]:
        subs = w.get("subprojects") or []
        if subs:
            lines += [(f'{w["name"]} / {s["title"]}', s["keywords"]) for s in subs if s["keywords"]]
        elif w.get("keywords"):
            lines.append((f'{w["name"]} — {w["position"]}', w["keywords"]))
    return lines


def count_rendered_lines(layout: list[str], tags: list[str]) -> int | None:
    """Über wie viele Zeilen läuft die Tag-Folge im Layout-Text? None = nicht gefunden."""
    target = " · ".join(tags)
    for i, line in enumerate(layout):
        if not line.startswith(tags[0]):
            continue
        joined = line
        for j in range(i + 1, min(i + 6, len(layout) + 1)):
            if joined == target:
                return j - i
            if j < len(layout):
                joined += " " + layout[j]
    return None


def compounds(resume: dict) -> set[str]:
    """Wörter mit Bindestrich oder Punkt aus Titeln, Profil und Bullets."""
    texts = [resume["basics"]["summary"]]
    for w in resume["work"]:
        texts += [w["name"], w["position"], *w.get("highlights", [])]
        texts += [s["title"] for s in w.get("subprojects") or []]
    # Tiefgestellte Ziffern extrahieren als normale Ziffern ("CO₂" → "CO2").
    flat = " ".join(texts).translate(str.maketrans("₀₁₂₃₄₅₆₇₈₉", "0123456789"))
    return {m.rstrip(".-") for m in re.findall(r"[^\W_]+(?:[.\-][^\W_]+)+", flat)}


def check(lang: str) -> None:
    pdfs = sorted(DIST.glob(f"*_{lang.upper()}_*.pdf"))
    if not pdfs:
        fail(f"kein PDF für {lang.upper()} in dist/ — erst npm run build")
        return
    pdf = pdfs[-1]
    print(f"\n{pdf.name}")
    texts = extract(pdf, lang)
    resume = json.loads((GENERATED / f"resume.{lang}.json").read_text())
    layout = [re.sub(r"\s+", " ", l).strip() for l in texts["layout"].split("\n")]

    pages = int(re.search(r"Pages:\s+(\d+)", run("pdfinfo", str(pdf))).group(1))
    if pages != PAGES:
        fail(f"{pages} statt {PAGES} Seiten")

    for n, line in enumerate(layout, 1):
        if re.match(r"^[·—–|]", line):
            fail(f"Zeile {n} beginnt mit einem Trenner: {line[:60]}")
        if re.search(r"[^\W_]-$", line):
            fail(f"Zeile {n} endet mit Bindestrich: …{line[-40:]}")
        # Einzelnes Wort auf einer Zeile; Sektionslabels (Versalien) ausgenommen.
        if re.fullmatch(r"[^\s•·]+", line) and not line.isupper():
            fail(f"Zeile {n} enthält nur ein Wort: {line}")

    for label, tags in tech_lines(resume):
        limit = MAX_TECH_LINES_FLAGSHIP if FLAGSHIP in label else MAX_TECH_LINES
        n = count_rendered_lines(layout, tags)
        if n is None:
            fail(f"Tech-Zeile nicht im Layout-Text gefunden: {label}")
        elif n > limit:
            fail(f"Tech-Zeile {label}: {n} Zeilen (max. {limit})")

    # Jeder Begriff muss bei jedem Extraktor als zusammenhängender Text ankommen.
    terms = {t for _, tags in tech_lines(resume) for t in tags}
    terms |= {k for s in resume["skills"] for k in s["keywords"]}
    terms |= {fmt_range(w["startDate"], w.get("endDate"), lang) for w in resume["work"]}
    terms |= {fmt_range(e["startDate"], e.get("endDate"), lang) for e in resume["education"]}
    terms |= compounds(resume)
    for tool, text in texts.items():
        flat = re.sub(r"\s+", " ", text)
        missing = sorted(t for t in terms if t not in flat)
        if missing:
            fail(f"{tool}: {len(missing)} Begriffe nicht unversehrt extrahiert: {', '.join(missing[:8])}")

    # Marker allein auf einer Zeile: Der Extraktor liest die Marker als eigene
    # Spalte, die Bullets verschmelzen zu einem Absatz.
    for tool in ("pdftotext", "pdfminer"):
        lone = len(re.findall(r"(?m)^\s*•\s*$", texts.get(tool, "")))
        if lone:
            fail(f"{tool}: {lone} Zeilen nur mit Bullet-Marker")

    # pypdf trennt Wörter an Kerning-Paaren ("T ailwind") — Kerning muss aus bleiben.
    if "pypdf" in texts:
        splits = re.findall(r"\b[A-ZÄÖÜ] [a-zäöüß]{2,}|\w -\w|\w \)|\( \w", texts["pypdf"])
        if splits:
            fail(f"pypdf zerlegt Wörter: {', '.join(splits[:8])}")


if __name__ == "__main__":
    for lang in ("de", "en"):
        check(lang)
    if failures:
        print(f"\nPDF-Prüfung fehlgeschlagen: {failures} Fehler. Extrakte: dist/text/")
        sys.exit(1)
    print("\nPDF-Prüfung erfolgreich. Extrakte: dist/text/")
