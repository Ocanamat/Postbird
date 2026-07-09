# Changelog

All notable changes to postbird. Versions track the definition of done in
`CLAUDE.md`; after v1.0, only migration repairs (Betterbird ESR bumps) are in
scope unless scope is explicitly re-opened.

## [Unreleased] — v1.1 (in progress)

- **Spaces toolbar** (`spacestoolbar.css`): light rail (`#E8E8E8`, matching the
  toolbar) with vertically-centred icons.
- **Folder pane**: hide the header Get Messages + New Message buttons (FP-12).
- **`scripts/configure-prefs.ps1`**: writes recommended Betterbird prefs to
  `user.js` — message-pane layout, Cards view, 2-line cards, and enabling
  userChrome. (Tooling, not part of the CSS theme.)

## [1.0.0] — 2026-07-09

First complete theme. Targets **Betterbird 140.12.0esr-bb24**. Recreates
Postbox's "Monterail Dark" look. All colours/sizes are `--pb-*` tokens in
`chrome/postbird/config.css`; every rule is mapped in `docs/selector-map.md`.

### Themed regions
- **Thread pane** — two-line card rows; warm-neutral text (`#4C4C4C` / slate
  `#5E6C79`); unread = bold only; pale-blue unread dot, vertically centred;
  per-account colour band (widened); flat list with hairline row dividers;
  solid-orange focused selection; smaller, centred sender gravatar (via the
  add-on's `.recipient-avatar`); chrome-grey header bar.
- **Folder pane** — dark charcoal sidebar (`#343430`) with light text; account
  icons carry their assigned colour (subfolders + unified root stay grey); no
  account-row wash; orange focused / muted-orange unfocused selection; orange
  unread pills (borderless, incl. collapsed accounts); compact rows; symmetric
  section spacing; divider toned into the pane; dark header bar.
- **Toolbar** — Monterail two-tone background; per-button flat icon tints;
  tighter icon-over-text buttons; menu bar matched.
- **Tabs** — active tab reads as chrome grey against a darker strip; inactive
  tabs recede; divider under the tab bar.
- **Message header** — chrome-grey band; message body as a floating white card
  on a grey frame (no divider line); "To" shown and bottom-aligned; smaller
  avatar.
- **Composer** — toolbars + header on the chrome band; menu bar matched;
  writing area as a card matching the reader.
- **Status bar** — thin chrome strip, top divider, muted text.
- **Email body** (`userContent.css`) — line-width cap on plain/flowed text
  (HTML mail untouched); `pre` wraps; muted accent quote border; faded
  signatures; accent selection.

### Known limitations (see `docs/backlog.md`)
- Colouring thread/header text *per account* isn't possible CSS-only (Betterbird
  applies the account colour as an inline background/border, not a token).
- Multi-hue toolbar icons would need asset replacement.
- Postbox's Focus Pane has no Betterbird equivalent.
