# postbird — Postbox-style theme for Betterbird

## Purpose
Recreate Postbox's look/feel on Betterbird via userChrome.css. The #1 design
goal is CHEAP REPAIR after Betterbird ESR updates: broken selectors must be
findable in minutes via docs/selector-map.md and docs/migration-runbook.md.

## Environment
- OS: Windows 11
- Betterbird: 140.12.0esr-bb24, install: C:\Program Files\Betterbird\
- Profile: %APPDATA%\Thunderbird\Profiles\<profile>.default-release
  (Betterbird reuses the Thunderbird profile root; deploy.ps1 auto-detects it)
- Pref toolkit.legacyUserProfileCustomizations.stylesheets = true (already set)
- Deploy: scripts/deploy.ps1 copies chrome/ into the profile. I restart
  Betterbird manually. Live-tuning happens in Browser Toolbox Style Editor
  (Ctrl+Shift+Alt+I) by ME; final values get committed here.

## Feedback loop (important)
Claude cannot see the rendered UI. After each deploy I add screenshots to
refs/screenshots-wip/ named <component>-<date>.png. Target references live in
refs/postbox-target/. Compare, propose diffs, never assume a change "worked."

## Ground truth for selectors
- refs/betterbird-extracted/  → CSS extracted from Betterbird's own omni.ja.
  THIS is the authority on current DOM/selectors. Do not trust training data
  for Thunderbird DOM structure (115→128→140 changed heavily).
- refs/postbox-extracted/     → CSS from Postbox omni.ja. Authority on target
  VALUES (colors, fonts, metrics). GITIGNORED — proprietary, reference only.
- Never copy Postbox rules/assets verbatim into chrome/. Tokens + fresh
  selectors only.

## Hard constraints
- CSS only. No add-ons, no userChrome.js loaders, no autoconfig.
- Performance: no `*` selectors, no `:has()` inside #threadTree or list rows.
- One component per file; all literals in config.css custom properties.
- Windows paths; PowerShell for scripts.

## Definition of done (v1.0)
threadpane, folderpane, toolbar, tabs, messageheader, composer, statusbar —
matching refs/postbox-target/ screenshots. Everything else → docs/backlog.md.
This project has a fixed scope by explicit agreement; do not suggest expanding
it. When v1.0 is tagged, only migration repairs are in scope.

## Migration runbook trigger
When Betterbird updates and something breaks: re-extract Betterbird's omni.ja
into refs/betterbird-extracted/, diff against the previous extraction, update
selector-map.md statuses, patch components, run docs/smoke-test.md.

## Git workflow & deployment
- Branches:
  - `main` — public GitHub branch (default). Clean history; releases tagged here.
  - `feat/<name>` — one per feature/fix, off `main`, merged back via PR.
  - `master` — LOCAL-only archive of the original pre-release history (holds the
    bulky refs/ material). Never pushed.
- Everyday loop: branch `feat/x` off `main` → edit chrome/postbird/ → run
  scripts/deploy.ps1 → restart Betterbird (or live-tune in Browser Toolbox) →
  screenshot compare → update docs/selector-map.md → PR into `main`.
- `refs/` is gitignored except betterbird-version.txt + refs/README.md — the
  extraction, screenshots, Postbox material and community files are local only
  (privacy / copyright / bloat). Repopulate per refs/README.md.
- Deploy: `scripts/deploy.ps1` auto-detects the profile (profiles.ini default,
  else newest *.default-release under %APPDATA%\{Betterbird,Thunderbird}). It
  copies chrome/userChrome.css, chrome/userContent.css and chrome/postbird/ into
  <profile>\chrome\. `-ProfilePath` overrides; `-Link` junctions for live edits.
  Both loaders are read only at startup → restart after every deploy.
- Two stylesheets: userChrome.css = app UI shell; userContent.css = email body
  (imports config.css so --pb-* tokens work in content docs). Status/version:
  v1.0.0 tagged; per Definition of done, only migration repairs unless scope is
  explicitly reopened.

## Tools
- The Project is git version controlled. Commit, branch, merge and add messages 
  as you see fit.
- CodeGraph index covers chrome/, docs/, refs/betterbird-extracted/,
  refs/community/. Prefer it over raw grep for selector lookups in the
  Betterbird extraction ("where is X styled", "what references token Y").
- The index is only valid for the version in refs/betterbird-version.txt.
  After any re-extraction, re-index BEFORE trusting lookup results.
- docs/selector-map.md remains the curated authority for region→selector
  mapping; CodeGraph answers "where", selector-map answers "what we decided".