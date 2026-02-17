![Custom Bash Commands logo](cbc_logo_00001.png)

# Custom Bash Commands

Custom Bash Commands (CBC) is a Bash-based toolkit for Linux shells. It
provides a small set of helper commands under `cbc`, a few standalone
commands for opening project resources, and a curated alias catalog that
is sourced at shell startup.

- [Overview](#overview)
- [Key Components](#key-components)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Post-Installation Behavior](#post-installation-behavior)
- [Daily Usage](#daily-usage)
- [Supporting Docs & Utilities](#supporting-docs--utilities)
- [Documentation Style](#documentation-style)
- [Contribution Workflow](#contribution-workflow)
- [Troubleshooting](#troubleshooting)

## Overview

The core script uses [Charmbracelet gum](https://github.com/charmbracelet/gum)
for styled prompts and messages. When sourced in an interactive shell, it
loads config from `~/.config/cbc/cbc.config`, aligns modules listed in
`~/.config/cbc/packages.toml`, and prints a version banner once per
session (unless disabled). It sources `~/.cbc_aliases.sh` if present and
warns when missing, then optionally sources `~/.bash_aliases` when
enabled in config.

## Key Components

| Path | Purpose |
| --- | --- |
| `custom_bash_commands.sh` | Main entry point. Defines `cbc` subcommands, gum-based styling helpers, update checks, and module management. |
| `cbc_aliases.sh` | Alias catalog loaded by the main script. |
| `install_cbc.sh` | Installer that validates the repository path, copies scripts into `~`, appends a sourcing line to `.bashrc` when missing, and creates common directories under `~/Documents`. |
| `docs/` | Reference documentation for dependencies, SOPs, and the TODO list. |
| `CHANGELOG.md` & `cbc_logo_00001.png` | Release history file and branding asset used in documentation. |

## Prerequisites

CBC expects the tools listed in `docs/dependencies.md`. Highlights include:

- `gum` for styled UI output.
- `git` and `curl` for update checks and module management.
- `fzf`, `eza`, and `bat`/`batcat` for aliases and formatted output.
- `nvim` for editor shortcuts.
- `wl-copy` for clipboard options in `readme`, `wiki`, `changes`, and
  `releases`.
- `imv-x11` for the `imv` alias and `man` for `fman`.

## Installation

1. Ensure the canonical repository location exists:

   ```bash
   mkdir -p ~/Documents/github_repositories
   ```

2. Clone the project into the expected folder:

   ```bash
   git clone https://github.com/iop098321qwe/custom_bash_commands \
     ~/Documents/github_repositories/custom_bash_commands
   ```

3. Run the installer from inside the repository:

   ```bash
   cd ~/Documents/github_repositories/custom_bash_commands
   ./install_cbc.sh
   ```

   The script verifies the repository path, copies the main script and alias
   catalog into the home directory, appends the sourcing line to `.bashrc` when
   missing, and creates common directories under `~/Documents/Temporary` and
   `~/Documents/github_repositories`.

If you install manually, copy `custom_bash_commands.sh` and
`cbc_aliases.sh` to `~` (prefixed with dots), mark them executable, and
append the following to the end of `~/.bashrc`:

```bash
source ~/.custom_bash_commands.sh
```

Restart the shell (or run `refresh`) when you finish so the new commands
load.

## Post-Installation Behavior

When the terminal sources CBC:

- Config is loaded from `~/.config/cbc/cbc.config` when present.
- A version banner prints once per interactive session when
  `CBC_SHOW_BANNER=true`.
- Modules listed in `~/.config/cbc/packages.toml` are aligned and loaded
  from `~/.config/cbc/modules` when possible.
- `~/.cbc_aliases.sh` is sourced if it exists; missing files trigger a
  warning. When `CBC_SOURCE_BASH_ALIASES=true` (default),
  `~/.bash_aliases` is sourced afterward.
- CBC does not check for updates automatically; use `cbc update check`.

## Daily Usage

### Discover and monitor CBC

- `display_version` (alias `dv`) prints the version banner.
- `cbc doctor` runs diagnostics for dependencies, config, modules, and
  GitHub update access.
- `readme`, `wiki`, `changes`, `releases`, and `dotfiles` open project
  resources in the default browser. Use `-c` to copy URLs where supported.
- `cbc list [-v]` lists available functions and aliases; it uses `bat` or
  `batcat` for formatted output when available.

### Update CBC

- `cbc update check` queries the latest GitHub release.
- `cbc update` (alias `ucbc`) pulls the latest scripts via sparse checkout
  and reloads CBC.
- `cbc test [repo-path]` reloads CBC from a local repo (useful for
  development).

### Configure CBC

- `cbc config [-f]` writes `~/.config/cbc/cbc.config` with defaults.
- Config keys include `CBC_SHOW_BANNER`, `CBC_BANNER_MODE`,
  `CBC_SOURCE_BASH_ALIASES`, and `CBC_LIST_SHOW_DESCRIPTIONS`.

### Manage CBC modules

- `cbc pkg` stores module metadata in `~/.config/cbc/packages.toml`.
- `cbc pkg install <creator/repo|git-url|path>` records a module source.
- `cbc pkg load` installs missing modules and sources entrypoints.
- `cbc pkg update` fast-forwards installed module repos and refreshes the
  manifest.
- `cbc pkg uninstall <creator/repo|module-name>` removes the manifest
  entry and local module folder.
- `cbc pkg list` shows module status and last update dates.
- Subcommands support `-h` for help (for example, `cbc pkg install -h`).

### Aliases and navigation

- Editor and shell helpers: `editbash`, `refresh`, `fman`, `please`,
  `myip`, `imv`.
- `eza` wrappers for directory listings such as `la`, `ll`, and `lt`.
- Python and editor shortcuts: `py`, `python`, `vim`, `v`.
- Single-letter aliases are limited to `c`, `s`, `v`, `x`, and `z`.
- On Ubuntu-like systems, `bat` is aliased to `batcat`.
- Use `cbc list -v` to see the full alias catalog.

## Supporting Docs & Utilities

- `docs/dependencies.md` lists required and optional tools.
- `docs/standard_operating_procedures.md` documents how to add functions
  and aliases and keep `cbc list` accurate.
- `docs/todo.md` tracks outstanding cleanup and feature work.

## Documentation Style

Most Markdown in this project is wrapped at 80 characters. The following
cases may exceed that limit when readability would otherwise suffer:

- Tables that depend on single-line rows.
- URLs that become ambiguous or unusable when broken across lines.
- Code fences where formatting depends on preserving longer lines.

## Contribution Workflow

- Follow `docs/standard_operating_procedures.md` when adding functions or
  aliases.
- Keep `cbc list` arrays in sync (`function_names`, `function_descs`,
  `alias_names`, `alias_descs`).
- Update documentation whenever behavior or dependencies change.

## Troubleshooting

- **Provisioning fails with a path error:** `install_cbc.sh` verifies the
  repository lives at `~/Documents/github_repositories/custom_bash_commands`
  and aborts if it does not. Move the clone into the expected location and
  rerun the script.
- **Dependencies missing or failing silently:** Compare your environment
  against `docs/dependencies.md` and confirm helpers such as `gum`, `fzf`,
  `wl-copy`, `eza`, `nvim`, and `imv-x11` are installed.
