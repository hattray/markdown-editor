# Changelog

All notable changes to Free MD Viewer. This project follows
[Keep a Changelog](https://keepachangelog.com/) and
[Semantic Versioning](https://semver.org/).

The version and build date of any copy are in the comment at the top of the file
and in the app's **?** panel, so a downloaded file can always be identified.

## [Unreleased]

### Added

- The app's name in the toolbar links to freemdviewer.com. It opens in a new tab
  rather than navigating the app, so an open document and any unsaved edits are
  left alone.

- A landing page, served from `site/` at **freemdviewer.com**, with the viewer at
  `/app/`. The app's manifest uses relative paths, so the PWA scopes itself to
  `/app/` with no changes. The viewer is still served at
  `kingsbridge-consultancy.com/md-viewer/` as well — the Show HN post links there
  and an installed app starts there, so redirecting it would break both.
- SEO and answer-engine files for that site: a generated `sitemap.xml`, a real
  `robots.txt` (Cloudflare's managed one is all comments and sets nothing, so it
  declared no sitemap), an `llms.txt` summary, and SoftwareApplication + FAQPage
  JSON-LD generated from the page's own FAQ so the two cannot drift apart.
- Privacy and support pages on freemdviewer.com, so the site's footer no longer
  sends people to the Kingsbridge site for them. The privacy page is specific
  rather than boilerplate, and is honest about what the hosted site does collect:
  Cloudflare Web Analytics page views on every page, and Google Fonts everywhere
  except the app, which embeds its fonts. A downloaded copy has neither.

## [1.1.0] — 2026-10-26

Multiple documents, and the app now notices when a file changes underneath it.

### Added

- **Several documents at once.** The launch handler read `params.files[0]` and
  discarded the rest, so selecting five files in Finder and choosing "Open With"
  opened one of them silently. Every entry point — OS launch, the file picker
  (now `multiple: true`), the fallback input and drag-and-drop — takes all the
  files, and a tab strip above the editor switches between them. Each document
  keeps its own file handle, so Save writes back to the right file, and switching
  captures the editor first so edits survive a round trip.
- **Edits made elsewhere are noticed.** If another editor changes an open file, a
  bar offers to reload it. Browsers get no file-change events, so the handle is
  stat'd — via `getFile().lastModified`, which does not read the contents — on
  window focus, on a tab switch, and on a 20-second timer while visible.
  Reloading keeps your place and warns first if you have unsaved edits.
- **New** adds a document instead of closing the open set, so it no longer needs
  a confirmation. An untouched welcome or blank document is reused rather than
  leaving an empty tab behind.
- Re-opening a file switches to the document already open instead of adding a
  second copy, compared with `isSameEntry` rather than by name.

### Fixed

- **Save could destroy another editor's work.** It wrote straight to the file
  with no check on whether the file had moved underneath it, so a change made
  elsewhere was overwritten silently. Save now compares the timestamp and asks
  before overwriting; declining leaves their version on disk and your edits in
  the editor.
- A multi-file launch opened only some of the files. Three causes: the manifest
  had no `launch_handler`, so Chrome's default `auto` mode could *navigate* the
  app window per launch and a navigation reloads the page, resetting the open
  set; concurrent opens could interleave; and the launch consumer was registered
  before startup finished, so files could be loaded and then clobbered by the
  boot code. The manifest now sets `client_mode: "focus-existing"`, opens run
  through one promise chain, and the consumer is registered last.
- A file already open as a restored draft opened a second time. The draft has no
  file handle, so it never matched the incoming handle; it is now matched by name
  and adopts the handle, which also means Save writes back to the file instead of
  asking where to put it.
- A file the operating system refuses to read now says so. Dismissing the picker
  and a genuinely failed read landed in the same `catch`, so a file blocked by
  macOS's Files & Folders privacy controls — which gate protected folders and
  other apps' containers, such as a Drive sync folder — appeared to do nothing at
  all. Cancelling is still silent.
- The window title names the open file, and an installed window no longer repeats
  the app name it already draws itself.

## [1.0.0] — 2026-10-07

First tagged release. The app has been live at
[kingsbridge-consultancy.com/md-viewer](https://kingsbridge-consultancy.com/md-viewer/)
since 2026-08-29; this release makes the single-file builds downloadable and
identifiable by version.

### Added

- **Open and edit markdown locally** — drag & drop or file picker; the file never
  leaves the device. Save writes back to the original file via the File System
  Access API (Chrome/Edge), with a download fallback elsewhere.
- **Rendering** — GitHub-flavored markdown, syntax highlighting (highlight.js),
  Mermaid diagrams, LaTeX math via KaTeX, GitHub callouts, and footnotes.
- **Find & replace** in the editor (`⌘F`/`Ctrl+F`); Replace All is one undo step.
- **Insert-equation palette** — 69 LaTeX templates, each rendered with KaTeX.
- **Export** — self-contained `.html`, `.png` of the preview, and PDF through the
  browser's print dialog. No watermarks, no page limits, no account.
- **Per-block actions** — copy a code block, download a diagram as `.svg`, or a
  table as `.csv`.
- **Installable** — a manifest declaring `file_handlers`, so a double-clicked
  `.md` opens in the app and Save writes back to that same file. Works offline.
- **Table of contents** (a slide-over drawer on phones) and reader controls for
  text size and line width.
- **Lite build** (`index-lite.html`, ~270 KB vs ~3.7 MB) without Mermaid and
  KaTeX, for anyone who writes neither. Requested in
  [#1](https://github.com/hattray/markdown-editor/issues/1).
- **Help panel** with the keyboard shortcuts, the version, and a route to request
  custom builds.
- Draft auto-restore via `localStorage`, dark/light theme, sanitized rendering
  (DOMPurify, including over KaTeX output).

### Fixed

- The window title names the open file; an installed window no longer repeats the
  app name, which it already draws itself.
- `Shift+Tab` outdents instead of inserting spaces, and Tab is undoable — both
  paths write through `execCommand("insertText")`, since `setRangeText` bypasses
  the browser's native undo stack.
- The table of contents works on phones (it was `display: none` below 900px, so
  the button did nothing).
- Documents open at the top rather than scrolled to the last line.
- The equation palette's superscript button inserted a bare `{}` group: its
  caret-position marker was `^`, which is also LaTeX's superscript operator.

### Notes

- Everything is inlined, so the app makes no network requests of its own. The
  hosted page is served behind Cloudflare, which adds its own analytics beacon;
  a downloaded copy has nothing of the kind.
- **A downloaded file does not update itself.** The hosted page and anything
  installed from it update on next launch; a copy on disk stays as it was. Use
  the link in the **?** panel to check for a newer release.
