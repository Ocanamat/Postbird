# migration-runbook.md — repairing postbird after a Betterbird update

The whole repo is optimised for this procedure. When Betterbird updates and
something looks wrong, work through this top to bottom. Budget: minutes, not
hours.

## 0. Confirm a migration is actually needed

- Deploy the current theme (`scripts/deploy.ps1`) and restart Betterbird.
- Run `docs/smoke-test.md`. If nothing is broken, stop — an update doesn't
  always move selectors.

## 1. Re-extract Betterbird's omni.ja → `refs/betterbird-extracted/`

The extracted CSS is the **only** trustworthy source for the current DOM.

1. Locate the install (see `CLAUDE.md`): `C:\Program Files\Betterbird\`.
2. `omni.ja` files live in the install root and `…\Betterbird\browser\`. They
   are ZIP archives. Extract into `refs/betterbird-extracted/` (overwrite),
   preserving the `chrome/…` layout the current tree already uses.
3. Update `refs/betterbird-version.txt`: set `version=`, `extracted=` (today),
   and leave `previous=` at the last **verified** version until the smoke test
   passes.

## 2. Re-index CodeGraph (BEFORE trusting any lookup)

The CodeGraph index is only valid for the version in `betterbird-version.txt`.
After re-extraction the index is stale.

- Re-run the CodeGraph indexer over the repo.
- Until it finishes, do lookups with `Grep` against
  `refs/betterbird-extracted/`, not CodeGraph.

## 3. Diff the extraction against the previous version

Focus on the files behind ported components (see selector-map's `path:line`):

- `chrome/messenger/skin/classic/messenger/shared/threadPane.css`
- `chrome/messenger/skin/classic/messenger/shared/threadCard.css`
- `chrome/messenger/skin/classic/messenger/shared/tree-listbox.css`
- `…/shared/messageHeader.css`, folder-tree / unifiedToolbar / tabmail CSS.

Look specifically for renamed **class names, ids, `data-properties` values, and
custom-property names** — those are what our selectors and token remaps hang
on. A useful signal: `git diff` the extraction directory between versions.

## 4. Update selector-map.md, then patch components

For each row in `docs/selector-map.md` whose BB140 selector changed:

1. Update the `BB140 selector` cell to the new `path:line` + selector.
2. Flip **Status** to `not-started`/`adapted` until re-verified.
3. Patch the matching rule in `chrome/postbird/components/<region>.css`.
   Every literal stays in `config.css`; you should only be editing selectors
   here, not values.

Order by definition-of-done priority: threadpane → folderpane → toolbar →
tabs → messageheader → composer → statusbar.

## 5. Redeploy, restart, smoke-test

- `scripts/deploy.ps1`, restart Betterbird.
- Run `docs/smoke-test.md`. Drop a fresh screenshot into
  `refs/screenshots-wip/` named `<component>-<YYYYMMDD>.png` and compare to
  `refs/postbox-target/`.
- When the smoke test passes, set `previous=` in `betterbird-version.txt` to
  the new version and commit.

## 6. If a selector has no replacement

If Betterbird removed the hook entirely (not just renamed it), mark the
selector-map row `blocked`, log it in `docs/backlog.md`, and note the last
version where it worked. Do **not** invent JS/add-on workarounds — this repo is
CSS-only by hard constraint.

## Live tuning

Exact values are tuned live in the Browser Toolbox Style Editor
(Ctrl+Shift+Alt+I) by the maintainer, then committed back into `config.css`.
Claude cannot see the rendered UI — it proposes diffs against screenshots and
never assumes a change "worked" until a screenshot confirms it.
