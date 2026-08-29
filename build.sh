#!/usr/bin/env bash
# Inlines vendor libraries into the template to produce the single-file index.html.
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import base64, re
from pathlib import Path

tpl = Path("src/index.template.html").read_text()

# KaTeX CSS: keep only the .woff2 sources and embed them as data: URIs so the
# page needs no font files on disk.
css = Path("vendor/katex.min.css").read_text()
def inline_font(m):
    name = m.group(1)
    data = base64.b64encode(Path(f"vendor/katex-fonts/{name}.woff2").read_bytes()).decode()
    return f"src:url(data:font/woff2;base64,{data}) format(\"woff2\")"
css = re.sub(r"src:url\(fonts/([A-Za-z0-9_-]+)\.woff2\)[^;}]*", inline_font, css)
assert "url(fonts/" not in css, "katex css still references external fonts"
tpl = tpl.replace("/*__KATEX_CSS__*/", css)

for marker, path in [("/*__MARKED__*/", "vendor/marked.min.js"),
                     ("/*__PURIFY__*/", "vendor/purify.min.js"),
                     ("/*__HLJS__*/", "vendor/highlight.min.js"),
                     ("/*__KATEX__*/", "vendor/katex.min.js"),
                     ("/*__MERMAID__*/", "vendor/mermaid.min.js")]:
    js = Path(path).read_text()
    # '</script' inside an inline script would end the tag early; escaping the
    # slash is a no-op in JS strings/regexes, so this is always safe.
    js = js.replace("</script", "<\\/script").replace("</SCRIPT", "<\\/SCRIPT")
    if marker not in tpl:
        raise SystemExit(f"marker {marker} missing from template")
    tpl = tpl.replace(marker, js)

Path("index.html").write_text(tpl)
print(f"built index.html ({len(tpl):,} bytes)")
PY

# The repo root is the deployable folder: the single-file app plus the PWA
# sidecars (manifest, service worker, icons) that make it installable and
# let it register as a handler for .md files.
cp pwa/manifest.json pwa/sw.js pwa/icon-192.png pwa/icon-512.png pwa/icon-maskable-512.png .
echo "copied PWA files (manifest, service worker, icons)"
