# Contributing to postbird

postbird recreates Postbox's "Monterail Dark" look on Betterbird using only
`userChrome.css` / `userContent.css`. The overriding design goal is **cheap
repair** after Betterbird ESR updates: a broken selector must be findable in
minutes.

## The one rule that matters most

Betterbird's UI DOM changed heavily across Thunderbird 115 → 128 → 140. **Do not
write selectors from memory** — verify every selector against the CSS/markup of
the exact Betterbird version in `refs/betterbird-version.txt`, and record the
decision in `docs/selector-map.md`. If you can't point to a source, say so
rather than guess.

`docs/selector-map.md` is the project spine: `region → Betterbird selector →
status`. `docs/migration-runbook.md` is the repair procedure after an ESR bump.

## Hard constraints

- **CSS only.** No JS, no `userChrome.js` loaders, no autoconfig, no add-ons.
  (Some roadmap items would relax this — but only if scope is explicitly
  reopened; see the README roadmap.)
- **Performance:** no `*` selectors, and no `:has()` inside `#threadTree` or
  list rows (virtualized, performance-critical).
- **One UI region per component file.** No literal colours/sizes in components —
  everything references a `--pb-*` token in `chrome/postbird/config.css`.
- Never copy Postbox CSS or icon/image assets verbatim. Extract *values* into
  tokens; write selectors fresh against Betterbird's DOM.
- Windows paths; PowerShell for scripts.

## Repo layout

```
chrome/
  userChrome.css              loader — app UI shell (@import only)
  userContent.css             loader — email body (@import only)
  postbird/
    config.css                ALL design tokens (single source of truth)
    components/*.css            one file per UI region
    content/message-body.css    email-body styling (via userContent.css)
scripts/deploy.ps1            copy chrome/ → profile (auto-detects it)
docs/
  selector-map.md             the mapping table (spine)
  migration-runbook.md        repair procedure after a Betterbird update
  smoke-test.md               post-deploy visual checklist
  backlog.md                  out-of-scope / blocked ideas (log here, not in code)
refs/                         LOCAL-only reference material (gitignored; see refs/README.md)
```

## Two stylesheets

- **`userChrome.css`** styles the app UI shell (toolbars, panes, folder tree,
  message header, the frame around the message).
- **`userContent.css`** styles content documents — the email **body** (and
  feeds/web pages). It re-imports `config.css` so `--pb-*` tokens resolve inside
  content documents (they don't inherit the chrome document's tokens).

## The development loop

You cannot see the rendered UI from code alone — the human is the visual
feedback channel. Never claim a change "works" or "matches"; propose a diff and
verify with a screenshot.

1. Branch `feat/<name>` off `main`.
2. Edit `chrome/postbird/…` (values in `config.css`, selectors in components).
3. `./scripts/deploy.ps1` → restart Betterbird (or live-tune in the Browser
   Toolbox Style Editor, `Ctrl+Shift+Alt+I`).
4. Take a screenshot; compare to the target.
5. Update `docs/selector-map.md` status; run `docs/smoke-test.md`.
6. PR into `main`.

## Branching & releases

- **`main`** — published GitHub default; clean history; releases tagged here.
- **`feat/<name>`** — one per feature/fix off `main`, merged via PR.

## Deployment

`scripts/deploy.ps1` auto-detects the Betterbird/Thunderbird profile
(`profiles.ini` default, else newest `*.default-release` under
`%APPDATA%\{Betterbird,Thunderbird}\Profiles`). It copies both loaders and
`chrome/postbird/` into `<profile>\chrome\`. `-ProfilePath` overrides; `-Link`
junctions for live editing. Restart the app after every deploy — the
stylesheets are only read at startup.

## After a Betterbird update (repair mode — the point of this repo)

Follow `docs/migration-runbook.md`. In short: refresh your local
`refs/betterbird-extracted/` for the new version, update
`refs/betterbird-version.txt`, diff old vs new, fix broken selectors in the
components + `docs/selector-map.md`, and run `docs/smoke-test.md`.

## Scope

v1.0 is fixed: threadpane, folderpane, toolbar, tabs, messageheader, composer,
statusbar, and the email body. It is **tagged** — only migration repairs are in
scope unless the maintainer explicitly reopens it. Log new ideas in
`docs/backlog.md` or the README roadmap, not in code.
