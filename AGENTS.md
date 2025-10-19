# Custom Bash Commands – Agent Handbook

## Purpose of this document This `AGENTS.md` file is the canonical source of

truth for automated contributors that operate on the `custom_bash_commands`
repository. It provides:

- Project orientation and the relationships between the key scripts.
- Implementation notes that are critical for keeping behaviour consistent
  (especially around interactive gum usage, CLI `-h` help flows, and
  alias/function discovery).
- Required conventions for commits, pull requests, testing, and documentation
  updates.

> **Always keep this file accurate.** If you touch any code, documentation, or
> assets that are described here (or if you add new functionality that should
> be referenced), update this document in the same change set.

---

## Repository layout (high level)

| Path | Purpose | | --- | --- | | `custom_bash_commands.sh` | Main entry
point. Defines helper styling utilities, loads modules/aliases, and implements
most interactive functions. | | `cbc_aliases.sh` | Sourced from the main
script. Holds the bulk alias catalogue so aliases stay modular. | |
`pron-module.sh` | Prototype module for separating “pron” functions. Ships with
the same gum helpers as the main script so it can be sourced independently. | |
`new_update_commands.sh` | Provisioning helper that copies scripts/configs into
`~`, ensures directories exist, updates `.bashrc`, and refreshes the shell. | |
`docs/` | Markdown references (`dependencies.md`,
`standard_operating_procedures.md`, `todo.md`). Keep these aligned with script
behaviour. | | `managed_context/` | Stores Managed Context metadata for
previous AI sessions. Usually no runtime impact but review when behaviour
tracking changes. | | `node_modules/` | Only used for release automation
utilities (e.g., `commit-and-tag-version`). Do **not** check in new
dependencies without need. |

### Key runtime flow

1. `custom_bash_commands.sh` exports color constants and evaluates whether
   [Charmbracelet gum](https://github.com/charmbracelet/gum) is available
   (`CBC_HAS_GUM`).
2. Helper wrappers (`cbc_style_box`, `cbc_style_message`, `cbc_style_note`,
   `cbc_confirm`, `cbc_input`, `cbc_spinner`) render styled output when gum is
   present and fall back to POSIX `printf`/`read`/direct command execution
   otherwise.
3. Feature functions (batch file openers, pron utilities, sorters, wiki
   shortcuts, etc.) use the helper wrappers for consistent UX and define `usage()`
   blocks triggered by the `-h` flag via `getopts`.
4. The script sources `cbc_aliases.sh` near the end, appends itself to
   `~/.bashrc` through `append_to_bashrc`, and exposes helper commands like
   `repeat`, `smart_sort`, `wiki`, and `changes`.

---

## Implementation conventions

### 0. Industry standards & best practices

- **Adhere to widely accepted industry standards across all languages and
  artifacts in this repository.** Follow shell scripting best practices
  (POSIX-compatible Bash, defensive quoting, lint-friendly structure), ensure
  documentation aligns with established technical writing guides, and model
  automation or infrastructure changes after reputable sources (e.g., GNU,
  Linux Foundation, Write the Docs). When unsure, reference authoritative style
  guides or upstream project recommendations so that every change reflects
  professional-quality craftsmanship.

### 1. Gum-aware UX

- **Always use the `cbc_style_*`, `cbc_confirm`, `cbc_input`, and `cbc_spinner`
  helpers** for user-facing output, confirmation prompts, and loading indicators.
  They automatically downgrade gracefully when gum is absent.
- When adding helpers outside the main script (e.g., modules), mirror the
  defensive pattern from `pron-module.sh`: only declare helpers if they are
  undefined so double-sourcing does not override shared implementations.
- color constants follow the Catppuccin Mocha palette; new helpers should
  reference the same naming scheme to stay consistent.

### 2. Command-line ergonomics

- Each function exposed to users **must implement a `-h` flag** (via `getopts`)
  that prints a `usage()` section using `cbc_style_box`. Follow the structure
  seen in `batchopen`, `phopen`, `phsearch`, `pronlist`, `repeat`, `smart_sort`,
  etc.
- Default argument parsing should reset `OPTIND=1` at the start of every
  function to support re-entrancy.
- For functions that accept interactive input, prefer `fzf` selectors (already
  used for file picking) and show help text describing the selection behaviour.
- Where confirmation is required (overwriting files, launching browsers), call
  `cbc_confirm` and provide a cancellation path.

### 3. Alias management

- `cbc_aliases.sh` houses all alias declarations. New aliases must:
  - Be grouped with related aliases to maintain readability.
  - Prefer `fzf`-driven selectors for discoverability.
  - Avoid overriding core GNU utilities unless the alias is intentionally
    protective (`cp -i`, `mv -i`, etc.).
- Any function or alias surfaced via `cbcs` or the wiki must be documented in
  both `cbc_aliases.sh` and the wiki/README sections referencing it.

### 4. Module system (e.g., pron-module)

- Modules should be sourceable without the main script. Use the guard patterns
  from `pron-module.sh` to define gum helpers only when missing.
- Keep duplicated logic between `custom_bash_commands.sh` and modules in sync.
  When refactoring, consolidate shared code and update this file plus
  `docs/standard_operating_procedures.md` accordingly.
- `pron-module.sh` currently mirrors `pronlist`. If you expand it (e.g., to
  relocate `phopen` or `phsearch`), ensure the main script either sources the
  module or removes duplicate definitions to avoid drift.

### 5. Update workflow

- `new_update_commands.sh` bootstraps the environment by copying scripts to the
  home directory, creating expected folders (`~/Documents/update_logs`,
  `~/Documents/github_repositories`, `~/Documents/ai`, `~/temporary`), and
  appending sourcing statements to `~/.bashrc` before refreshing the shell. Keep
  this logic idempotent—reruns should not create duplicate lines or break
  existing setups.
- A complementary `update_commands.sh` lives in users’ home directories (not
  in-repo). When updating core scripts, verify `new_update_commands.sh` still
  references the correct filenames and update the instructions in `README.md` if
  the bootstrap flow changes.

### 6. Dependency expectations

- CLI dependencies listed in `docs/dependencies.md` include: `zellij`,
  `zoxide`, `fzf`, `stacer`, `eza`, `neofetch`, `figlet`, `neovim`, `tldr`,
  `btop`, `brave-browser`, `vscode`, `python3`, `chezmoi`, `thefuck`, `fd`,
  `ripgrep`, `starship`, `ranger`, `lazygit`, `tree`, and `obsidian`.
- Browser-opening functions fall back through `brave-browser`, `xdg-open`, and
  macOS `open`. Ensure new launchers follow this pattern and handle the absence
  of all options gracefully.
- Media/download features rely on `yt-dlp`, clipboard tools (`xclip`), and
  `gum`. If you add dependencies, register them in `docs/dependencies.md`,
  `README.md`, and this file.

---

## Testing & validation expectations

- There is no automated CI. When modifying scripts, manually test the affected
  functions—especially `-h` paths, gum-present/gum-absent scenarios, and
  destructive actions such as file deletion or overwriting.
- Document manual test steps in your PR description and final message. Prefer
  shell transcripts demonstrating the command output when possible.
- If adding functionality that can be unit-tested, include inline test helpers
  or document a manual testing checklist under `docs/`.

---

## Contribution workflow requirements

1. **Branching** – Work on feature branches. Keep the main branch clean.
2. **Commit messages** – Follow [Conventional
   Commits](https://www.conventionalcommits.org/) strictly. Format:
   `<type>(<optional scope>): <description>` (e.g., `feat(batchopen): add
--dry-run flag`). Use meaningful scopes referencing affected functions or
   areas.
3. **Pull requests** – Titles must also follow Conventional Commit style (e.g.,
   `feat: describe overall change`). Summaries should cover:
   - Motivation and the user-facing behaviour change.
   - Testing performed (including gum/no-gum cases when relevant).
   - Documentation updates (remember: **update this `AGENTS.md` whenever
     referenced behaviour changes**).
4. **Changelog** – If the change impacts end users, update `CHANGELOG.md` using
   the existing structure. Align the version bump with the `VERSION` string in
   `custom_bash_commands.sh` and any release tooling (e.g., `.versionrc`).
5. **Version coordination** – When modifying the `VERSION` constant, ensure
   related scripts (`.version`, release automation) and docs mention the correct
   release number.

### 7. Markdown authoring standards

- **Wrap Markdown text at 80 characters.** Line wrapping keeps diffs concise
  and predictable for reviewers and future automation. Exceptions are allowed
  for tables, URLs, code blocks, or other structures where wrapping would harm
  readability or functionality. This mirrors the widely adopted [MD013
  guideline][md013], so following it keeps the docs compatible with industry
  tooling.
- Prefer semantic heading levels that progress by one level at a time. Avoid
  skipping from `##` to `####`, and keep heading text sentence case for
  consistency with common technical documentation styles.
- Use fenced code blocks with language hints (e.g., ```` ```bash ````) whenever
  commands or configuration snippets are documented so that downstream tooling
  can enable syntax highlighting.
- Lists should be sentence cased, use parallel grammar, and keep ordered lists
  for sequential tasks. This matches guidance from the Microsoft Writing Style
  Guide and improves readability.
- Whenever code changes introduce new behaviour, configuration steps, or other
  user-facing adjustments, review `README.md` and expand it with the relevant
  details. This includes usage instructions, dependency notes, screenshots, or
  any other information that helps users understand the update. Treat the
  README as the canonical user manual and update it in the same commit when the
  change warrants documentation. Follow "Keep a Changelog" style summaries so
  release notes and README guidance stay aligned.
- README updates should follow docs-as-code best practices: include a brief
  feature summary, prerequisites, installation or upgrade steps, usage
  walkthroughs, and troubleshooting tips when applicable. Model the structure
  after Write the Docs guidance so changes remain actionable for end users.

[md013]: https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md#md013

---

## Authoring guidelines for AI agents

- **Respect shell compatibility** – Target POSIX-compliant bash (no
  zsh-specific constructs). Reset `OPTIND`, quote variables, and guard against
  word splitting.
- **Security and privacy** – Never leak sensitive filesystem paths beyond what
  is already codified in this repository. Prompt users before deleting or
  overwriting files.
- **Idempotency** – Scripts should be safe to re-run. For file mutations (like
  updating `~/.bashrc`), check existing entries first.
- **Discoverability** – Whenever you add a new function or alias, ensure it
  appears in:
  - The `cbcs` help output (update its help table in
    `custom_bash_commands.sh`).
  - `README.md` / wiki references, if the feature is user-facing.
  - `docs/standard_operating_procedures.md` if the creation workflow changes.
  - This `AGENTS.md` file with a short description so future agents understand
    the feature.

---

## When to update this file

Update `AGENTS.md` **in the same commit** whenever you:

- Add, remove, or significantly modify functions, aliases, helper utilities,
  color palettes, or gum-handling behaviour.
- Change dependency requirements, CLI flags, help text formats, or default
  flows (e.g., new confirmation logic, altered bootstrap steps).
- Touch documentation that agents rely on (`README.md`, `docs/`, wiki
  references), since this file cross-links those resources.
- Adjust contribution practices (commit rules, testing expectations, release
  flow).

If you are unsure whether a change impacts these instructions, err on the side
of updating the document.

---

## Quick-reference checklist before submitting work

- [ ] Code follows the gum helper conventions and provides `-h` usage blocks.
- [ ] Aliases/functions updated in both the script and documentation.
- [ ] Manual tests executed and recorded.
- [ ] Dependencies documented.
- [ ] Conventional Commit message prepared.
- [ ] `AGENTS.md` reviewed/updated to remain accurate.

Following this checklist keeps the automation-friendly workflow reliable for
future contributors.
