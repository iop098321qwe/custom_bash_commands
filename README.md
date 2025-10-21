![Custom Bash Commands logo](cbc_logo_00001.png)

# Custom Bash Commands

Custom Bash Commands (CBC) is a personal automation toolkit for Linux shells.
It layers interactive helpers, file management utilities, media launchers, and
Git quality-of-life shortcuts on top of standard Bash. The project also ships a
companion alias catalog, optional provisioning script, and documentation that
keep the experience reproducible across machines.

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Keeping CBC Updated](#keeping-cbc-updated)
- [Daily Usage](#daily-usage)
- [Documentation & Layout](#documentation--layout)
- [Troubleshooting](#troubleshooting)

## Overview

CBC is driven by `custom_bash_commands.sh`, which loads on each terminal start
(after being sourced from `~/.bashrc`). When
[Charmbracelet gum](https://github.com/charmbracelet/gum) is installed, CBC uses
Catppuccin-themed UI components for prompts, confirmation dialogs, and status
messages. When gum is missing, every helper falls back to POSIX-friendly
`printf` and `read` so the commands remain usable.
【F:custom_bash_commands.sh†L1-L124】

Key features include:

- Automatic release checks against GitHub with cached polling intervals and
  update notifications inside the shell.【F:custom_bash_commands.sh†L1318-L1446】
- A discoverability command (`cbcs`) that prints all CBC functions and aliases,
  plus optional expanded descriptions with `cbcs -a`. The script also exposes a
  `commands` alias that pipes the output through `batcat` for easier reading.
  【F:custom_bash_commands.sh†L1494-L1754】【F:cbc_aliases.sh†L37-L45】
- Startup helpers that ensure working directories (Temporary, GitHub
  repositories, and the Grymm's Grimoires knowledge base) exist before the rest
  of the script runs.【F:custom_bash_commands.sh†L1240-L1268】
- A dedicated alias file (`cbc_aliases.sh`) that keeps the main script modular
  while providing navigation shortcuts, Git helpers, fuzzy pickers, media
  launchers, and productivity wrappers.【F:cbc_aliases.sh†L1-L119】

## Prerequisites

CBC targets Debian/Ubuntu-based systems. Install the utilities that CBC calls
out-of-the-box so every command works as expected:

- Core tools: `git`, `curl`, `python3`, `fzf`, `ripgrep`, `fd`, `batcat`,
  `xclip`, `yt-dlp`, `neovim`, `chezmoi`, `eza`, `starship`, `zellij`, `zoxide`.
- Optional tooling surfaced by aliases: `obsidian`, `lazygit`, `lazydocker`,
  `stacer`, `btop`, `thefuck`, `tldr`, `ranger`, `kitty`, `brave-browser`, and
  `tree`.

See `docs/dependencies.md` for the authoritative package list and keep it in
sync with your environment.【F:docs/dependencies.md†L1-L23】 Gum is optional but
highly recommended for the best UX.

## Installation

CBC expects to live inside
`~/Documents/github_repositories/custom_bash_commands` so that the provisioning
script can copy files to the home directory. Use the following steps for a clean
installation:

1. Ensure the target directory exists:
   ```bash
   mkdir -p ~/Documents/github_repositories
   ```
2. Clone the repository into the expected location:
   ```bash
   git clone https://github.com/iop098321qwe/custom_bash_commands \
     ~/Documents/github_repositories/custom_bash_commands
   ```
3. Enter the repository and run the provisioning helper:
   ```bash
   cd ~/Documents/github_repositories/custom_bash_commands
   ./new_update_commands.sh
   ```
   The script copies the main CBC files into your home directory, creates
   supporting folders under `~/Documents` and `~/temporary`, and appends
   sourcing lines to `~/.bashrc` before reloading the shell.
   【F:new_update_commands.sh†L1-L43】

> **Note:** `new_update_commands.sh` blindly appends the sourcing lines every
> run. If you rerun the script, trim duplicate `source ~/.update_commands.sh`
> and `source ~/.custom_bash_commands.sh` entries from `~/.bashrc` with the
> `editbash` alias.【F:new_update_commands.sh†L35-L43】【F:cbc_aliases.sh†L30-L33】

If you prefer to configure things manually, copy `custom_bash_commands.sh` and
`cbc_aliases.sh` into your home directory (prefixed with a dot), mark them as
executable, and append the following to the end of `~/.bashrc`:

```bash
source ~/.update_commands.sh
source ~/.custom_bash_commands.sh
```

Restart the terminal (or run `refresh`) so the new aliases and functions load.

## Keeping CBC Updated

CBC checks GitHub for new releases each time the script is sourced and shows a
styled notification when a newer tag is found. Update your local copy with the
`updatecbc` function, which uses a sparse checkout to fetch the latest script,
alias file, and `.version` metadata before re-sourcing CBC.【F:custom_bash_commands.sh†L1318-L1446】【F:custom_bash_commands.sh†L3339-L3412】

Helpful maintenance commands:

- `display_version` (alias `dv`) prints the currently loaded version and
  pointers to the wiki and changelog.【F:custom_bash_commands.sh†L1448-L1488】
- `changes [-c]` opens or copies the GitHub changelog so you can review what is
  new before updating.【F:custom_bash_commands.sh†L1178-L1214】
- `remove_all_cbc_configs` (alias `racc`) cleans up CBC-related dotfiles from
  your home directory if you want to uninstall the toolkit.【F:custom_bash_commands.sh†L2534-L2606】【F:cbc_aliases.sh†L86-L90】

## Daily Usage

Run `display_info` (or the `di` alias) after opening a terminal session to see
version information and confirm CBC loaded correctly.【F:custom_bash_commands.sh†L3314-L3337】【F:cbc_aliases.sh†L31-L34】
The `cbcs` command lists every function and alias CBC defines, while `cbcs -a`
adds descriptions, default options, and related shortcuts.
【F:custom_bash_commands.sh†L1494-L1754】

Popular functions:

- **Automation:** `batchopen` opens lists of URLs, `repeat` reruns commands with
  optional counts or delays, and `update` orchestrates system package updates
  with flags for reboot/shutdown/log inspection.【F:custom_bash_commands.sh†L145-L322】【F:custom_bash_commands.sh†L706-L871】【F:custom_bash_commands.sh†L2621-L2796】
- **Media workflows:** `sopen`/`sopenexact` launch video files based on playlist
  patterns, `random` opens a random video, and `pronlist` manages batch download
  manifests that integrate with yt-dlp aliases.【F:custom_bash_commands.sh†L491-L686】【F:custom_bash_commands.sh†L1049-L1106】【F:custom_bash_commands.sh†L344-L489】
- **File utilities:** `smartsort` groups files by extension, alphabet, modified
  date, size, or MIME type (with interactive refinements), `extract` handles
  archive formats, `filehash` computes checksums, and `regex_help` surfaces
  common regular expression snippets.【F:custom_bash_commands.sh†L809-L1332】【F:custom_bash_commands.sh†L3330-L3392】【F:custom_bash_commands.sh†L3498-L3599】【F:custom_bash_commands.sh†L3235-L3327】
- **Reference helpers:** `wiki` jumps to the GitHub wiki, `dotfiles` opens the
  related dotfiles repository, and `makeman` scaffolds new man pages for your
  scripts.【F:custom_bash_commands.sh†L1108-L1176】【F:custom_bash_commands.sh†L1230-L1268】【F:custom_bash_commands.sh†L2798-L2910】

Alias highlights:

- Directory management shortcuts (`back`, `cbc`, `cdgh`, `home`, `vault`) keep
  navigation quick.【F:cbc_aliases.sh†L17-L73】
- Fuzzy helpers (`fopen`, `fhelpexact`, `historysearch`, `line`) wrap `fzf`
  interactions for launching files, commands, or manual pages.
  【F:cbc_aliases.sh†L39-L88】
- Git utilities (`gco`, `gsw`, `cbcc`, `verg`) accelerate common workflows with
  smart defaults.【F:cbc_aliases.sh†L47-L109】

Use the `commands` or `commandsmore` aliases to review the catalog whenever you
need a refresher.【F:cbc_aliases.sh†L37-L45】

## Documentation & Layout

This repository includes supporting documentation under `docs/`:

- `dependencies.md` – list of external packages CBC relies on.
- `standard_operating_procedures.md` – guidance for extending CBC with new
  functions or aliases.
- `todo.md` – backlog notes for future improvements.【F:docs/dependencies.md†L1-L23】【F:docs/standard_operating_procedures.md†L1-L56】

Other notable files:

- `cbc_aliases.sh` – alias definitions sourced by the main script.
- `new_update_commands.sh` – bootstrap helper for first-time installation.
- `CHANGELOG.md` – human-readable release history referenced by the `changes`
  command.
- `.versionrc` – release tooling configuration for `npx commit-and-tag-version`.

## Troubleshooting

- **Missing commands or aliases:** Run `refresh` (alias that sources
  `~/.bashrc`) or open a new shell to reload CBC.【F:cbc_aliases.sh†L83-L89】
- **Duplicate shell sourcing lines:** Open `~/.bashrc` with the `editbash` alias
  and remove extra `source ~/.custom_bash_commands.sh` entries added by repeat
  provisioning runs.【F:new_update_commands.sh†L35-L43】【F:cbc_aliases.sh†L30-L33】
- **Dependency issues:** Compare your installed packages against
  `docs/dependencies.md` and install anything missing. Some features (such as
  clipboard integration via `xclip` or batch downloads via `yt-dlp`) silently
  fail without their supporting tools.【F:docs/dependencies.md†L1-L23】【F:custom_bash_commands.sh†L1178-L1214】

For deeper maintenance notes and contribution guidelines, review `AGENTS.md` and
`docs/standard_operating_procedures.md` before making changes.
