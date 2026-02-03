# AGENTS.md

## Purpose

AGENTS.md describes how to work in this repository for automated and human
contributors. All work must follow best practices and industry standards where
applicable.

## Scope

This document covers repository layout, scripts, commands, and documentation.
It does not define user-specific shell configuration outside the references in
the scripts (for example, `~/.bashrc`).

## Formatting Rules

- Limit lines to 80 characters.
- Allow exceptions only for URLs, code blocks, tables, hashes, or unbreakable
  commands. Call out exceptions inline.

## Quick Start

```bash
mkdir -p ~/Documents/github_repositories
git clone https://github.com/iop098321qwe/custom_bash_commands \
  ~/Documents/github_repositories/custom_bash_commands
cd ~/Documents/github_repositories/custom_bash_commands
./install_cbc.sh
```

## Environment

- Targets Debian/Ubuntu-based systems.
- Requires Bash (`custom_bash_commands.sh` and `cbc_aliases.sh` use bash).
- Optional: `gum` for styled output; the script falls back without it.
- Config variables set in `custom_bash_commands.sh`:
  - `CBC_CONFIG_DIR` (default `~/.config/cbc`)
  - `CBC_MODULE_ROOT` (default `~/.config/cbc/modules`)
  - `CBC_PACKAGE_MANIFEST` (default `~/.config/cbc/packages.toml`)
  - `CBC_MODULE_ENTRYPOINT` (default `cbc-module.sh`)

## Repository Overview

- `.github/` holds issue templates for GitHub.
- `docs/` holds dependency lists, SOPs, and the TODO backlog.
- Repository root holds the main scripts, installer, and branding assets.

## Tracked Files Overview

- `.github/ISSUE_TEMPLATE/bug_report.md`: GitHub bug report template.
- `.github/ISSUE_TEMPLATE/config.yml`: GitHub issue template settings.
- `.gitignore`: Git ignore rules (includes `node_modules/`).
- `AGENTS.md`: Contributor and automation instructions.
- `CHANGELOG.md`: Release history (managed outside this repository).
- `LICENSE`: License text.
- `README.md`: User-facing documentation.
- `cbc_aliases.sh`: Alias catalog sourced by the main script.
- `cbc_logo_00001.png`: CBC logo asset.
- `custom_bash_commands.sh`: Main entry point script.
- `docs/dependencies.md`: Baseline dependency list.
- `docs/standard_operating_procedures.md`: SOPs for changes.
- `docs/todo.md`: Outstanding work list.
- `install_cbc.sh`: Installer script for local setup.

## Architecture

- `custom_bash_commands.sh` is the main entry point. It defines UI helpers,
  command functions, and `updatecbc`, then sources `~/.cbc_aliases.sh`.
- `cbc_aliases.sh` defines aliases that the main script loads during startup.
- `install_cbc.sh` copies scripts into `~` and appends a sourcing line to
  `~/.bashrc` for automatic loading.
- `docs/` captures dependencies, SOP guidance, and open tasks.

## Commands

- `./install_cbc.sh`: Install the scripts into the home directory.
- `source ~/.custom_bash_commands.sh`: Load CBC after a manual copy.
- `cbcs` or `cbcs -a`: List available commands and extended descriptions.
- `updatecbc`: Pull the latest scripts via sparse checkout and reload them.
- `cbc pkg`: Manage CBC modules (see `custom_bash_commands.sh`).

## Testing

- No automated tests are tracked.
- Follow `docs/standard_operating_procedures.md` for manual test guidance.

## Linting and Formatting

- No linting or formatting tooling is documented.
- Verification needed: confirm if any lint/format commands exist outside this
  repository.

## CI and Release

- No CI workflows are tracked (no `.github/workflows/` directory).
- `custom_bash_commands.sh` documents release shortcuts `ver` and `verg` in
  the `cbcs` output that call `npx commit-and-tag-version`.
- Verification needed: confirm the official release process and whether `ver`
  or `verg` are wired to aliases in your shell setup.

## Conventions

- Follow `docs/standard_operating_procedures.md` when adding or modifying
  functions and aliases.
- Keep `cbcs` output in `custom_bash_commands.sh` aligned with new commands.
- Maintain `cbc_aliases.sh` as the alias catalog loaded by the main script.

## Security and Compliance

- Do not commit secrets, credentials, or private keys.
- Verification needed: no security or compliance policy is tracked.

## Dependencies and Services

- `docs/dependencies.md` lists required tools: zellij, zoxide, fzf, stacer,
  eza, neofetch, figlet, neovim, tldr, btop, brave-browser, vscode,
  python3, chezmoi, thefuck, fd, ripgrep, starship, ranger, lazygit,
  tree, obsidian.
- Optional dependency: `gum` for styled terminal UI.
- External service: GitHub is used by `updatecbc` for sparse checkout updates.

## Troubleshooting

- Installer path errors: `install_cbc.sh` requires the repo at
  `~/Documents/github_repositories/custom_bash_commands`.
- Duplicate sourcing lines: rerunning the installer appends another
  `source ~/.custom_bash_commands.sh` line to `~/.bashrc`.

## Refining Existing AGENTS.md

- Verify every statement against repository files or explicit user input.
- Remove stale, duplicated, or speculative guidance.
- Enforce the template section order and formatting rules.
- Replace vague statements with exact commands and file paths.
- Add "Verification needed" notes when information is not confirmed.
- Optimize for AI consumption with short, atomic bullets.

## Maintenance

- After any code or documentation change, re-check this file against the repo.
- Re-scan tracked files and update the file list immediately.
- Re-verify commands, paths, and workflows for accuracy.
- Update AGENTS.md to resolve mismatches without delay.
- Do not record change logs inside this file.
