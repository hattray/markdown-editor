# Free MD Viewer

A single-file, browser-based markdown viewer & editor, live at
**[kingsbridge-consultancy.com/md-viewer](https://kingsbridge-consultancy.com/md-viewer/)**.
Drag a `.md` file onto the page (or click **Open**), edit on the left, see the rendered result
live on the right. **Everything stays on the client** — no server, no upload, and zero network
requests at runtime (all libraries and fonts are embedded).

The whole app is one self-contained `index.html` (~3.6 MB raw, ~1 MB compressed over the wire)
that can be opened straight from disk or dropped onto any static host.

## Features

- **Drag & drop** or file-picker open; accepts `.md`, `.markdown`, `.txt`
- **Live split preview** (Edit / Split / Preview modes) with scroll sync
- **Save writes back to the original file** via the File System Access API (Chrome/Edge — works for both picked and dropped files); Save-As and a plain **Download** fallback everywhere else
- **GitHub-flavored markdown**: tables, task lists, strikethrough, fenced code blocks
- **Syntax highlighting** in code fences (highlight.js, GitHub-style palette for both themes)
- **Mermaid diagrams** from ` ```mermaid ` fences, theme-aware (re-rendered on dark/light toggle)
- **LaTeX math** via KaTeX: `$inline$`, `$$display$$`, `\(...\)`, `\[...\]` — math is extracted *before* markdown parsing so underscores/asterisks in TeX survive, and `$` inside code spans/fences is left alone
- **GitHub callouts**: `> [!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]`
- **Export** (all generated in-page, nothing uploaded):
  - `.html` — the rendered document as one self-contained file, styles and KaTeX fonts embedded
  - `.png` — the preview rasterized via an SVG `<foreignObject>` painted onto a canvas, at up to 2× device scale. Remote images can't load inside an SVG-as-image, so they come out blank; `data:` URIs are fine
  - PDF — the browser's own print-to-PDF, so the text stays selectable. Printing forces the light palette (and temporarily switches the app to light first, since Mermaid bakes theme colors into its SVG)
- **Table of contents** — toggleable panel built from headings, click to jump
- **Reader controls** — text size and line width (Aa button), persisted
- **Sanitized rendering** — untrusted markdown can't inject script (DOMPurify, including over KaTeX output)
- **Draft auto-restore**: content persists in `localStorage`, so a refresh or crash loses nothing
- **Dark / light theme** (follows system, manual toggle remembered)
- Rename inline, word/char/line counts, `⌘S` / `⌘⇧S` / `⌘O` shortcuts, print-friendly (printing outputs just the rendered document)

## Structure

```
src/index.template.html   the app (HTML/CSS/JS) with inline markers
vendor/marked.min.js      markdown parser      (marked v14, MIT)
vendor/purify.min.js      HTML sanitizer       (DOMPurify v3, MIT)
vendor/highlight.min.js   code highlighting    (highlight.js v11, BSD-3)
vendor/katex.min.js|css   math rendering       (KaTeX v0.16, MIT)
vendor/katex-fonts/       KaTeX woff2 fonts — embedded as data: URIs at build time
vendor/mermaid.min.js     diagrams             (Mermaid v11, MIT)
build.sh                  inlines the vendor libs + fonts into the template
index.html                the built, self-contained deliverable (committed)
```

After editing `src/index.template.html`, run:

```bash
./build.sh
```

and commit the regenerated `index.html`.

## Deploying

`index.html` is the entire product. Copy it anywhere a static file can be served (or open it locally with `file://`). No build step, no dependencies, no CORS or CSP requirements beyond allowing its own inline script.
