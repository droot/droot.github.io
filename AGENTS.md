# arorasunil.com

Personal blog. Jekyll + the `minima` theme, served from the `main` branch of
`droot/droot.github.io` by GitHub Pages' **classic** Jekyll build. There is no
Actions workflow — pushing to `main` deploys. `droot.github.io` redirects to the
custom domain in `CNAME`.

## Commands

```sh
make install   # gems into vendor/bundle (first time only)
make serve     # preview on :4000, drafts included
make build     # build _site/ the way Pages will
make check     # build + fail on leftover Hugo shortcodes
make new title="My Post"              # scaffold a draft
make publish post=_drafts/my-post.md  # move draft into _posts, dated today
```

Don't call `jekyll` directly. macOS system Ruby (2.6) is too old for the pinned
Jekyll; the Makefile puts Homebrew's Ruby on PATH. The `Gemfile` pins Jekyll
3.9.5 / minima 2.5.1 to match Pages, and declares `csv`, `base64`, `bigdecimal`,
`logger`, and `ostruct` because Ruby 4.0 dropped them from the default gems.

## Content layout

- `_posts/` — current writing. Appears in the home feed. Filenames need a
  `YYYY-MM-DD-` prefix.
- `_archive/` — 23 recovered posts from 2009–2014. **Not published.** The files
  are kept in the repo but nothing is built from them. Don't move these into
  `_posts/`. No date prefix; the date comes from front matter.
- `_drafts/` — unpublished. Safe to commit; Jekyll won't build them without
  `--drafts`.

To publish the archive at `/archive/`, all of these are needed — any one alone
leaves it broken or half-visible:

1. `collections.archive.output: true` in `_config.yml`
2. remove `published: false` from `archive.html`
3. add `archive.html` back to `header_pages` for the nav link
4. restore the archive styles, which were stripped to keep the shipped CSS
   minimal: `git show a86b0c6:assets/main.scss` has `.archive-year`,
   `.archive-list`, `.archive-notice`, and the `.video-embed` / `.slide-embed`
   iframe wrappers

Archive entries must not set `layout:` in their own front matter — the
`archived` layout is applied by the `defaults:` block in `_config.yml`, and a
per-file `layout:` silently overrides it and drops the "From the archive"
banner.

## Design

Palette is "Ink": no accent hue. Links are the same near-black as body text and
are marked by an **underline**, so the underline is load-bearing — don't
"clean it up". The single hue, `$ink-slate` `#3e5c76`, is reserved for literal
values in code.

Type is tuned for reading a long post: Roboto at **wght 350** (Light read thin
at length, Regular too dense), 19px/1.75, and a **34em measure** (~68
characters). `$content-width` is that measure plus minima's gutters, so the nav
aligns with the text column. Sizes in post bodies are **em-relative** — a `rem`
value here ignores the base size, which is how post text ended up smaller than
the rest of the site once before.

`_includes/header.html` and `_layouts/{home,page}.html` override minima's
originals. Nav comes from `site.nav` in `_config.yml`, not page titles, so a nav
label is independent of the `<title>` tag; the current page renders as a
`<span>` rather than a self-link.

## Gotchas

**`assets/main.scss` needs its `---` front-matter delimiters on their own
lines.** Without them Jekyll doesn't process the file, serves it raw as
`text/x-scss`, and the site silently falls back to stock minima CSS. This was
broken in production for seven months. Run `make build` and confirm
`_site/assets/main.css` contains `Roboto` after touching that file.

**Sass rejects malformed hex colors.** `$grey-color` was once `#facfade` (seven
digits), which makes `lighten()` throw and the whole build fail.

**The `master` branch is dead** — an older Hugo version of the site, kept only
as a backup of the pre-2015 history. Never develop on it.

**Old posts came from Hugo**, so watch for `{{< gist >}}`, `{{< youtube >}}`,
and `{{< slideshare >}}` shortcodes. Jekyll renders those as raw text and warns.
`make check` catches them.

**Minima's code styling fights you on specificity, not source order.** It paints
`.highlighter-rouge .highlight` (0,2,0) and `pre, code` together, and rouge emits
`div.highlighter-rouge > div.highlight > pre.highlight > code`. A bare
`.highlight` override loses, and the inner `<code>` paints its own slab on top.
Overrides must match those selectors exactly. After changing code styling, check
the resolved value rather than trusting that your rule came last.

**Check syntax colours against Go, not YAML.** Go is ~40% plain identifiers
(`.n`) and emits almost no `.na`, so a theme that looks fine on YAML keys can
render Go as one flat wall of colour.

## Deploying

Push to `main`. Pages rebuilds in a minute or two. If the build fails, the
previously built site stays live, so a bad push degrades to "no change" rather
than an outage. Verify with `curl -sI https://arorasunil.com/archive/`.
