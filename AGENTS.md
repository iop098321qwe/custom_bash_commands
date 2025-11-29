# Custom Bash Commands – Agent Handbook

## Purpose

This handbook keeps automated contributors aligned with the expectations of the
`custom_bash_commands` project. Use it to understand how the scripts are wired
together, which conventions are non-negotiable, and what must be updated when
you touch the codebase. Update this file and `README.md` in every change set so
they describe both the current state of the repository and the changes you are
introducing.

---

## Repository orientation

| Path | Notes |
| --- | --- |
| `custom_bash_commands.sh` | Main entry point. Owns gum-aware styling helpers,
  onboarding tasks (`setup_directories`, `check_cbc_update`, `display_info`), the
  feature catalog (`cbcs`), and the sparse-checkout updater (`updatecbc`). |
| `cbc_aliases.sh` | Alias catalog sourced by the main script. Provides fuzzy
  navigation, Git helpers, media launchers, and release automation shortcuts
  (e.g., `ver`). Keep this file as the single source of truth for aliases. |
| `install_cbc.sh` | Installer that validates the repository path, copies the
  main script and aliases into the home directory, appends sourcing lines to
  `.bashrc`, and reloads the shell. Use this when you need a fast local setup. |
| `docs/` | Supporting references: dependency list, SOPs for adding functions or
  aliases, and the current TODO backlog. Keep these synchronized with any
  behaviour changes you introduce. |
| `node_modules/` | Vendored release tooling (`npx commit-and-tag-version`). Do
  not add packages unless you are intentionally changing the release workflow. |
| `CHANGELOG.md` & `cbc_logo_00001.png` | Human-readable release history and
  branding assets referenced by the CLI and README. |
| Missing/expected externals | `.version` and `update_commands.sh` are not
  tracked. Document any reliance on them in `README.md` and this handbook. |

---

## Runtime behaviour to preserve

- Gum detection must stay at the top of the main script so every helper can
  degrade cleanly when gum is absent.
- `setup_directories` creates the Temporary workspace (with screenshot and
  recording folders), `~/Documents/github_repositories`, and the
  `~/Documents/grymms_grimoires` vault before the rest of CBC loads.
- `check_cbc_update` polls the GitHub Releases API with cached intervals. It
  should remain silent unless a newer tag is found or the cache has expired.
- `display_info` runs automatically after the script is sourced and should keep
  pointing users at `cbcs`, `changes`, and removal instructions. The banner must
  stay accurate when features move.
- `cbcs` is the discoverability hub. Whenever you add a function or alias,
  update both the brief list and the `-a` detail output, plus any alias rows in
  `cbc_aliases.sh`.
- `cbc pkg` now writes `[[module.deps]]` entries (`use`, `rev`, `hash`) to
  `~/.config/cbc/packages.toml`. `install` must append new modules without
  clearing earlier entries, `load` syncs modules into `modules/` while
  refreshing the recorded fields, `update` should show a spinner per module
  while performing a single fetch before fast-forwarding, summarize results
  under `Updated Modules` and `Skipped Modules` headers with one module per
  line, `uninstall` removes entries while deleting local module directories,
  and the post-update auto-load must remain intact. Keep the manifest parser
  tolerant of spacing and quoted values.
- `cbc pkg list` should summarize modules with last-updated timestamps and a
  concise status (`Current` or `UPDATE AVAILABLE`) without surfacing module
  entrypoints.
- `updatecbc` performs a sparse checkout of the repository, presenting a gum
  confirmation (with a plain fallback) before pulling the latest copy of the
  main script and `cbc_aliases.sh`, overwriting the home-directory versions, and
  sourcing the result. Preserve its temporary-directory hygiene, spinner
  feedback, and cleanup flow.

---

## Implementation conventions

1. **Gum helpers** – Use `cbc_style_box`, `cbc_style_message`, `cbc_style_note`,
   `cbc_confirm`, `cbc_input`, and `cbc_spinner` for user-facing output,
   confirmations, prompts, and long-running operations. These wrappers already
   downgrade to `printf`/`read` when gum is unavailable.
2. **Help flags & `OPTIND`** – Every function callable from the CLI must offer a
   `-h`/`--help` path implemented with `getopts` and reset `OPTIND=1` at the
   start. Follow the formatting used by `batchopen`, `repeat`, `smartsort`, and
   `regex_help` to stay consistent.
3. **Interactive input** – Prefer `fzf` selectors and gum confirmations when
   collecting user choices. Ensure the scripts still behave sensibly if `fzf` or
   gum are missing.
4. **Alias management** – Add or adjust aliases only in `cbc_aliases.sh`. Group
   related aliases together, retain safe defaults (`cp -i`, `rm -I`), and make
   sure any alias with custom behaviour is documented in `cbcs -a` and the
   README.
5. **Documentation sync** – When behaviour or dependencies change, update this
  handbook and `README.md` in the same change set, capturing both the new
  behaviour and any prior changes that need to remain discoverable. Refresh
  other references (`docs/dependencies.md`, `docs/standard_operating_procedures.
  md`, `docs/todo.md`) as needed to keep them aligned.
6. **Release metadata** – If you modify the release process or `updatecbc`,
   verify the sparse checkout still copies `.version` and that the `ver`/`verg`
   aliases in `cbc_aliases.sh` remain accurate.
7. **Non-repo support files** – `update_commands.sh` and `.version` are not
  tracked. If your change depends on them existing or changing, document the
  expectation in README/AGENTS and avoid committing private copies.

---

## Documentation maintenance

- Treat `README.md` and this handbook as paired sources of truth. Every update
  must adjust both files to reflect the current repository contents, the new
  behaviour you introduced, and any earlier changes that should stay visible to
  future contributors.
- Keep tables and setup instructions in sync with the actual files present
  (e.g., `install_cbc.sh` is the current installer; provisioning helpers such as
  `new_update_commands.sh` are absent). If those files return, immediately
  revise both documents.
- Summarize documentation edits in the PR body so reviewers can verify the
  narrative matches the code.

---

## Testing expectations

- There is no automated CI. Manually exercise any function or alias you touch,
  including its help flag, gum/no-gum paths, and destructive operations.
- Record manual test steps in the final response and the PR description. Shell
  transcripts are preferred when demonstrating behaviour.
- If you introduce new functionality that merits scripted tests, stage those in
  a separate helper or document the manual checklist under `docs/`.

---

## Contribution workflow

1. **Branching** – Work on dedicated feature branches. Do not commit directly to
   `main`.
2. **Commit messages** – Follow Conventional Commits:
   `<type>(<optional scope>): <description>` (e.g., `feat(cbcs): add wiki link`).
   Apply the same convention to PR titles.
3. **Pull requests** – Titles should also follow Conventional Commit style.
   Summaries must include motivation, user-facing behaviour changes, tests run,
   and documentation updates (including this handbook and `README.md`). Keep the
   PR body in lockstep with the current diff: rewrite the summary whenever new
   commits land before merge so reviewers always see a complete, detailed
   accounting of the latest changes.
4. **Changelog** – Do not modify `CHANGELOG.md`; it is auto-generated outside
   this repository.
5. **Version bumps** – If you change the `VERSION` constant in the main script,
   ensure `.version`, release automation, and docs reflect the same number.
6. **make_pr** – After committing, call the provided `make_pr` tool with an
   accurate title and body summarizing your work and tests.

---

## Markdown authoring standards

- Wrap Markdown text at 80 characters. The following exceptions may exceed the
  limit for clarity:
  - Tables, including the repository orientation table in this handbook.
  - URLs that would lose meaning if broken up.
  - Code fences where formatting requires longer lines.
- Use sequential heading levels (e.g., `##` → `###`) and sentence case titles.
- Annotate code examples with language fences (```` ```bash ````) when
  applicable.
- Maintain parallel structure in lists, preferring ordered lists for sequential
  tasks.
- Treat the README as the canonical user manual: update prerequisites,
  installation steps, usage instructions, and troubleshooting notes whenever you
  change behaviour.

---

## Pre-flight checklist

- [ ] Gum helpers used for all user-facing interactions.
- [ ] Functions and aliases expose `-h` help and reset `OPTIND`.
- [ ] `cbcs` and `cbc_aliases.sh` updated for any new or removed items.
- [ ] `README.md` and this handbook refreshed to reflect the current state and
      the changes introduced.
- [ ] Manual tests executed and captured for the final report.
- [ ] Dependencies and documentation refreshed as needed.
- [ ] Conventional Commit message prepared and `make_pr` planned after commit.

Following this playbook keeps CBC maintainable for both humans and automation.
