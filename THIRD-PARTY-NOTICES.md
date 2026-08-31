# Third-party notices

The built `index.html` is a single self-contained file, which means these
libraries are **bundled inside it** rather than fetched at runtime. Their
licenses therefore travel with any copy of `index.html` you distribute. Full
license texts are in [`licenses/`](licenses/), and a summary is embedded as a
comment at the top of the built file.

| Component | Version | License | Text |
| --------- | ------- | ------- | ---- |
| [marked](https://github.com/markedjs/marked) | 14.1.4 | MIT | [marked-MIT.txt](licenses/marked-MIT.txt) |
| [DOMPurify](https://github.com/cure53/DOMPurify) | 3.2.7 | Apache-2.0 OR MPL-2.0 | [dompurify-Apache-2.0.txt](licenses/dompurify-Apache-2.0.txt) |
| [highlight.js](https://github.com/highlightjs/highlight.js) | 11.11.1 | BSD-3-Clause | [highlight.js-BSD-3-Clause.txt](licenses/highlight.js-BSD-3-Clause.txt) |
| [KaTeX](https://github.com/KaTeX/KaTeX) | 0.16.22 | MIT | [katex-MIT.txt](licenses/katex-MIT.txt) |
| [Mermaid](https://github.com/mermaid-js/mermaid) | 11.12.0 | MIT | [mermaid-MIT.txt](licenses/mermaid-MIT.txt) |

## KaTeX fonts

The KaTeX `.woff2` fonts in `vendor/katex-fonts/` are embedded into the built
file as `data:` URIs. KaTeX distributes its fonts under the
[SIL Open Font License 1.1](https://scripts.sil.org/OFL); the KaTeX code itself
is MIT. Neither license restricts this kind of redistribution, but both require
the notices above to be carried along.

## Note on the minified bundles

`marked`, `DOMPurify` and `highlight.js` carry their own license banners inside
their minified files, so those survive the build automatically. `KaTeX` and
`Mermaid` ship no top-level banner, which is why the build prepends the summary
comment to `index.html` — otherwise a standalone copy of the file would carry no
attribution for them at all.
