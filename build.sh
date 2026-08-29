#!/usr/bin/env bash
# Inlines vendor libraries into the template to produce the single-file index.html.
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
from pathlib import Path

tpl = Path("src/index.template.html").read_text()
for marker, path in [("/*__MARKED__*/", "vendor/marked.min.js"),
                     ("/*__PURIFY__*/", "vendor/purify.min.js")]:
    js = Path(path).read_text()
    if "</script" in js.lower():
        raise SystemExit(f"{path} contains '</script' and cannot be inlined safely")
    if marker not in tpl:
        raise SystemExit(f"marker {marker} missing from template")
    tpl = tpl.replace(marker, js)

Path("index.html").write_text(tpl)
print(f"built index.html ({len(tpl):,} bytes)")
PY
