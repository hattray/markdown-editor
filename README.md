# Markdown Editor

A single-file, browser-based markdown editor & viewer. Drag a `.md` file onto the page (or click **Open**), edit on the left, see the rendered result live on the right. **Everything stays on the client** — no server, no upload, no network requests at all.

The whole app is one self-contained `index.html` (~83 KB) that can be opened straight from disk or dropped onto any static host.

## Features

- **Drag & drop** or file-picker open; accepts `.md`, `.markdown`, `.txt`
- **Live split preview** (Edit / Split / Preview modes) with scroll sync
- **Save writes back to the original file** via the File System Access API (Chrome/Edge — works for both picked and dropped files); Save-As and a plain **Download** fallback everywhere else
- **GitHub-flavored markdown**: tables, task lists, strikethrough, fenced code blocks
- **Sanitized rendering** — untrusted markdown can't inject script (DOMPurify)
- **Draft auto-restore**: content persists in `localStorage`, so a refresh or crash loses nothing
- **Dark / light theme** (follows system, manual toggle remembered)
- Rename inline, word/char/line counts, `⌘S` / `⌘⇧S` / `⌘O` shortcuts, print-friendly (printing outputs just the rendered document)

## Structure

```
src/index.template.html   the app (HTML/CSS/JS) with two inline markers
vendor/marked.min.js      markdown parser  (marked v14, MIT)
vendor/purify.min.js      HTML sanitizer   (DOMPurify v3, MIT)
build.sh                  inlines the vendor libs into the template
index.html                the built, self-contained deliverable (committed)
```

After editing `src/index.template.html`, run:

```bash
./build.sh
```

and commit the regenerated `index.html`.

## Deploying

`index.html` is the entire product. Copy it anywhere a static file can be served (or open it locally with `file://`). No build step, no dependencies, no CORS or CSP requirements beyond allowing its own inline script.
