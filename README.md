# Free MD Viewer

A markdown viewer and editor that runs entirely in your browser. **Your files stay on
your machine** — there is no upload endpoint, no account, and no server-side rendering.

**Live at [kingsbridge-consultancy.com/md-viewer](https://kingsbridge-consultancy.com/md-viewer/)**

Drop a `.md` file on the page (or click **Open**), read it properly rendered, edit it with a
live preview, and save it straight back to disk. The whole app is one self-contained
`index.html` (~3.6 MB, ~1 MB over the wire) with every library and font embedded, so you can
also save the page and run it offline from `file://`.

## Why

Markdown files are everywhere now — every AI tool hands you one — but double-clicking a `.md`
file still gets you a wall of raw text, and most online viewers upload your document to a
server to render it. For work documents and private notes, that's a real cost of a "free"
tool. This renders locally instead.

The claim is checkable rather than promised: everything is inlined, so open devtools and watch
the network tab, or read the source with view-source. Only the vendor libraries are minified —
the app's own code ships readable.

## Features

- **Drag & drop** or file-picker open; accepts `.md`, `.markdown`, `.txt`
- **Live split preview** (Edit / Split / Preview modes) with scroll sync; phones open in Preview
- **Save writes back to the original file** via the File System Access API (Chrome/Edge — works
  for both picked and dropped files); Save-As and a plain download fallback everywhere else
- **GitHub-flavored markdown**: tables, task lists, strikethrough, fenced code blocks
- **Syntax highlighting** in code fences (highlight.js, GitHub-style palette for both themes)
- **Mermaid diagrams** from ` ```mermaid ` fences, theme-aware (re-rendered on dark/light toggle)
- **LaTeX math** via KaTeX: `$inline$`, `$$display$$`, `\(...\)`, `\[...\]` — math is extracted
  *before* markdown parsing so underscores/asterisks in TeX survive, and `$` inside code spans
  and fences is left alone
- **Footnotes**: `[^1]` references with `[^1]: …` definitions, numbered by order of first
  reference, collected into a footnote section with back-links. A reference with no definition
  stays literal text, as on GitHub
- **Find & replace** in the editor (`⌘F`/`Ctrl+F`) — match count, next/previous, replace one or
  all. Replace All is a single undo step. In Preview the browser's own find is left alone
- **Insert-equation palette** — a grid of LaTeX structures, Greek letters and operators, each
  rendered with KaTeX so you pick the shape instead of recalling the syntax
- **GitHub callouts**: `> [!NOTE]`, `[!TIP]`, `[!IMPORTANT]`, `[!WARNING]`, `[!CAUTION]`
- **Export** (all generated in-page, nothing uploaded, no watermarks or limits):
  - `.html` — the rendered document as one self-contained file, styles and KaTeX fonts embedded
  - `.png` — the preview rasterized via an SVG `<foreignObject>` painted onto a canvas, at up to
    2× device scale. Remote images can't load inside an SVG-as-image, so they come out blank;
    `data:` URIs are fine
  - PDF — the browser's own print-to-PDF, so the text stays selectable. Printing forces the light
    palette (and temporarily switches the app to light first, since Mermaid bakes theme colors
    into its SVG)
- **Copy code blocks** — hover a fenced code block for a `Copy` button (falls back to a
  legacy copy when the async clipboard is unavailable, e.g. from `file://`)
- **Help & support** — a `?` panel with the shortcuts, plus a route to request custom builds
  (lite, SSO, sync, on-premise) at support@kingsbridge-consultancy.com
- **Per-block downloads** — hover a Mermaid diagram for an `SVG` button (real dimensions taken
  from its viewBox, not mermaid's `width="100%"`), or a table for a `CSV` button (RFC-style
  quoting, UTF-8 BOM so Excel reads accents correctly)
- **Installable (Chrome/Edge desktop)** — a service worker plus a manifest declaring
  `file_handlers`, so once installed, double-clicking a `.md` file opens it here. The launch
  handle is a real `FileSystemFileHandle`, so Save writes straight back to the file you opened.
  Works offline
- **Table of contents** — toggleable panel built from headings; a slide-over drawer on phones
- **Reader controls** — text size and line width (Aa button), persisted
- **Sanitized rendering** — untrusted markdown can't inject script (DOMPurify, including over
  KaTeX output)
- **Draft auto-restore** — content persists in `localStorage`, so a refresh or crash loses nothing
- **Dark / light theme** (follows system, manual toggle remembered)
- Inline rename, word/char/line counts, `⌘S` / `⌘⇧S` / `⌘O` shortcuts

## Browser support

Rendering, editing, exports and per-block downloads work in any current browser. Two features
depend on Chromium-desktop-only APIs and degrade gracefully elsewhere:

| Feature | API | Elsewhere |
| ------- | --- | --------- |
| Save back to the original file | File System Access | falls back to a download |
| Double-click a `.md` to open it here | `file_handlers` + `launchQueue` | not offered |

## Building

No package manager, no toolchain — just Python 3 and bash:

```bash
./build.sh
```

That inlines the vendored libraries and the KaTeX fonts into `src/index.template.html` and
writes `index.html`, then copies the PWA sidecars to the repo root. Edit
`src/index.template.html`, never `index.html`.

```
src/index.template.html   the app (HTML/CSS/JS), with markers where libraries get inlined
vendor/                   the bundled libraries + KaTeX .woff2 fonts
pwa/                      manifest.json, sw.js and the icons
tools/make-icons.py       regenerates the icons (hand-rolled PNG encoder, no dependencies)
build.sh                  the build
index.html                the built, self-contained app (committed)
licenses/                 full license texts for everything bundled
```

## Self-hosting

`index.html` is the entire product. Copy it anywhere a static file can be served, or open it
from disk. It needs no CORS, no CSP beyond allowing its own inline scripts, and no backend.

The `manifest.json`, `sw.js` and `icon-*.png` files beside it are only needed for the
installable-app behavior; serving `index.html` alone works fine without them. Installability
additionally requires HTTPS (or localhost).

## License

[MIT](LICENSE) for this project's own code.

The built `index.html` bundles marked, DOMPurify, highlight.js, KaTeX and Mermaid, so their
licenses travel with any copy you distribute — see [THIRD-PARTY-NOTICES.md](THIRD-PARTY-NOTICES.md)
and [`licenses/`](licenses/). A summary is also embedded as a comment at the top of the built file.

## Contributing

Issues and pull requests are welcome. Two things to keep in mind:

1. Edit `src/index.template.html` and run `./build.sh`; don't hand-edit `index.html`.
2. Anything that would send a user's document off their machine — telemetry, cloud rendering,
   AI features backed by an API, share links that upload — is out of scope by design. Features
   that need a server belong in a fork, not here.
