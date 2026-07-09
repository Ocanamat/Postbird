# smoke-test.md — visual checklist after every deploy

Run this after `scripts/deploy.ps1` + a Betterbird restart. It's a fast "did
anything obviously break" pass, not pixel QA. Tick each; if one fails, see
`docs/migration-runbook.md`.

## Preconditions
- [x] Betterbird restarted after deploy (userChrome.css is read at startup only).
- [x] `toolkit.legacyUserProfileCustomizations.stylesheets = true` (one-time).
- [x] Thread pane is in **Cards view** (View ▸ Layout ▸ Cards view) — required
      for the threadpane rules to apply.

## threadpane (the ported component)
- [x] Message rows are **two lines**: sender + date on line 1, subject line 2.
- [x] Row background is near-white; rows are compact (~28px), not spaced out.
- [x] Sender is neutral dark-grey (`#4C4C4C`); subject/date slate (`#5E6C79`).
- [x] **Unread** rows differ by **weight only** (bold) — same colour as read.
- [x] Unread **dot** at the row start is **pale blue** (not green).
- [x] A thin grey hairline divides each row from the next.
- [x] Date is right-aligned and muted slate.
- [x] Sender avatars are slightly smaller (~25px) and still crisp.
- [x] The per-account colour band (left edge of the row) is a bit wider/clearer.
- [x] The unread dot AND the sender gravatar are vertically centred on the row.
- [ ] The gravatar has a little gap from the sender/subject text (not crowding).
- [x] Selected row (with the list focused) is a **solid orange** fill with
      **white** text.
- [x] Scrolling the list is smooth — no lag (perf regression check).

## folderpane (ported)
- [x] Folder pane background is **dark charcoal** (`#343430`) with light text.
- [x] Selected folder is **solid orange** when the pane is focused, muted
      orange when it isn't.
- [x] Unread-count badges are **orange-red pills** (`#dd491a`), white bold text.
- [ ] All-Folders account pills are solid pills (no outline border) — identical
      to the Favorite/Tags pills.
- [x] Subfolder icons are flat grey; ACCOUNT icons carry their account colour;
      the "Unified Folders" root icon is grey (not coloured/white).
- [x] Account rows have NO background/stripe wash — the colour is only on the
      icon (remove any personal userChrome account-bg rule if one lingers).
- [x] Folder rows are compact (not tall/spacious) and the names sit on one line.

## toolbar (ported: background + icon tints)
- [x] Main toolbar strip is light two-tone grey (not white).
- [x] Get Mail icon reads blue, Compose green, Delete red, Junk orange,
      Archive amber, Reply/Forward slate — each a flat tint (not multi-colour).
- [x] Icons are still legible against the grey toolbar; nudge `--pb-icon-*`
      tokens if any colour is too light/harsh.
- [x] Icon-over-text buttons sit close together (not spread out); labels not
      clipped. Nudge `--pb-toolbar-btn-padding` / `--pb-toolbar-label-size`.

## tabs (ported)
- [x] Active tab is the lighter chrome grey (like the message-header bg) and
      stands out against the darker tab strip.
- [x] Inactive tabs blend into the strip (they recede). Nudge
      `--pb-tab-inactive-bg` (strip + inactive) or `--pb-tab-active-bg` if the
      contrast is off.
- [x] Tab labels are legible dark text.

## messageheader (adapted — reading pane)
- [x] The From/Subject/Date header band is chrome grey (not white).
- [x] Subject is dark and readable; date is muted.
- [x] The message body floats as a white rounded card on a light-grey frame,
      with a wider bottom margin and comfortable side margins.
- [x] No thin divider line between the message header and the body (the grey
      frame is the only separation).

## folderpane spacing + divider
- [x] A section's last row clears the next section's divider (not cramped).
- [x] Section divider lines are a subtle dark tone that reads as part of the
      dark pane, not a bright contrasting rule.
- [x] The "To:" (sent-to) address shows in the compact header, bottom-aligned
      with the sender's email line (not floating up by the sender name).
- [x] Header avatar is slightly smaller (~24px) and still crisp.

## menu bar + folder-pane header
- [x] The menu bar (File Edit View …) matches the toolbar surface, in BOTH the
      main window and the compose window.
- [x] No white hairline at the very top of the folder pane (it's dark to the
      top edge, flush under the tab divider).

## composer (adapted — separate window)
- [x] Compose, headers, and format toolbars sit on the chrome grey band.
- [x] Subject field is a clean white input; message body is white.
- [x] The 3-pane window is unaffected (composer rules stayed scoped).
- [x] The writing area floats as a card (rounded, soft shadow, grey frame)
      matching the reader pane's message card.

## tabs divider + statusbar
- [x] A thin divider line sits under the tab bar, separating it from the
      thread-pane header (quick-filter row) and the message pane below.
- [x] Status bar is a thin chrome strip with a top divider and muted text.

## message body (userContent.css)
- [x] A plain-text email wraps at a comfortable width (not edge-to-edge).
- [x] An HTML newsletter is NOT squished/broken (its own layout intact).
- [x] Preformatted/code blocks wrap instead of scrolling sideways.
- [x] Quoted reply text has a muted accent left-border; signatures look faded.

## Regression sweep
- [x] All seven v1.0 regions are themed; nothing looks broken, blank, or
      invisible. (v1.0 component set is complete — remaining work is tuning.)
- [x] No missing/blank areas, no giant/zero-height rows, no invisible text
      (text-on-same-colour). Any of these = a broken selector or bad token.
- [x] Open a message, open the composer — neither window is visually mangled
      (composer rules are scoped but confirm no leakage).

## After the checklist
- [ ] Drop a screenshot into `refs/screenshots-wip/` as
      `threadpane-<YYYYMMDD>.png` for comparison against
      `refs/postbox-target/Screenshot_mainWindow.jpg`.
- [ ] Note any mismatch in the PR/commit so the next tuning pass has a target.
