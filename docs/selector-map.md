# selector-map.md — the project spine

This table is the **curated authority** for how each Postbox UI region maps onto
a current Betterbird selector, and how far the port has got. When a Betterbird
update breaks the theme, this is the first file you open (then
[migration-runbook.md](migration-runbook.md)).

- **Betterbird version this map targets:** `140.12.0esr-bb24`
  (see `refs/betterbird-version.txt`).
  ⚠️ The original brief said "Betterbird 128", but the extracted omni.ja and
  `CLAUDE.md` are both **140**. 140 replaced the XUL `<tree>` thread pane with an
  HTML `tree-view` custom element, so Postbox's `treechildren::-moz-tree-*`
  pseudo-elements **do not exist** here — selectors are written fresh against
  the HTML DOM.
- **Ground truth for BB selectors:** `refs/betterbird-extracted/` (its own CSS).
  Never trust training data for Thunderbird DOM.
- **Ground truth for Postbox colours:** `refs/postbox-target/MonterailDark_PostboxTheme.css`
  — the actual theme in the target screenshots ("Monterail Dark": light content,
  orange accent, dark charcoal folder-pane sidebar). Authoritative over pixel
  sampling. **Ground truth for Postbox metrics/weights:** `refs/postbox-extracted/`
  (gitignored).
- **Status legend:** `ported` (done, matches target) · `adapted` (working but
  a value/behaviour was substituted, needs verification) · `blocked` (no BB
  equivalent) · `not-started`.
- **⚠️ Cascade gotcha (read before debugging "my rule did nothing"):**
  `userChrome.css` is a **user-origin** stylesheet. Normal *author* declarations
  (Betterbird's omni.ja CSS) beat normal *user* declarations no matter the
  specificity — only user `!important` outranks author styles. So virtually
  every override in these components carries `!important`. If a newly added rule
  appears to have no effect, this is the first thing to check.

Column key: **Postbox source** and **BB140 selector** are `path:line` relative
to their `refs/` roots (`refs/postbox-extracted/…` and
`refs/betterbird-extracted/…` respectively).

---

## threadpane — message list (component: `chrome/postbird/components/threadpane.css`)

BB140 renders the two-line row in **Cards view** (`#threadTree[rows="thread-card"]`).
The user must have Cards view enabled (View ▸ Layout ▸ Cards view) for these
rules to apply; Table view is out of v1.0 scope (see TP-TABLE note).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| TP-01 | Surface + accent tokens | themes/default-light.css:22,31 | `chrome/messenger/skin/classic/messenger/shared/tree-listbox.css:71,122,127` (`--tree-pane-background`, `--tree-view-bg`, `--selected-item-color`) | ported | Remap BB card tokens instead of restyling each node. |
| TP-02 | Row density (~28px, 2-line) | mailWindow1.css:639,647 (`-moz-tree-row height:28px`) | `shared/threadCard.css:340` (`.thread-card-column`), `:343` gap | adapted | BB card height is content-driven; we tighten `gap`/`padding-block`. Verify against screenshot. |
| TP-03 | Line 1 sender | MonterailDark:38 (`--font-primary #4C4C4C`) | `shared/threadCard.css:432` (`.card-container .sender`) | ported | Colour authoritative from theme CSS. Read == unread colour. |
| TP-04 | Line 1 date | MonterailDark:40 (`--font-secondary #5E6C79`) | `shared/threadCard.css:438` (`.card-container .date`) | ported | Postbox uses secondary colour for date (mailWindow1.css:91). |
| TP-05 | Line 2 subject | MonterailDark:40 (`--font-secondary #5E6C79`) | `shared/threadCard.css:425` (`.card-container .subject`) | ported | Colour authoritative from theme CSS. |
| TP-06 | Unread text | MonterailDark (no unread colour) + mailWindow1.css:57 | `shared/threadCard.css:110` (`.card-layout[data-properties~="unread"] :is(.sender,.subject)`) | ported | Unread differs by **weight only** (700), same colour as read. |
| TP-07 | Unread dot | mailWindow1.css (message state icons) | `shared/threadCard.css:380` (`.read-status`), fill/stroke `:107` | ported | BB dot is green; recoloured to Postbox blue `--pb-unread-indicator`. |
| TP-08 | Selected + focused | MonterailDark:30,42 (`--selector #F07746`, `--font-primary-selected #F9FAFC`) | `shared/threadPane.css:216` + `shared/threadCard.css:47` (`.card-layout.selected`, `--tree-card-background-selected`) | ported | BB cards tint subtly; overridden to Postbox solid orange fill + `#F9FAFC` text. |
| TP-TABLE | Table-view unread colour | — | `shared/threadPane.css:207` (`--unread-color`) | adapted | Courtesy one-liner so Table-view unread rows aren't unstyled. Table view not a v1.0 target. |
| TP-09 | Header bar strip | MonterailDark:22 (`--bg-secondary`) | `#threadPaneHeaderBar` (about3Pane.xhtml:118, `.list-header-bar`) | ported | Chrome grey `#F0F0F0`. |
| TP-10 | Flat list + row divider | — (Postbox flat rich-row list) | `.card-layout > td` (`border:0` on `.card-container`, `border-bottom` on `td`) | ported | Removes BB card box; adds hairline `--pb-row-divider #E4E4E4` between rows. |
| TP-11 | Sender avatar size | — | `#threadTree { --recipient-avatar-size }` | ported | Round images injected by the "Auto Profile Picture" add-on, but it reuses `.recipient-avatar`, so the size token applies. |
| TP-14 | Centre gravatar | — | `#threadTree .recipient-avatar` (`margin-block:auto`) | ported | Add-on avatar (`div.recipient-avatar.has-avatar[data-auto-profile-picture-owner]`) centred vertically on the row. |
| TP-15 | Avatar column padding | — | `.card-container > .thread-card-column:first-child` (`padding-inline-end`) | ported | `--pb-card-avatar-gap` 3px so the gravatar doesn't crowd the text. |
| TP-12 | Account colour band width | — | `.card-layout > td` (`border-inline-start-width`) | ported | BB draws account colour as inline `border-left:5px rgba(…,0.2)` (thread-card.mjs:100); widened to 8px. Alpha is JS-fixed, not CSS-tunable. |
| TP-13 | Centre unread dot | — | `.card-container .read-status` (`margin-block:auto`) | ported | Vertically centres the dot over the row height. |

---

## folderpane — folder/account tree (component: `folderpane.css`)

Selectors verified in `folder-tree-row.mjs` (`.name`:70, `.icon`:71,
`.unread-count`:72) and adapted from the maintainer's live-tested userChrome
(`refs/community/2026Jul_userChrome.css`). Dark sidebar; `!important` required
to beat BB's folder-pane theming.

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| FP-01 | Pane surface (dark) | MonterailDark:23,39 (`--bg-sidebar`, `--font-primary-sidebar`) | `#folderPane` | ported | bg `#343430`, text `#F9FAFC`. |
| FP-02 | Folder / account name | MonterailDark:39 | `#folderTree li > div.container > span.name` | ported | |
| FP-03 | Selection (orange) | MonterailDark:30,32 (`--selector`, `--selector-inactive`) | `#folderTree:focus-within li.selected > div.container` / `li.selected:not(:focus-within) > div.container` | ported | Focused solid `#F07746`; unfocused `rgba(240,119,70,0.6)`. |
| FP-04 | Hover | MonterailDark:18 (`--favbar-button-hover`) | `#folderTree li:hover > div.container` | ported | `rgba(132,146,166,0.35)`. |
| FP-05 | Unread count badge | MonterailDark:51,54 (`--folder-bubble-bg/-text`) | `#folderTree li .unread-count` | ported | `#dd491a` filled pill, white text, `border:none`. The `border:none` cancels BB's outline badge for collapsed-with-unread-children folders (about3Pane.css:644), so All-Folders account pills match Favorite/Tags. |
| FP-06 | Folder + account icons | — (user-tuned) | grey: `li:not([data-server-type])`, `li[data-server-type="none"]`; colour: `li[data-server-type]:not([data-server-type="none"])` `> .container > .icon` | ported | Subfolders + smart/unified root (type "none") grey; real accounts keep assigned `--icon-color`. |
| FP-09 | Account row wash off | MonterailDark:23 | `#folderTree li[data-server-type]` | ported | BB paints the account colour as inline `background-color:rgba(…,0.2)` on the account `<li>` (native full-row-colour); user `!important` overrides it → pane bg. Colour stays on the icon; selection/hover paint `.container` so still show. |
| FP-10 | Section spacing | — | `#folderTree li[data-mode] > ul` (`padding-block-end`) | ported | Explicit `--pb-folder-section-gap` (10px) after a section's last folder so it isn't cramped against the next divider. (margin-bottom on the section was too subtle.) |
| FP-11 | Section divider colour | — | `#folderPane { --sidebar-border-color }` (about3Pane.css:471) | ported | Sidebar bg lightened ~18% (`--pb-sidebar-divider`) so the line belongs to the dark pane instead of contrasting. |
| FP-12 | Hide header buttons | — | `#folderPaneGetMessages`, `#folderPaneWriteMessage` (about3Pane.xhtml:69,75) | ported | `display:none` (v1.1). |
| FP-07 | Row density | — | `#folderPane` (`--list-item-min-height`, tree-listbox.css:8,772) + `.name` font | ported | Reduce large default 26px → `--pb-folder-row-height` 20px; name → `--pb-folder-name-size`. |
| FP-08 | White hairline at pane top | MonterailDark:23 | `#folderTree` (+ `.sidebar-panel-scroll::before/::after`, containers.css:27-48) + `#folderPaneHeaderBar` | ported | Pixel-measured 3px white strip at folder-tree top; force tree dark + neutralise scroll-shadow pseudo-elements. (Earlier `#folderPaneHeaderBar`-only fix missed it — that element is hidden.) |

## toolbar — unified toolbar (component: `toolbar.css`)

Ground truth: `…/shared/unifiedToolbar.css` + `unifiedToolbarShared.css`. Icons
render via `.button-icon { content: var(--icon-*) }` with
`-moz-context-properties: fill, stroke`, so a flat per-button tint is possible
CSS-only; multi-hue icon art is NOT (would need asset replacement).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| TB-01 | Toolbar background | MonterailDark:2,3 (`--toolbar-top/-bottom`) | `unified-toolbar`, `#unifiedToolbarContainer` | ported | Two-tone `#E8E8E8`→`#E0E0E0` gradient. |
| TB-02 | Button density | — | `.unified-toolbar .unified-toolbar-button` (`--button-padding`, label font) | ported | Packs icon-over-text buttons closer. Tokens `--pb-toolbar-btn-padding/-gap/-label-size`. Default `--button-padding` 6px (variables.css:34). |
| TB-03 | Menu bar | MonterailDark:2,3 | `#toolbar-menubar` (messenger.xhtml:3890) | ported | Same surface as toolbar. |
| TB-ICONS | Per-button icon tints | — (Postbox functional colour) | `.unified-toolbar .<action> .button-icon` (get-messages/write-message/reply*/archive/delete/junk) | adapted | Flat tints via `fill`/`stroke`. Colours are tunable `--pb-icon-*` tokens; verify on screenshot. |

## tabs — tab bar (component: `tabs.css`)

Ground truth `…/shared/tabmail.css` (`.tab-background[selected=true]`:311,315).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| TA-01 | Tab strip | — (chrome-derived) | `#tabmail-tabs` | ported | Set to the inactive-tab tone so the lighter active tab stands out (was chrome = same as active → invisible). |
| TA-02 | Inactive tab | — (chrome-derived) | `.tabmail-tab .tab-background:not([selected="true"])` | ported | Retuned off Monterail blue: desaturated step below chrome (`color-mix chrome 90% + grey`) so tabs don't stand out. `background-image:none` kills lwtheme paint. |
| TA-03 | Active tab | — (chrome-derived) | `.tabmail-tab[selected="true"] .tab-background`, `.tab-background[selected="true"]` | ported | Chrome grey `--pb-bg-chrome` (matches message-header bg); stands out against the darker strip without going white. |
| TA-04 | Tab label text | MonterailDark:38 | `.tabmail-tab .tab-content` | ported | `#4C4C4C`. |
| TA-05 | Divider under tab bar | — | `#tabmail-tabs` (messenger.xhtml:5455) | ported | `border-bottom` `--pb-chrome-divider`; separates tab bar from thread header + message pane. |

## messageheader — reading-pane header (component: `messageheader.css`)

Ground truth aboutMessage.xhtml:856 (`#messageHeader`, `#expandedsubjectBox`,
`#dateLabel`, `.message-header-row`).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| MH-01 | Header band | MonterailDark:22 | `#messageHeader` | adapted | Chrome grey `#F0F0F0` (matches maintainer userChrome). |
| MH-02 | Subject | MonterailDark:38 | `#messageHeader #expandedsubjectBox` | adapted | Primary ink `#4C4C4C`. |
| MH-03 | Date | MonterailDark:40 | `#messageHeader #dateLabel` | adapted | Muted `#5E6C79`. Verify; recipient-name colour TBD on screenshot. |
| MH-04 | Show "To" in compact header | — (Postbox) | `#messageHeader #expandedtoRow` | adapted | Force To visible + `align-self/items:flex-end` to bottom-align with the sender email line. Verify. |
| MH-05 | Header avatar size | — | `#messageHeader { --recipient-avatar-size }` (messageHeader.css:11, default 26px) | ported | Trimmed to `--pb-avatar-header-size` 24px (~8%). |
| MH-07 | Message "card" | refs/postbox-target/Screenshot_emailRead.jpg | `#messagepanebox` (grey frame) + `#messagepane` (margin/radius/shadow) — aboutMessage.xhtml:840,1873 | ported | Body floats as a white card. Margins: top 8 / sides 12 / bottom 18 (`--pb-msg-card-margin-*`), radius `--pb-msg-card-radius`. |
| MH-08 | Remove header/body line | refs/postbox-target/Screenshot_emailRead.jpg | `#header-splitter` (aboutMessage.xhtml:1452) | ported | Collapsed splitter rendered a 1px line between header and body; made transparent (card frame is the separator). |
| MH-06 | "To:" colon | — | (dropped) | n/a | Requested then discarded; plain "To" left as-is. Label is a XUL `<label value>` so `::after` can't attach anyway. |
| MH-PILL2 | Thread text by account colour | — | (none) | blocked | Colour sender/subject text per receiving account. BB applies account colour as an inline row `background-color`/`border-left` (thread-card.mjs:88,100 via `mail.server.<key>.color`), NOT a token — CSS can't reuse it for text. Native row-tint/left-border IS available. → backlog. |
| MH-PILL | Account-name colour pill | — | (none) | blocked | Receiving account name + colour not in header DOM; needs userChrome.js. → backlog. |

## composer — compose window (component: `composer.css`)

Ground truth messengercompose.xhtml (`#msgcomposeWindow`, `#composeToolbar2`,
`#MsgHeadersToolbar`, `#FormatToolbar`, `#msgSubject`). Scoped under
`#msgcomposeWindow` (separate window).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| CO-01 | Toolbars + header block | MonterailDark:22 | `#msgcomposeWindow :is(#composeToolbar2, #MsgHeadersToolbar, #FormatToolbar)` | adapted | Chrome band; body iframe left white. |
| CO-02 | Subject field | MonterailDark:21,38 | `#msgcomposeWindow #msgSubject` | adapted | White input, dark text. |
| CO-04 | Writing-area card | refs/postbox-target/Screenshot_writeEmail.jpg | `#msgcomposeWindow #messageArea` (frame) + `#messageEditor` (margin/radius/shadow) — messengercompose.xhtml:2841,2862 | ported | Mirrors reader MH-07 via shared `--pb-msg-card-*` tokens for a consistent read/compose look. |

## spacestoolbar — the left icon rail (component: `spacestoolbar.css`, v1.1)

Ground truth `…/shared/spacesToolbar.css`. `#spacesToolbar` (`.spaces-toolbar`)
is a fixed flex column, `justify-content: space-between`, bg `--spaces-bg-color`
(`light-dark(#e8e8e8,#252525)`).

| ID | UI element | Source | BB140 selector | Status | Notes |
|----|-----------|--------|----------------|--------|-------|
| ST-01 | Rail background | MonterailDark:2 | `#spacesToolbar { --spaces-bg-color }` | ported | Pinned light `--pb-spaces-bg` (#E8E8E8) regardless of OS light/dark. |
| ST-02 | Centre icons | — | `#spacesToolbar { justify-content }` | ported | `center` (default pins them top). |

## Recommended prefs (script, not CSS) — `scripts/configure-prefs.ps1`

Not selectors — Betterbird prefs postbird expects, written to `user.js`:

| Pref | Value | Meaning |
|------|-------|---------|
| `toolkit.legacyUserProfileCustomizations.stylesheets` | `true` | load userChrome/Content |
| `mail.pane_config.dynamic` | `5` | message-pane layout (0 Classic · 2 Vertical=right · 5 Horizontal=bottom) |
| `mail.threadpane.listview` | `0` | 0 Cards · 1 Table |
| `mail.threadpane.cardsview.rowcount` | `2` | 2-line cards (clamped 2–3, about3Pane.js:5051) |

## statusbar — status bar (component: `statusbar.css`)

Ground truth messenger.xhtml:7027 (`#status-bar.statusbar`, `#statusText`,
`.statusbarpanel`).

| ID | UI element | Postbox source rule | BB140 selector | Status | Notes |
|----|-----------|--------------------|----------------|--------|-------|
| SB-01 | Status strip | MonterailDark:22 | `#status-bar` | adapted | Chrome band + top divider `--pb-chrome-divider`, muted text. |
| SB-02 | Status text | MonterailDark:40 | `#status-bar :is(#statusText, .statusbarpanel)` | adapted | Muted `#5E6C79`. |

---

## message-body — email CONTENT (component: `chrome/postbird/content/message-body.css`, via `userContent.css`)

Content documents (the email body) are styled by `userContent.css`, NOT
userChrome. Selectors are Thunderbird body classes, not chrome DOM. HTML emails
are sender-designed, so readability rules target plain/flowed text only.

| ID | UI element | Source | Content selector | Status | Notes |
|----|-----------|--------|------------------|--------|-------|
| MB-01 | Plain-text width/spacing | BB userContent example | `.moz-text-plain, .moz-text-flowed` | ported | `max-width:100ch` + line-height + padding. **Not** `.moz-text-html` (would squish designed mail). |
| MB-02 | `<pre>` wrap | BB userContent example | `:is(.moz-text-plain,.moz-text-flowed,.moz-text-html) pre` | ported | `white-space:pre-wrap` — no horizontal scroll. |
| MB-03 | Quoted text | — (Postbox) | `blockquote[type="cite"]` | ported | Accent left border + muted colour. |
| MB-04 | Forwarded container | BB userContent example | `.moz-forward-container` | ported | Subtle left border (no debug colour). |
| MB-05 | Signature | — | `.moz-signature` | ported | Muted (opacity 0.6). |
| MB-06 | Selection colour | — (Postbox accent) | `::selection` | ported | Accent tint. |

## Blocked / out-of-scope (Postbox features with no BB equivalent)

| Postbox feature | Why blocked | Disposition |
|-----------------|-------------|-------------|
| Focus Pane (Attributes / Favorite Topics / Contacts — 2nd column in target shot) | No Betterbird equivalent UI; can't be recreated in CSS alone. | blocked → docs/backlog.md |
| Topics / colour-coded conversations | Postbox data model feature, not styling. | blocked → docs/backlog.md |

---

## Sampling log — and why colours now come from the theme CSS

Colours were originally pixel-sampled from
`refs/postbox-target/Screenshot_mainWindow.jpg` (1920×1050) via `System.Drawing`.
**Flat-fill samples were accurate; per-glyph text samples were NOT** — the
"darkest pixel" of anti-aliased text picked up **ClearType subpixel fringing**
(red/blue glyph-edge colour), which read as false warm red/brown. Once the user
supplied the real theme (`MonterailDark_PostboxTheme.css`), text colours were
corrected to the authoritative values and the `[SHOT]` text tokens were dropped.

| Token | Method | Sampled | Authoritative ([MTRL]) | Kept? |
|-------|--------|---------|------------------------|-------|
| `--pb-c-content-bg` | box avg 930,195 | `#FDFDFD` | `#fdfdfd` | ✓ matched |
| `--pb-c-selector` | box avg 115,481 | `#F07846` | `#F07746` | theme wins |
| `--pb-c-folder-badge` | most-sat 150,184 | `#EA580D` | `#dd491a` | theme wins |
| `--pb-c-font-primary` (sender) | darkest glyph | `#8E2420` ✗ ClearType | `#4C4C4C` | theme wins |
| `--pb-c-font-secondary` (subj/date) | darkest glyph | `#6A3230`/`#52585E` ✗ | `#5E6C79` | theme wins |
| `--pb-c-unread-dot` | most-sat 429,125 | `#4AB1FF` | (icon, not themed) | ✓ [SHOT] kept |

Lesson for future sampling: trust flat fills; for text, use the theme CSS, not
glyph pixels (ClearType poisons them).
