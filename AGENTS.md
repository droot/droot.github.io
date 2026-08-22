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

## Deploying

Push to `main`. Pages rebuilds in a minute or two. If the build fails, the
previously built site stays live, so a bad push degrades to "no change" rather
than an outage. Verify with `curl -sI https://arorasunil.com/archive/`.
