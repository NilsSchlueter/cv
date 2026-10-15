#!/bin/sh
# Python-Umgebung für `npm run check:pdf` (pypdf + pdfminer.six in .venv/).
# Nimmt das neueste vorhandene Python ab 3.10.
set -e
for py in python3.13 python3.12 python3.11 python3.10 python3; do
  if command -v "$py" >/dev/null && "$py" -c 'import sys; sys.exit(sys.version_info < (3, 10))'; then
    "$py" -m venv .venv
    .venv/bin/pip install -q pypdf pdfminer.six
    echo "check:pdf bereit ($($py --version))"
    exit 0
  fi
done
echo "Python >= 3.10 nicht gefunden" >&2
exit 1
