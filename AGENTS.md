# AGENTS.md — postbird

Instructions for any coding agent (Codex, etc.) working in this repo.
CLAUDE.md and the files in docs/ are the authoritative project spec; this
file is the operational quick-start. If they conflict, docs/ wins — flag the
conflict, don't silently pick one.

## What this is
A Betterbird userChrome.css theme recreating the Postbox email client's look
and selected behaviors, on Betterbird ESR. See CLAUDE.md for full context.

## The one rule that matters most
Betterbird's UI DOM changed heavily across Thunderbird 115 → 128 → 140.
Your training data about Thunderbird selectors is UNRELIABLE. Do not write
selectors from memory.

Ground truth = refs/betterbird-extracted/ (CSS pulled from Betterbird's own
omni.ja for the exact version in refs/betterbird-version.txt). Every selector
you use or modify must be traceable to a file there. If you can't point to the
source, say so instead of guessing. CodeGraph indexes this dir — use it to
look selectors up ("where is #threadTree styled").

## Authority hierarchy
- refs/betterbird-extracted/  → current DOM & selectors (WHAT EXISTS)
- refs/postbox-extracted/     → target values: colors, fonts, metrics
                                (proprietary, gitignored, reference only —
                                 never copy rules/assets verbatim into chrome/)
- refs/postbox-target/        → target screenshots (ACCEPTANCE CRITERIA)
- docs/selector-map.md        → curated region→selector decisions (WHAT WE CHOSE)
- refs/betterbird-version.txt → the version everything above is pinned to

## Repo layout
- chrome/userChrome.css              → loader (app UI shell), @import only
- chrome/userContent.css             → loader (email body), @import only
- chrome/postbird/config.css         → ALL design tokens (custom properties)
- chrome/postbird/components/*.css   → one file per UI region
- chrome/postbird/content/*.css      → email-body styling (via userContent.css)
- scripts/deploy.ps1                 → copy chrome/ → profile (auto-detects it)
- docs/selector-map.md               → the mapping table (project spine)
- docs/migration-runbook.md          → repair procedure after Betterbird updates
- docs/smoke-test.md                 → post-change visual checklist
- docs/backlog.md                    → out-of-scope ideas go here, not into code
- refs/                              → LOCAL-only reference material (gitignored
                                       except betterbird-version.txt + README);
                                       repopulate per refs/README.md

## Git workflow & deployment
- Branches: `main` = public GitHub default (clean history, tagged releases);
  `feat/<name>` = one per feature/fix off `main`, merged via PR; `master` =
  maintainer's LOCAL pre-release archive (bulky refs/), never pushed.
- Deploy: `scripts/deploy.ps1` auto-detects the Betterbird/Thunderbird profile.
  It copies both loaders + chrome/postbird/ into <profile>\chrome\. Restart the
  app after every deploy (stylesheets read only at startup).
- Two stylesheets: userChrome.css (app chrome) and userContent.css (email body,
  re-imports config.css so --pb-* tokens resolve in content docs).

## Hard constraints
- CSS ONLY. No JS, no userChrome.js loaders, no autoconfig, no add-ons.
- No `*` selectors and no `:has()` inside #threadTree or list rows
  (virtualized list — performance-critical).
- One UI region per component file. No literal colors/sizes in components;
  everything references a token in config.css.
- Never copy Postbox CSS or icon/image assets verbatim into chrome/. Extract
  VALUES into tokens; write selectors fresh against Betterbird's DOM.
- Windows paths; PowerShell for scripts.

## You cannot see the rendered UI
The human is the only visual feedback channel. Never claim a change "works" or
"matches." After edits, tell the human exactly what to check, and wait for a
screenshot in refs/screenshots-wip/ compared against refs/postbox-target/.
Propose diffs; don't assert results.

## Typical loop
1. Human runs scripts/deploy.ps1 and restarts Betterbird (or live-tunes in
   Browser Toolbox Style Editor, Ctrl+Shift+Alt+I).
2. Human drops a screenshot in refs/screenshots-wip/.
3. You compare to the target, propose a CSS diff citing the extraction source
   for any selector, and update docs/selector-map.md status.

## After a Betterbird update (repair mode — the whole point of this repo)
Follow docs/migration-runbook.md. In short:
1. Re-extract the new omni.ja into refs/betterbird-extracted/.
2. Update refs/betterbird-version.txt (version, extracted date, previous).
3. RE-RUN CodeGraph — the index is stale and will serve old-DOM answers until
   you do. Stale index here is worse than none.
4. Diff old vs new extraction; update broken selectors in selector-map.md and
   components. Run docs/smoke-test.md.

## Scope
v1.0 = threadpane, folderpane, toolbar, tabs, messageheader, composer,
statusbar, plus the email body (userContent.css). **v1.0.0 is TAGGED**, so only
migration repairs are in scope unless the maintainer explicitly reopens it. Log
new ideas in docs/backlog.md / README roadmap, not into code.

Note on the roadmap: several future items (a `userChrome.js` behaviour layer for
things CSS can't do — e.g. quick-reply above the message body — an in-app
settings page, palette import, add-on packaging) would **relax the CSS-only hard
constraint**. Do NOT introduce any of these until the maintainer explicitly
reopens scope; until then the hard constraints above stand.