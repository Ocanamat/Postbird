# refs/ — local reference material (NOT published)

Everything under `refs/` except this file and `betterbird-version.txt` is
**gitignored** on purpose. It's the maintainer's local working material and must
not go to a public repo — for privacy, copyright, and size reasons. To work on
postbird locally, repopulate these yourself:

| Folder | What it is | How to get it | Why it's not published |
|--------|-----------|---------------|------------------------|
| `betterbird-extracted/` | Betterbird's `omni.ja` unzipped — the **ground truth** for current DOM/selectors. | Unzip `omni.ja` from your Betterbird install (root + `browser/`) into this folder, preserving the `chrome/…` layout. | ~7.5k Mozilla MPL files; bloat + third-party. |
| `postbox-extracted/` | Postbox's `omni.ja` — reference for target values. | Unzip a Postbox install's `omni.ja` here. | Proprietary (Postbox). |
| `postbox-target/` | Target screenshots + the "Monterail Dark" theme CSS. | Your own Postbox screenshots / theme file. | Personal inbox data + proprietary theme. |
| `screenshots-wip/` | Deploy screenshots for the compare loop. | Drop `<component>-<date>.png` after each deploy. | Personal inbox data. |
| `community/` | Other people's userChrome projects, kept for reference. | Clone the ones you want. | Their code, their licences. |

`betterbird-version.txt` **is** published — it pins the Betterbird version the
selectors/CodeGraph index are valid for.

After re-extracting `betterbird-extracted/`, re-index CodeGraph before trusting
lookups (see `docs/migration-runbook.md`).

## Branching (why this material isn't on GitHub)

- **`main`** — the public GitHub branch. This `refs/` material is gitignored, so
  `main` never carries it.
- **`master`** — the maintainer's LOCAL-only archive of the original pre-release
  history, which *does* contain earlier snapshots of this material. It is **not
  pushed** — keep it local.
- **`feat/<name>`** — feature branches off `main` for ongoing work.

So: the heavy/private reference files live only on disk (and in the local
`master` history); the published `main` branch stays clean.

