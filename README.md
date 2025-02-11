![Custom Bash Commands logo](cbc_logo_00001.png)

# Custom Bash Commands

Custom Bash Commands (CBC) is a personal automation toolkit for Linux shells.
It wraps interactive helpers, media utilities, fuzzy finders, and Git-focused
shortcuts around a single Bash entry point so the experience stays consistent
across machines.【F:custom_bash_commands.sh†L1-L3357】 CBC ships with a dedicated
alias catalog, provisioning helpers, and supplemental documentation that keep
new environments aligned with the toolkit's expectations.【F:cbc_aliases.sh†L1-L135】【F:new_update_commands.sh†L1-L43】【F:docs/standard_operating_procedures.md†L1-L72】

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
| `new_update_commands.sh` | Provisioning script that copies the main script, bootstrap helpers, and release metadata into the home directory, ensures expected folders exist, verifies the repository lives under `~/Documents/github_repositories/custom_bash_commands`, and appends sourcing lines to `~/.bashrc`.【F:new_update_commands.sh†L1-L43】 |
| `.cbcconfig/apt_packages.conf` | Optional package manifest that records apt software to install alongside CBC.【F:.cbcconfig/apt_packages.conf†L1-L23】 |
| `.testing_setup.sh` | Helper for staging a parallel "test" install of CBC by copying the main script, `update_commands.sh`, and `.version` into temporary dotfiles before sourcing them from `.bashrc`.【F:.testing_setup.sh†L1-L23】 |
| `docs/` | Reference documentation covering dependency expectations, SOPs for adding functions or aliases, and the current TODO backlog.【F:docs/dependencies.md†L1-L24】【F:docs/standard_operating_procedures.md†L1-L72】【F:docs/todo.md†L1-L81】 |
| `managed_context/` & `test_suite_analysis/` | Metadata captured from prior AI sessions and test runs. The JSON files are informational and do not affect runtime behavior.【F:managed_context/metadata.json†L1-L1】【F:test_suite_analysis/metadata.json†L1-L1】 |
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
3. Provide the supporting files that CBC expects in the repository root. Both
   `new_update_commands.sh` and `.testing_setup.sh` copy `update_commands.sh`
   and `.version` into the home directory, so place or generate those files
   before running the provisioning script.【F:new_update_commands.sh†L7-L13】【F:.testing_setup.sh†L1-L23】
4. Run the provisioning helper from inside the repository:
   ```bash
   cd ~/Documents/github_repositories/custom_bash_commands
   ./new_update_commands.sh
   ```
   The script copies CBC into the home directory, creates supporting folders,
   confirms the repository lives in the expected path, appends sourcing lines to
   `.bashrc`, and refreshes the shell session.【F:new_update_commands.sh†L1-L43】

> **Note:** Re-running the provisioning helper appends duplicate sourcing
> commands to `.bashrc`. Use the `editbash` alias to clean up the file after
> subsequent runs.【F:new_update_commands.sh†L35-L43】【F:cbc_aliases.sh†L19-L36】

If you install manually, copy `custom_bash_commands.sh` and `cbc_aliases.sh` to
`~` (prefixed with dots), mark them executable, and append the following to the
end of `~/.bashrc`:

```bash
source ~/.update_commands.sh
source ~/.custom_bash_commands.sh
```

The main script includes an `append_to_bashrc` guard that performs the same
addition when CBC loads, so ensure only one set of sourcing lines remains in the
file.【F:custom_bash_commands.sh†L682-L700】 Restart the shell (or run `refresh`)
when you finish so the new commands load.【F:cbc_aliases.sh†L103-L116】

## Post-Installation Behavior

When the terminal sources CBC it immediately prepares the working environment:

- `setup_directories` creates the Temporary workspace (with screenshot and
  recording subfolders), the GitHub repositories directory, and the Grymm's
  Grimoires vault if they do not already exist.【F:custom_bash_commands.sh†L1579-L1629】
- `check_cbc_update` polls the GitHub Releases API on a configurable interval,
  caches the response, and surfaces styled upgrade notifications when a newer
  tag is available.【F:custom_bash_commands.sh†L1635-L1781】
- `display_info` runs automatically to show the current version, discovery
  hints, and removal instructions, while `cbc_aliases.sh` is sourced to expose
  every alias. If `.bash_aliases` exists it is sourced as well so user-defined
  shortcuts remain available.【F:custom_bash_commands.sh†L3220-L3357】【F:cbc_aliases.sh†L1-L135】

## Daily Usage

### Discover and monitor CBC

- `display_version` (alias `dv`) prints the current version banner and links to
  the wiki for deeper documentation.【F:custom_bash_commands.sh†L1787-L1829】
- `display_info` (alias `di`) is available on demand and runs automatically at
  the end of script startup to confirm CBC loaded correctly.【F:custom_bash_commands.sh†L3220-L3342】
- `changes [-c]` opens or copies the GitHub changelog before you update so you
  can scan release notes from the terminal.【F:custom_bash_commands.sh†L1483-L1529】
- `wiki [-c|-C|-A|-F]` opens the project wiki or copies the URL to the
  clipboard, providing quick access to deeper documentation categories.
  【F:custom_bash_commands.sh†L1413-L1477】
- `cbcs [-a]` lists every custom function and alias CBC provides. The `commands`
  and `commandsmore` aliases pipe that output through `batcat` for easier
  browsing.【F:custom_bash_commands.sh†L1835-L2626】【F:cbc_aliases.sh†L19-L36】

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
- `.cbcconfig/apt_packages.conf` can be used by external installers to control
  which apt packages should be installed or skipped.【F:.cbcconfig/apt_packages.conf†L1-L23】
- `.testing_setup.sh` mirrors the provisioning process for a sandbox install so
  you can test changes without touching the primary configuration.
  【F:.testing_setup.sh†L1-L23】

## Documentation Style

Most Markdown in this project is wrapped at 80 characters. The following cases
may exceed that limit when readability would otherwise suffer:

- Tables, including the repository orientation table in `AGENTS.md` and the Key
  Components table in this README.
- URLs that become ambiguous or unusable when broken across lines.
- Code fences where formatting depends on preserving longer lines.

## Troubleshooting

- **Provisioning fails with a path error:** `new_update_commands.sh` verifies the
  repository lives at `~/Documents/github_repositories/custom_bash_commands` and
  aborts if it does not. Move the clone into the expected location and rerun the
  script.【F:new_update_commands.sh†L19-L34】
- **Missing support files:** The provisioning and testing scripts copy
  `update_commands.sh` and `.version` into the home directory. Ensure both files
  exist alongside the main script before bootstrapping CBC.【F:new_update_commands.sh†L7-L13】【F:.testing_setup.sh†L14-L19】
- **Duplicate sourcing lines:** If `.bashrc` contains repeated `source` entries
  after running the installer multiple times, open the file with `editbash` and
  remove the extra lines.【F:new_update_commands.sh†L35-L43】【F:cbc_aliases.sh†L19-L36】
- **Dependencies missing or failing silently:** Compare your environment against
  the dependency list and confirm helpers such as `fzf`, `yt-dlp`, `xclip`, and
  `batcat` are installed. CBC leans on these binaries in both scripts and alias
  definitions.【F:docs/dependencies.md†L1-L24】【F:custom_bash_commands.sh†L145-L1529】【F:cbc_aliases.sh†L11-L135】
