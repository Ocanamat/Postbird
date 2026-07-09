# backlog.md — out of v1.0 scope

v1.0 scope is fixed by explicit agreement (see `CLAUDE.md` → Definition of
done): threadpane, folderpane, toolbar, tabs, messageheader, composer,
statusbar — matching `refs/postbox-target/`. **Everything else lands here, not
in `chrome/`.** Do not expand scope; log ideas below.

## Blocked (no CSS-only path on Betterbird)
- **Focus Pane** — Postbox's 2nd column (Attributes / Favorite Topics /
  Favorite Contacts / Date filters), visible in the target main-window shot.
  No Betterbird equivalent element; cannot be recreated in CSS. Closest native
  feature is the Quick Filter bar, which is a different UX.
- **Topics & colour-coded conversations** — Postbox data-model features, not
  styling.

## Maintainer personal overrides (kept out of the theme by default)
These live in the maintainer's own userChrome (`refs/community/2026Jul_userChrome.css`)
and deviate from the Postbox Monterail target, so postbird does NOT apply them
by default. They're easy opt-ins:
- **Subject coloured by leading tag** — `#threadTree[rows="thread-card"]
  .card-container .subject { color: var(--tag-color); }`. Monterail renders the
  subject in secondary slate (`#5E6C79`, our TP-05 default); this recolours it
  per-tag instead. Flip in threadpane.css if desired.
- ~~Zero card border (list-like cards)~~ — FOLDED IN as threadpane TP-10
  (Postbox rich rows are a flat list; more faithful than BB's bordered cards).

## Nice-to-have (in-scope regions, deferred polish)
- Thread pane **read-state** colour verification — current read-row colours are
  Postbox `default-light` fallbacks; no read rows existed in the target sample.
  Verify/adjust when a screenshot with read rows is available (selector-map
  TP-03/TP-05).
- Thread pane **Table view** parity — v1.0 targets Cards view only. Table view
  currently gets a single unread-colour courtesy rule (TP-TABLE).
- **Dark theme** token set — Postbox ships `default-dark.css`; a `[data-theme]`
  / `prefers-color-scheme` variant of `config.css` could follow v1.0.
- Toolbar button **hover/pressed** states and icon recolouring to match
  Postbox's flat treatment.
- Account/folder **row icons** recolour to match Postbox iconography.

## Blocked — needs userChrome.js (CSS-only can't do it)
- **Colour thread-pane sender/subject text by receiving account** — Betterbird
  applies the account colour (`mail.server.<key>.color`) to the thread row as an
  inline `background-color` (full-row-colour on) or `border-left` (off), in
  `thread-card.mjs`/`thread-row.mjs`. It's an inline paint, not a CSS variable,
  so CSS can't reuse that colour for the text. Native alternatives that DO work
  without code: assign account colours (right-click account → choose colour) and
  Betterbird will draw a full-row tint or a 5px left border in the thread pane —
  the left border is the subtle, Postbox-like option.
- **Account-name colour pill in the message header** — show the RECEIVING
  account's name (Main / Personal / Work-MS …) as a pill tinted with that
  account's colour, before the date. Blocked: BB140 renders neither the account
  name nor an `account-color` CSS variable into the message-header DOM (verified
  — no `account-color` anywhere in `chrome/messenger`; `msgHdrView.js` uses the
  identity only for compose). CSS can't inject dynamic text or read the colour,
  so this needs `userChrome.js` — forbidden by the CSS-only hard constraint.
  (Folder-pane account colours DO exist via `setIconColor`, but that's the tree,
  not the header.)

## Add-on interop (resolved, noted for repair)
- **Thread-pane gravatar** — injected by the "Auto Profile Picture" add-on as
  `div.recipient-avatar.has-avatar[data-auto-profile-picture-owner]`. It reuses
  the standard `.recipient-avatar` class, so postbird sizes (TP-11) and centres
  (TP-14) it via that class. If a future add-on/version renames the class, those
  two rules are where to look.

## Blocked — needs asset replacement (CSS-only can't do it)
- **Multi-hue toolbar icons** — Postbox's toolbar glyphs are multi-colour.
  Betterbird's are monochrome line icons (`-moz-context-properties`), so we can
  flat-tint each button one colour (done: TB-ICONS) but not reproduce two-tone
  art without swapping the SVG assets. Authoring fresh `data:` URI SVG icons is
  possible in principle but heavy and borderline hard-constraint; deferred.

## Rejected / won't-do
- Any add-on, `userChrome.js` loader, or autoconfig approach — hard constraint,
  CSS only.
