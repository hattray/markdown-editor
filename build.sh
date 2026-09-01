#!/usr/bin/env bash
# Inlines the vendored libraries into the template and writes two builds:
#
#   index.html       everything, including Mermaid and KaTeX
#   index-lite.html  without them — ~20x smaller, for people who never write
#                    a diagram or an equation
#
# The app feature-detects both libraries at runtime, so one template serves
# both and they can never drift apart.
set -euo pipefail
cd "$(dirname "$0")"

python3 - <<'PY'
import base64, re
from pathlib import Path

template = Path("src/index.template.html").read_text()

def katex_css():
    """KaTeX's stylesheet with its .woff2 fonts embedded as data: URIs."""
    css = Path("vendor/katex.min.css").read_text()
    def inline_font(m):
        data = base64.b64encode(Path(f"vendor/katex-fonts/{m.group(1)}.woff2").read_bytes()).decode()
        return f'src:url(data:font/woff2;base64,{data}) format("woff2")'
    css = re.sub(r"src:url\(fonts/([A-Za-z0-9_-]+)\.woff2\)[^;}]*", inline_font, css)
    assert "url(fonts/" not in css, "katex css still references external fonts"
    return css

def js(path):
    src = Path(path).read_text()
    # '</script' would end the inline tag early; escaping the slash is a no-op in JS
    return src.replace("</script", "<\\/script").replace("</SCRIPT", "<\\/SCRIPT")

LIBS = {
    "/*__MARKED__*/":  "vendor/marked.min.js",
    "/*__PURIFY__*/":  "vendor/purify.min.js",
    "/*__HLJS__*/":    "vendor/highlight.min.js",
    "/*__KATEX__*/":   "vendor/katex.min.js",
    "/*__MERMAID__*/": "vendor/mermaid.min.js",
}
HEAVY = {"/*__KATEX__*/", "/*__MERMAID__*/"}

def build(out, include_heavy):
    doc = template
    doc = doc.replace("/*__KATEX_CSS__*/", katex_css() if include_heavy else "")
    for marker, path in LIBS.items():
        if marker not in doc:
            raise SystemExit(f"marker {marker} missing from template")
        doc = doc.replace(marker, js(path) if include_heavy or marker not in HEAVY else "")
    if not include_heavy:
        # the attribution banner must describe what this file actually bundles
        doc = re.sub(r"^ {4}(KaTeX|Mermaid) \d.*\n", "", doc, flags=re.M)   # banner rows only
        doc = doc.replace("  KaTeX's embedded .woff2 fonts are under the SIL Open Font License 1.1.\n", "")
        doc = doc.replace(
            "This file bundles the following libraries. KaTeX and Mermaid ship no license\n"
            "  banner of their own, so their notices are recorded here; the others carry\n"
            "  their banners inside their own minified code below.",
            "This file bundles the following libraries, each of which carries its own\n"
            "  license banner inside its minified code below.")
        doc = doc.replace("Free MD Viewer —", "Free MD Viewer (lite) —", 1)
        # lite is a standalone file, so drop the PWA sidecars: its manifest and
        # service worker would point installs and the offline cache at the FULL
        # build sitting next to it.
        for tag in ('<link rel="manifest" href="manifest.json">\n',
                    '<link rel="icon" href="icon-192.png" sizes="192x192" type="image/png">\n',
                    '<link rel="apple-touch-icon" href="icon-192.png">\n'):
            doc = doc.replace(tag, "")
        sw = ('  if ("serviceWorker" in navigator && location.protocol.startsWith("http")) {\n'
              '    window.addEventListener("load", () => {\n'
              '      navigator.serviceWorker.register("sw.js").catch(() => {});\n'
              '    });\n'
              '  }\n')
        assert sw in doc, "service worker registration block not found"
        doc = doc.replace(sw, "  // no service worker in the lite build: it ships as a single standalone file\n")
    Path(out).write_text(doc)
    print(f"built {out} ({len(doc):,} bytes)")

build("index.html", True)
build("index-lite.html", False)
PY

# The repo root is the deployable folder for the full build: the app plus the
# PWA sidecars that make it installable and register it for .md files.
cp pwa/manifest.json pwa/sw.js pwa/icon-192.png pwa/icon-512.png pwa/icon-maskable-512.png .
echo "copied PWA files (manifest, service worker, icons)"
