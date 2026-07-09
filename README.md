# postbird

A **Postbox-style theme for [Betterbird](https://www.betterbird.eu/)**, built
entirely with `userChrome.css` / `userContent.css` — no add-ons, no JS, no
autoconfig. It recreates the look and feel of the (discontinued) Postbox email
client, specifically its **"Monterail Dark"** theme: a light content area with
an orange accent and a dark charcoal folder pane.

> Targets **Betterbird 140.x ESR** (`140.12.0esr-bb24`). Betterbird 140 uses an
> HTML thread tree, so the selectors are written fresh against that DOM — they
> will also mostly apply to matching Thunderbird 140 ESR builds, but that isn't
> a support target.

## What it themes (v1.0)

Thread pane · folder pane · unified toolbar · tabs · message header · composer ·
status bar — plus the email **body** (via `userContent.css`). Highlights:

- Two-line "card" message rows, warm-neutral text, pale-blue unread dots, a
  per-account colour band, a solid-orange selection.
- Dark charcoal folder pane with account-coloured icons and orange unread pills.
- Two-tone toolbar with flat, functionally-coloured action icons.
- Reader **and** composer show the message as a floating white card on a grey
  frame (consistent read/compose look).
- Plain-text email readability (line-width cap, `pre` wrap, muted quotes).

## Requirements

- Betterbird 140.x.
- Pref `toolkit.legacyUserProfileCustomizations.stylesheets = true`
  (Settings → General → Config Editor).
- Thread pane in **Cards view** (View ▸ Layout ▸ Cards view).
- Optional: the *Auto Profile Picture* add-on for sender gravatars (postbird
  sizes/centres them if present, but doesn't require it).

## Install

```powershell
git clone <this-repo> postbird
cd postbird
./scripts/deploy.ps1        # auto-detects your Betterbird/Thunderbird profile
```

Then **restart Betterbird**. `deploy.ps1` copies `chrome/userChrome.css`,
`chrome/userContent.css`, and `chrome/postbird/` into your profile's `chrome/`
folder (it only touches files postbird owns). Pass `-ProfilePath` to override
auto-detection, or `-Link` to junction the folder for live editing.

To tune values, edit `chrome/postbird/config.css` (all colours/sizes are
`--pb-*` tokens there), redeploy, restart.

## Layout

```
chrome/
  userChrome.css              loader (UI shell)
  userContent.css             loader (email body)
  postbird/
    config.css                ALL design tokens (single source of truth)
    components/*.css           one file per UI region
    content/message-body.css   email body styling
docs/
  selector-map.md             the spine: Postbox rule → BB140 selector → status
  migration-runbook.md        how to repair after a Betterbird ESR bump
  smoke-test.md               post-deploy visual checklist
  backlog.md                  out-of-scope / blocked ideas
scripts/deploy.ps1
refs/                         LOCAL reference material — not published (see refs/README.md)
```

## Design goal: cheap repair

Betterbird ESR updates move selectors. postbird is optimised so a break is
findable in minutes: every rule maps to a row in
[`docs/selector-map.md`](docs/selector-map.md), and
[`docs/migration-runbook.md`](docs/migration-runbook.md) is the step-by-step fix
procedure. All literals live in `config.css`; components reference tokens only.

## Development

Branching model:

- **`main`** — the published GitHub branch (clean history, protected/default).
  Releases are tagged here (`v1.0.0`, …).
- **`feat/<name>`** — one branch per feature/fix, branched off `main`, merged
  back via PR. Keep commits scoped and reference the relevant `docs/` rows.
- **`master`** — the maintainer's *local-only* archive of the original,
  pre-release history (contains the bulky `refs/` material). **Not pushed.**

Everyday flow: `git switch -c feat/x` off `main` → edit `chrome/postbird/…` →
`./scripts/deploy.ps1` → restart → screenshot compare → update
`docs/selector-map.md` → PR into `main`. See `CLAUDE.md` / `AGENTS.md` for the
full working agreement.

## Roadmap / ideas (post-v1.0)

v1.0 is intentionally fixed-scope (see `CLAUDE.md`). These are future directions,
not commitments — and several would mean **moving beyond the current CSS-only
approach** (a userChrome theme can't show a settings UI or import files on its
own; that needs a real add-on / MailExtension).

- [ ] **`userChrome.js` behaviour layer** — via a userChromeJS loader, add
      things CSS can't do, e.g. a **quick-reply box above the message body** in
      the reader pane, or an account-name pill in the header. (Explicitly
      relaxes the current CSS-only constraint — a deliberate future direction.)
- [ ] **Package as a Thunderbird/Betterbird add-on** (MailExtension / theme)
      instead of a manual `userChrome` deploy.
- [ ] **Import external palettes** — generalise the token layer so Postbox colour
      themes (and formats like ColorSublime / themes.vscode.one) map onto
      `config.css` tokens.
- [ ] **In-app settings page** to switch themes and enable/disable postbird.
- [ ] **Per-mod toggles** (à la Obsidian *Style Settings*): enable/disable each
      mod, with custom colours / sizes / fonts.
- [ ] **Add-on-specific mods** listed with the same enable/disable +
      customisation controls (e.g. the gravatar tweaks).
- [ ] **Breaking-change checklist / detector** for Betterbird updates — a formal
      procedure building on `docs/migration-runbook.md`.

## Licence & credits

- postbird's CSS: **MIT** (see [`LICENSE`](LICENSE)).
- Betterbird / Thunderbird / Mozilla: the DOM and class names postbird targets
  are theirs (MPL-2.0). No Mozilla or Betterbird code is bundled here.
- Postbox / "Monterail Dark": design inspiration only. No Postbox code or assets
  are redistributed — colours were re-derived into tokens.
