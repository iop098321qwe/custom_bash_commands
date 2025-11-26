![Custom Bash Commands logo](cbc_logo_00001.png)

# Custom Bash Commands

Custom Bash Commands (CBC) is a personal automation toolkit for Linux shells.
It wraps interactive helpers, media utilities, fuzzy finders, and Git-focused
shortcuts around a single Bash entry point so the experience stays consistent
across machines.【F:custom_bash_commands.sh†L1-L3357】 CBC ships with a dedicated
alias catalog, a lightweight installer, and supplemental documentation that keep
new environments aligned with the toolkit's expectations.【F:cbc_aliases.sh†L1-L135】【F:install_cbc.sh†L1-L34】【F:docs/standard_operating_procedures.md†L1-L72】

- [Overview](#overview)
- [Key Components](#key-components)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Post-Installation Behavior](#post-installation-behavior)
- [Daily Usage](#daily-usage)
- [Supporting Docs & Utilities](#supporting-docs--utilities)
- [Troubleshooting](#troubleshooting)

## Overview

The core script detects whether [Charmbracelet gum](https://github.com/
charmbracelet/gum) is available before exposing a Catppuccin-themed set of
styling helpers and gracefully falling back to plain `printf` and `read` when
gum is absent.【F:custom_bash_commands.sh†L1-L129】 A startup routine creates the
Temporary, GitHub, and Grymm's Grimoires working directories, checks GitHub for
new CBC releases with cached polling rules, and prints a version dashboard so
users know which features loaded successfully.【F:custom_bash_commands.sh†L1579-L1781】【F:custom_bash_commands.sh†L1787-L1829】【F:custom_bash_commands.sh†L3220-L3342】

## Key Components

| Path | Purpose |
| --- | --- |
| `custom_bash_commands.sh` | Main entry point. Defines gum-aware UI helpers, configures onboarding tasks, implements feature functions, and triggers the initial status output when sourced.【F:custom_bash_commands.sh†L1-L3357】 |
| `cbc_aliases.sh` | Catalog of navigation shortcuts, Git aliases, fuzzy wrappers, media launchers, and helper shorthands that keep the main script modular.【F:cbc_aliases.sh†L1-L135】 |
| `install_cbc.sh` | Installer that validates the repository path, copies the main script and aliases into the home directory, and appends sourcing lines to `.bashrc` before reloading the shell.【F:install_cbc.sh†L1-L34】 |
| `docs/` | Reference documentation covering dependency expectations, SOPs for adding functions or aliases, and the current TODO backlog.【F:docs/dependencies.md†L1-L24】【F:docs/standard_operating_procedures.md†L1-L72】【F:docs/todo.md†L1-L81】 |
| `node_modules/` | Vendored tooling used for release automation (e.g., `npx commit-and-tag-version`, exposed via the `ver` alias). Avoid modifying or expanding the dependency tree unless a release workflow change requires it.【F:cbc_aliases.sh†L124-L125】 |
| `CHANGELOG.md` & `cbc_logo_00001.png` | Human-readable release history and branding assets referenced by the CLI and README.【F:custom_bash_commands.sh†L1483-L1529】 |

## Prerequisites

CBC targets Debian and Ubuntu-based systems. Install the tools that the scripts
and aliases call directly so each helper works without manual edits. The
`docs/dependencies.md` file tracks the primary package list, while the main
script and alias catalog reference additional utilities such as Git, curl,
`batcat`, `fzf`, `yt-dlp`, `xclip`, Obsidian, Lazygit, Zellij, and the Catppuccin
friendly `eza` file lister.【F:docs/dependencies.md†L1-L24】【F:custom_bash_commands.sh†L145-L1106】【F:cbc_aliases.sh†L11-L135】 Gum is optional but unlocks the
styled UI experience.【F:custom_bash_commands.sh†L1-L129】

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
   catalog into the home directory, appends the sourcing line to `.bashrc`, and
   reloads the shell session.【F:install_cbc.sh†L1-L34】

> **Note:** The installer appends a sourcing line on every run. Use the
> `editbash` alias to remove duplicates from `.bashrc` after reinstalling.
> 【F:install_cbc.sh†L24-L29】【F:cbc_aliases.sh†L19-L36】

If you install manually, copy `custom_bash_commands.sh` and `cbc_aliases.sh` to
`~` (prefixed with dots), mark them executable, and append the following to the
end of `~/.bashrc`:

```bash
source ~/.custom_bash_commands.sh
```

The main script includes an `append_to_bashrc` guard that performs the same
addition when CBC loads, so ensure only one set of sourcing lines remains in the
file.【F:custom_bash_commands.sh†L960-L1003】 Restart the shell (or run `refresh`)
when you finish so the new commands load.【F:cbc_aliases.sh†L103-L116】

## Post-Installation Behavior

When the terminal sources CBC it immediately prepares the working environment:

- `setup_directories` creates the Temporary workspace (with screenshot and
  recording subfolders), the GitHub repositories directory, and the Grymm's
  Grimoires vault if they do not already exist.【F:custom_bash_commands.sh†L1579-L1629】
- `check_cbc_update` polls the GitHub Releases API on a configurable interval,
  caches the response, and surfaces styled upgrade notifications when a newer
  tag is available.【F:custom_bash_commands.sh†L1635-L1781】
- `display_info` runs automatically once per interactive session to show the
  current version, discovery hints, and removal instructions, while
  `cbc_aliases.sh` is sourced to expose every alias. If `.bash_aliases` exists
  it is sourced as well so user-defined shortcuts remain available.
  【F:custom_bash_commands.sh†L3220-L3357】【F:cbc_aliases.sh†L1-L135】

## Daily Usage

### Discover and monitor CBC

- `display_version` (alias `dv`) prints the current version banner and links to
  the wiki for deeper documentation.【F:custom_bash_commands.sh†L1787-L1829】
- `display_info` (alias `di`) is available on demand and runs automatically the
  first time CBC loads in an interactive session to confirm it loaded
  correctly.【F:custom_bash_commands.sh†L3220-L3342】
- `changes [-c]` opens or copies the GitHub changelog before you update so you
  can scan release notes from the terminal.【F:custom_bash_commands.sh†L1483-L1529】
- `wiki [-c|-C|-A|-F]` opens the project wiki or copies the URL to the
  clipboard, providing quick access to deeper documentation categories.
  【F:custom_bash_commands.sh†L1413-L1477】
- `cbcs [-a]` lists every custom function and alias CBC provides. The `commands`
  and `commandsmore` aliases pipe that output through `batcat` for easier
  browsing.【F:custom_bash_commands.sh†L1835-L2626】【F:cbc_aliases.sh†L19-L36】

### Manage CBC modules

- `cbc pkg` stores module metadata in `~/.config/cbc/packages.toml` using
  `[[module.deps]]` entries that carry `use`, `rev`, and `hash` fields so your
  installs can be synchronized across systems.
- `cbc pkg install <creator/repo|git-url|path>` records a module in the
  manifest (without removing existing entries), capturing revision details when
  possible so `cbc pkg load` can later clone it.
- `cbc pkg load` reads `packages.toml`, installs any missing modules using the
  `use` field into `~/.config/cbc/modules/`, updates the recorded `rev` and
  `hash` values, and sources each module's `cbc-module.sh` entrypoint.
- `cbc pkg uninstall <creator/repo|module-name>` prunes the entry from
  `packages.toml`, deletes the module directory in
  `~/.config/cbc/modules/`, and should be followed by a new shell session to
  clear any sourced functions.
- `cbc pkg update` consults the manifest to fetch upstream commits only when a
  module needs them, refreshes the stored metadata, and reloads the modules.
- `cbc pkg` or `cbc pkg list` reports manifest entries with their last updated
  date and a status that marks modules as `Current` or `UPDATE AVAILABLE`.

### Automation, media, and file utilities

- `batchopen`, `phopen`, and `phsearch` open batches of URLs or interactive
  search results in the browser while respecting gum confirmations and fzf
  selections.【F:custom_bash_commands.sh†L145-L338】
- `pronlist` integrates with `_configs.txt` and `yt-dlp` to build download
  manifests from curated text files and optional line selections.
  【F:custom_bash_commands.sh†L341-L485】
- `sopen`, `sopenexact`, and `random` launch media files that match selected
  patterns or pick a random video from the current directory.【F:custom_bash_commands.sh†L488-L1407】
- `repeat` reruns commands with optional delays and verbose logging so you can
  automate repetitive tasks safely.【F:custom_bash_commands.sh†L702-L780】
- `smartsort` groups files by extension, name, modification date, size, or MIME
  type using interactive prompts for fine-grained control.【F:custom_bash_commands.sh†L812-L1344】
- `backup`, `makeman`, `extract`, and `filehash` provide lightweight utilities
  for backups, documentation, archive extraction, and checksum generation.
  【F:custom_bash_commands.sh†L2631-L3141】
- `regex_help` defaults to a PCRE cheat-sheet and can list or interactively
  display other regex flavors so the syntax you need is always in reach.
  【F:custom_bash_commands.sh†L2827-L3164】

### Aliases and navigation

Common aliases cover directory jumps (`cbc`, `cdgh`, `vault`, `temp`), Git
workflows (`cbcc`, `gco`, `gsw`, `gpfom`), fuzzy file launchers (`fo`, `fman`,
`iopen`), media helpers (`pron`, `so`, `vopen`), and release automation (`ver`,
`verg`).【F:cbc_aliases.sh†L11-L135】 Use `commandsmore` for descriptions whenever
you need a refresher.【F:cbc_aliases.sh†L25-L27】

## Supporting Docs & Utilities

- `docs/dependencies.md` lists the baseline package set CBC expects to find on a
  workstation.【F:docs/dependencies.md†L1-L24】
- `docs/standard_operating_procedures.md` documents the preferred structure for
  new functions, aliases, and manual testing workflows.【F:docs/standard_operating_procedures.md†L1-L72】
- `docs/todo.md` tracks outstanding cleanup and feature work, including plans to
  reorganize the `cbcs` catalog output.【F:docs/todo.md†L1-L34】

## Documentation Style

Most Markdown in this project is wrapped at 80 characters. The following cases
may exceed that limit when readability would otherwise suffer:

- Tables, including the repository orientation table in `AGENTS.md` and the Key
  Components table in this README.
- URLs that become ambiguous or unusable when broken across lines.
- Code fences where formatting depends on preserving longer lines.

## Troubleshooting

- **Provisioning fails with a path error:** `install_cbc.sh` verifies the
  repository lives at `~/Documents/github_repositories/custom_bash_commands` and
  aborts if it does not. Move the clone into the expected location and rerun the
  script.【F:install_cbc.sh†L1-L21】
- **Duplicate sourcing lines:** If `.bashrc` contains repeated `source` entries
  after running the installer multiple times, open the file with `editbash` and
  remove the extra lines.【F:install_cbc.sh†L24-L29】【F:cbc_aliases.sh†L19-L36】
- **Dependencies missing or failing silently:** Compare your environment against
  the dependency list and confirm helpers such as `fzf`, `yt-dlp`, `xclip`, and
  `batcat` are installed. CBC leans on these binaries in both scripts and alias
  definitions.【F:docs/dependencies.md†L1-L24】【F:custom_bash_commands.sh†L145-L1529】【F:cbc_aliases.sh†L11-L135】
