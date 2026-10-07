# Changelog

All notable changes to Free MD Viewer. This project follows
[Keep a Changelog](https://keepachangelog.com/) and
[Semantic Versioning](https://semver.org/).

The version and build date of any copy are in the comment at the top of the file
and in the app's **?** panel, so a downloaded file can always be identified.

## [Unreleased]

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
