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

- Requires a Linux environment with `xdg-open`, `setsid`, and `wl-copy`
  available (scripts call these directly).
- Requires Bash (`custom_bash_commands.sh` and `cbc_aliases.sh` use bash).
- Requires Python 3.10 or newer for Zensical documentation builds.
- Zensical is pinned in `requirements-docs.txt` for documentation builds.
- Config variables set in `custom_bash_commands.sh`:
  - `CBC_CONFIG_DIR` (default `~/.config/cbc`)
  - `CBC_CONFIG_FILE` (default `~/.config/cbc/cbc.config`)
  - `CBC_MODULE_ROOT` (default `~/.config/cbc/modules`)
  - `CBC_PACKAGE_MANIFEST` (default `~/.config/cbc/packages.toml`)
  - `CBC_MODULE_ENTRYPOINT` (default `cbc-module.sh`)
  - `CBC_USE_GUM` (default `auto`)
  - `CBC_OMARCHY_COLORS_FILE` (default
    `~/.config/omarchy/current/theme/colors.toml`)

## Repository Overview

- `.github/` holds issue templates and the GitHub Pages workflow.
- `docs/commands/` holds command reference pages.
- `docs/operations/` holds SOP guidance.
- `docs/repository_docs/` holds documentation-site symlinks to root docs.
- `docs/` holds dependencies, command references, and root doc symlinks.
- Repository root holds scripts, docs config, installer, and branding assets.

## Tracked Files Overview

- `.github/ISSUE_TEMPLATE/bug_report.md`: GitHub bug report template.
- `.github/ISSUE_TEMPLATE/config.yml`: GitHub issue template settings.
- `.github/workflows/docs.yml`: GitHub Pages documentation workflow.
- `.gitignore`: Git ignore rules for local and generated files.
- `AGENTS.md`: Contributor and automation instructions.
- `CHANGELOG.md`: Release history (managed outside this repository).
- `LICENSE`: License text.
- `README.md`: User-facing documentation.
- `cbc_aliases.sh`: Alias catalog sourced by the main script.
- `cbc_logo_00001.png`: CBC logo asset.
- `custom_bash_commands.sh`: Main entry point script.
- `docs/LICENSE`: Symlink to the root license.
- `docs/README.md`: Symlink to the root README.
- `docs/commands/command_changes.md`: Reference page for `changes`.
- `docs/commands/command_display_version.md`: Reference page for
  `display_version`.
- `docs/commands/command_readme.md`: Reference page for `readme`.
- `docs/commands/command_releases.md`: Reference page for `releases`.
- `docs/commands/command_wiki.md`: Reference page for `wiki`.
- `docs/dependencies.md`: Dependency list for CBC usage and docs builds.
- `docs/operations/standard_operating_procedures.md`: SOPs for changes.
- `docs/repository_docs/AGENTS.md`: Symlink to root agent instructions.
- `docs/repository_docs/CHANGELOG.md`: Symlink to the root changelog.
- `done.txt`: Completed todo.txt task entries.
- `inbox.txt.tuxedo-lock`: Empty todo.txt lock file.
- `install_cbc.sh`: Installer script for local setup.
- `requirements-docs.txt`: Pinned Zensical dependency list.
- `todo.txt`: Open todo.txt task entries.
- `zensical.toml`: Zensical documentation site configuration.

## Architecture

- `custom_bash_commands.sh` is the main entry point. It defines UI helpers,
  command functions, and update helpers. It loads
  `~/.config/cbc/cbc.config` when present, then sources `~/.cbc_aliases.sh`
  if present and warns when missing. It uses `curl` with
  `--connect-timeout 10` and `--max-time 30` for update checks. Gum usage is
  controlled by `CBC_USE_GUM` (`auto`, `true`, or `false`). Gum helpers read
  Omarchy colors from `~/.config/omarchy/current/theme/colors.toml` when
  present and fall back to plain-text output when gum is inactive. It parses
  JSON with `awk` and `sed` for update checks. Package list and update outputs
  use gum tables when active and plain aligned tables otherwise. Startup
  sources installed module entrypoints from `~/.config/cbc/modules`; manifest
  alignment runs only when users call `cbc pkg load` or related package
  commands.
- `cbc_aliases.sh` defines aliases that the main script loads during startup.
- `install_cbc.sh` copies scripts into `~`, appends a sourcing block to
  `~/.bashrc` when missing, and creates common directories under
  `~/Documents/Temporary` and
  `~/Documents/github_repositories`.
- `docs/` captures command references, SOP guidance, repository docs, and
  dependency guidance.
- `zensical.toml` configures the documentation site with `docs/` as source
  and `site/` as generated output.

## Commands

- `./install_cbc.sh`: Install the scripts into the home directory.
- `source ~/.custom_bash_commands.sh`: Load CBC after a manual copy.
- `cbc list` or `cbc list -v`: List available commands and descriptions.
- `cbc config [-f]`: Write the CBC config file to
  `~/.config/cbc/cbc.config`.
- `cbc config edit [--reset]` or `cbc config -e [--reset]`: Open the
  CBC config file in an editor, writing defaults when missing or
  resetting.
- `cbc doctor`: Run diagnostics for config, dependencies, modules, and update
  access.
- `cbc doctor startup`: Profile CBC startup timing and print troubleshooting
  hints.
- `cbc update check`: Query the latest GitHub release and report the current
  and latest versions plus the release link.
- `cbc update`: Pull the latest scripts via sparse checkout and reload them.
- `cbc pkg`: Manage CBC modules (subcommands support `-h`).
- `cbc pkg install <creator/repo|git-url|path>`: Record a module source.
- `cbc pkg list`: Show module status and last update dates in a table.
- `cbc pkg load`: Install missing manifest modules, refresh metadata, and
  source installed module entrypoints.
- `cbc pkg uninstall <creator/repo|module-name>`: Remove a module.
- `cbc pkg update`: Fast-forward modules and show results in a table.
- `cbc test`: Reload CBC scripts from the current repository root.
- `python3 -m venv .venv`: Create the docs virtual environment.
- `source .venv/bin/activate`: Activate the docs virtual environment.
- `python -m pip install -r requirements-docs.txt`: Install Zensical.
- `zensical serve`: Preview the documentation site locally.
- `zensical build --clean`: Build the documentation site into `site/`.
- `display_version` or `dv`: Print the current CBC version banner.
- `changes [-c]`: Open the changelog or copy the URL.
- `releases [-c]`: Open the releases page or copy the URL.
- `readme [-c]`: Open the README or copy the README URL.
- `wiki [-c|-C|-A|-F]`: Open the wiki or jump to reference pages.
- `dotfiles [-h]`: Open the dotfiles repository.

## Testing

- No automated tests are tracked.
- Follow `docs/operations/standard_operating_procedures.md` for manual test
  guidance.
- For documentation site changes, run `zensical build --clean` after
  installing `requirements-docs.txt` in `.venv`.

## Linting and Formatting

- No linting or formatting tooling is documented.
- Verification needed: confirm if any lint/format commands exist outside
  this repository.

## CI and Release

- `.github/workflows/docs.yml` builds the Zensical site and deploys it to
  GitHub Pages on pushes to `main` or manual dispatch.
- `CHANGELOG.md` is generated by external tooling only; never edit it
  manually or with AI.
- Official releases are managed by the external `commit-and-tag-release`
  tool.

## Conventions

- Follow `docs/operations/standard_operating_procedures.md` when adding or
  modifying functions and aliases.
- Keep `cbc list` output in `custom_bash_commands.sh` aligned with current
  functions and aliases by updating `function_names`, `alias_names`,
  `function_descs`, and `alias_descs`.
- Maintain `cbc_aliases.sh` as the alias catalog loaded by the main script.
- Single-letter aliases in `cbc_aliases.sh` are limited to `c`, `s`, `v`,
  `x`, and `z`.
- Agents must never read, create, edit, delete, move, stage, commit, or
  otherwise touch `todo.txt`; only the user may modify it manually.

## Security and Compliance

- Do not commit secrets, credentials, or private keys.
- Verification needed: no security or compliance policy is tracked.

## Dependencies and Services

- `docs/dependencies.md` required tools:
  - bash
  - git
  - curl
  - sed
  - awk
  - find
  - xargs
  - man
  - xdg-open
  - setsid
  - Python 3.10 or newer
  - fzf
  - bat or batcat
  - eza
  - imv-x11
  - nvim
  - wl-copy
- `docs/dependencies.md` strongly recommended tools: gum.
- `docs/dependencies.md` documentation build tools: pip and Zensical.
- External service: GitHub is used by `cbc update check`, `cbc update`,
  `cbc pkg load`, `cbc pkg update`, `cbc doctor`, and GitHub Pages
  deployment.

## Troubleshooting

- Installer path errors: `install_cbc.sh` requires the repo at
  `~/Documents/github_repositories/custom_bash_commands`.
- Sourcing line missing: rerun `install_cbc.sh` or add the
  `source ~/.custom_bash_commands.sh` line manually.
- Manifest modules missing after startup: run `cbc pkg load` to install
  packages listed in `~/.config/cbc/packages.toml`.
- Zensical command missing: activate `.venv` or run the command through
  `.venv/bin/zensical` after installing `requirements-docs.txt`.

## Refining Existing AGENTS.md

- Verify every statement against repository files or explicit user input.
- Remove stale, duplicated, or speculative guidance.
- Enforce the template section order and formatting rules.
- Replace vague statements with exact commands and file paths.
- Add "Verification needed" notes when information is not confirmed.
- Optimize for AI consumption with short, atomic bullets.

## Maintenance

- After any code or documentation change, re-check this file against the
  repo.
- Re-scan tracked files and update the file list immediately.
- Re-verify commands, paths, and workflows for accuracy.
- Update AGENTS.md to resolve mismatches without delay.
- Do not record update notes or logs in this file.
