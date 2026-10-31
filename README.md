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
- [Documentation Site](#documentation-site)
- [Documentation Style](#documentation-style)
- [Contribution Workflow](#contribution-workflow)
- [Troubleshooting](#troubleshooting)

## Overview

The core script can use [Charmbracelet gum](https://github.com/charmbracelet/gum)
for styled prompts and messages. The `CBC_USE_GUM` config key controls
whether gum is auto-detected, required, or disabled. When sourced in an
interactive shell, CBC loads config from `~/.config/cbc/cbc.config`,
sources installed module entrypoints from `~/.config/cbc/modules`, and
prints a version banner once per session (unless disabled). Manifest
packages are installed or repaired only when users run `cbc pkg load`.
It sources `~/.cbc_aliases.sh` if present and warns when missing, then
optionally sources `~/.bash_aliases` when enabled in config.

## Key Components

| Path | Purpose |
| --- | --- |
| `custom_bash_commands.sh` | Main entry point. Defines `cbc` subcommands, styled output helpers, update checks, and module management. |
| `cbc_aliases.sh` | Alias catalog loaded by the main script. |
| `install_cbc.sh` | Installer that validates the repository path, copies scripts into `~`, appends a sourcing line to `.bashrc` when missing, and creates common directories under `~/Documents`. |
| `docs/` | Reference documentation for dependencies, SOPs, and commands. |
| `zensical.toml` | Zensical configuration for the documentation site. |
| `requirements-docs.txt` | Pinned Python package list for documentation builds. |
| `CHANGELOG.md` & `cbc_logo_00001.png` | Release history file and branding asset used in documentation. |

## Prerequisites

CBC expects the tools listed in `docs/dependencies.md`. Highlights include:

- `gum` for styled UI output (strongly recommended, optional).
- `git` and `curl` for update checks and module management.
- `fzf`, `eza`, and `bat`/`batcat` for aliases and formatted output.
- `nvim` for editor shortcuts.
- `wl-copy` for clipboard options in `readme`, `wiki`, `changes`, and
  `releases`.
- `imv-x11` for the `imv` alias and `man` for `fman`.
- Python 3.10 or newer for Zensical documentation builds.

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
- Installed module entrypoints in `~/.config/cbc/modules` are sourced
  when present.
- Packages listed in `~/.config/cbc/packages.toml` are not aligned during
  startup. Run `cbc pkg load` to install or repair manifest modules.
- `~/.cbc_aliases.sh` is sourced if it exists; missing files trigger a
  warning. When `CBC_SOURCE_BASH_ALIASES=true` (default),
  `~/.bash_aliases` is sourced afterward.
- `CBC_USE_GUM=auto` (default) uses gum when installed and plain text
  otherwise.
- `CBC_USE_GUM=true` requires gum and blocks command execution when gum
  is missing.
- `CBC_USE_GUM=false` always uses plain text output.
- When gum is active, styled output uses the terminal's ANSI palette and
  default foreground/background colors.
- CBC does not check for updates automatically; use `cbc update check`.

### Theme colors and automatic refresh

CBC uses the terminal's standard 16 ANSI colors by default: red for errors,
green for success, yellow for warnings, and blue or magenta for headings.
Regular text and backgrounds inherit the terminal defaults. CBC does not
need to read an Omarchy theme file in this mode.

When your terminal reloads its palette, existing CBC output can recolor,
including previous messages, boxes, and tables in scrollback. This depends
on the terminal applying palette changes to existing cells. Already-running
Gum interfaces use the same palette references. No CBC hook or shell restart
is needed. Output printed by older CBC versions with fixed RGB colors
cannot be converted retroactively.

For fixed RGB styling, set `CBC_OMARCHY_COLORS_FILE` to a palette file before
sourcing CBC, or assign it in the running shell. For example, use
`~/.local/state/omarchy/current/theme/colors.toml` for the active Omarchy
palette. An empty value restores terminal colors. This is a shell variable,
not a `cbc.config` key.

Explicit palette files support named colors (such as `red`, `green`, and
`selection`) and legacy `color0`–`color14` keys; named colors take precedence.
Values must be quoted six-digit hex colors. Missing or invalid colors use
derived colors or Catppuccin-Mocha defaults; unreadable files use the full
fallback palette. CBC checks file contents before each render, but existing
RGB output and already-running interfaces retain their original colors.
Modules passing literal hex colors also retain fixed RGB styling.

Gum's built-in keybinding help is hidden because its colors are internal to
Gum; CBC command help remains available with `-h`.

When reloading over an older CBC release with `cbc test` or `source`, CBC
replaces the inherited old default palette path with terminal colors.
Custom palette paths are preserved. After this one-time migration, explicit
overrides of the legacy path are also preserved on subsequent reloads.

## Daily Usage

### Discover and monitor CBC

- `display_version` (alias `dv`) prints the version banner.
- `cbc doctor` runs diagnostics for dependencies, config, modules, and
  GitHub update access.
- `cbc doctor startup` profiles CBC startup timing and prints hints for
  reducing terminal initialization delay.
- `readme`, `wiki`, `changes`, `releases`, and `dotfiles` open project
  resources in the default browser. Use `-c` to copy URLs where supported.
- `cbc list [-v]` lists available functions and aliases; it uses `bat` or
  `batcat` for formatted output when available.

### Update CBC

- `cbc update check` queries the latest GitHub release.
- `cbc update` (alias `ucbc`) pulls the latest scripts via sparse checkout
  and reloads CBC.
- `cbc test` reloads CBC from the current custom_bash_commands repository
  root for development. It fails when run from another directory.

### Configure CBC

- `cbc config [-f]` writes `~/.config/cbc/cbc.config` with defaults.
- `cbc config edit [--reset]` opens the config in your editor, writing
  defaults when missing or when `--reset` is used.
- `cbc config -e [--reset]` is shorthand for the edit workflow.
- Config keys include `CBC_SHOW_BANNER`, `CBC_BANNER_MODE`,
  `CBC_SOURCE_BASH_ALIASES`, `CBC_LIST_SHOW_DESCRIPTIONS`, and
  `CBC_USE_GUM`.

### Manage CBC modules

- `cbc pkg` stores module metadata in `~/.config/cbc/packages.toml`.
- `cbc pkg install <creator/repo|git-url|path>` records a module source.
- `cbc pkg load` installs missing manifest modules, refreshes metadata,
  and sources entrypoints.
- `cbc pkg update` fast-forwards installed module repos, refreshes the
  manifest, and shows the previous and new installed versions in a table.
- Update fetches up to four repositories concurrently. Use
  `cbc pkg update --jobs N` to change the limit, or `--jobs 1` for
  foreground sequential fetches that support terminal authentication.
  Parallel fetches require credentials available without terminal prompts,
  such as a credential helper or SSH agent. Merges, manifest writes, and
  module sourcing remain sequential.
- `cbc pkg uninstall <creator/repo|module-name>` removes the manifest
  entry and local module folder.
- `cbc pkg list` shows installed module versions, status, and last update
  dates in a table without contacting remotes. Status uses locally known
  refs and manifest metadata, not a fresh remote check.
- `cbc pkg list --refresh` contacts remotes for live update checks. It
  refreshes Git refs but does not merge changes. Unavailable remote state
  is reported as unknown rather than current.
- Subcommands support `-h` for help (for example, `cbc pkg install -h`).

### Aliases and navigation

- Editor and shell helpers: `editbash`, `refresh`, `fman`, `please`,
  `myip`, `imv`.
- `eza` wrappers for directory listings such as `la`, `ll`, and `lt`.
- Python and editor shortcuts: `py`, `python`, `vim`, `v`.
- Single-letter aliases are limited to `c`, `s`, `v`, `x`, and `z`.
- On Ubuntu-like systems, `bat` is aliased to `batcat`.
- Use `cbc list -v` to see the full alias catalog.

### Startup performance

Configuration parsing and module discovery use Bash built-ins. The standard
terminal-palette banner also renders with built-ins, retaining its green and
yellow colors without starting Gum. It respects `NO_COLOR`, `CLICOLOR`, and
`CLICOLOR_FORCE`; redirected output is plain by default. Explicit RGB palette
overrides continue to use Gum for color conversion.

Module entrypoints still run in order at startup. Large, definition-only
implementations can opt into first-use loading while keeping command names
available to `type`, completion registration, and callers:

```bash
if declare -F cbc_lazy_register >/dev/null; then
  cbc_lazy_register "${BASH_SOURCE[0]%cbc-module.sh}commands.sh" \
    example_command example_helper
else
  source "${BASH_SOURCE[0]%cbc-module.sh}commands.sh"
fi
```

List every top-level function defined by `commands.sh`. Keep aliases,
completion registration, keybindings, and other startup effects in the
entrypoint; the implementation must contain function definitions only. The
loader preserves registration-time alias parsing and later user function
overrides. Commands execute in the current shell, and reloads register fresh
wrappers. Missing or incomplete implementations fail and can be repaired and
retried. Avoid grouping independently overridden commands into one large
implementation without testing their interactions.

Small alias modules remain eager. First-use loading moves parsing work to the
first invocation, so compare both startup and first-use latency before adopting
it. CBC's own command implementations remain eager after testing showed that
deferring the entire core added more first-use latency than it saved at startup.

Run the startup regression checks from the repository root:

```bash
bash tests/test_startup.sh
bash tests/test_lazy_loading.sh
python3 tests/test_banner.py
bash tests/test_theme_reload.sh
```

Use Python 3.10 or newer for the benchmark and PTY banner tests. The benchmark
uses fresh interactive Bash processes, three warmups, alternating script order,
and median/p95 reporting. It loads no host profiles and uses a temporary home.
Selected module entrypoints execute, so use trusted module directories.

```bash
python3 tests/benchmark_startup.py --runs 40 \
  --modules "$HOME/.config/cbc/modules" --aliases cbc_aliases.sh
```

Compare a saved baseline and the current script with repeated `--script`
arguments. Measure first and repeated calls by passing `--command` last:

```bash
python3 tests/benchmark_startup.py --runs 40 --case quiet \
  --modules "$HOME/.config/cbc/modules" --command mkrepo -h
```

The opt-in `--shell-startup` mode executes the real `~/.bashrc`, substituting
each selected script for `source ~/.custom_bash_commands.sh` without editing
shell configuration. It measures shell startup plus exit, excluding the first
prompt and terminal-emulator creation. Other shell integrations execute
normally.
This mode fails if that CBC source is not observed. Run timing comparisons
without other benchmarks in parallel.

## Documentation Site

The documentation site uses Zensical with source files in `docs/` and output in
`site/`. Install the docs dependencies in a virtual environment before serving
or building the site locally:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-docs.txt
```

Preview the site locally:

```bash
zensical serve
```

Build the static site:

```bash
zensical build --clean
```

GitHub Pages deployment is handled by `.github/workflows/docs.yml` when changes
are pushed to `main` or when the workflow is run manually.

## Documentation Style

Most Markdown in this project is wrapped at 80 characters. The following
cases may exceed that limit when readability would otherwise suffer:

- Tables that depend on single-line rows.
- URLs that become ambiguous or unusable when broken across lines.
- Code fences where formatting depends on preserving longer lines.

## Contribution Workflow

- Follow `docs/operations/standard_operating_procedures.md` when adding
  functions or aliases.
- Keep `cbc list` arrays in sync (`function_names`, `function_descs`,
  `alias_names`, `alias_descs`).
- Update documentation whenever behavior or dependencies change.
- Run `zensical build --clean` after changing documentation site files.

### Release versioning

The repository's `.versionrc.cjs` configures `commit-and-tag-version` to
update `CBC_VERSION` in `custom_bash_commands.sh` during each release. Git
release tags determine the current release version; the script is a bump
target, so an outdated embedded version cannot reset the release sequence.
The updater preserves the `v` prefix and changes only the version assignment.
It rejects missing, duplicate, or malformed assignments.

Release tooling requires Node.js and npm/npx. The configuration was verified
with `commit-and-tag-version` 13.3.0, which requires Node.js 22 or newer.
Preview the next release from the repository root with:

```bash
npx commit-and-tag-version --dry-run
```

When available, the `verg` wrapper from the `commit-and-tag-version` CBC
module automatically uses this configuration for its preview and confirmed
release. The generated release commit includes the updated script version
and changelog. Adding the configuration does not itself bump `CBC_VERSION`.
Keep `CHANGELOG.md` managed by the release tool.

Check the updater independently, without creating a release:

```bash
node --test tests/test_version_updater.cjs
```

## Troubleshooting

- **Provisioning fails with a path error:** `install_cbc.sh` verifies the
  repository lives at `~/Documents/github_repositories/custom_bash_commands`
  and aborts if it does not. Move the clone into the expected location and
  rerun the script.
- **Dependencies missing or failing silently:** Compare your environment
  against `docs/dependencies.md` and confirm helpers such as `gum`, `fzf`,
  `wl-copy`, `eza`, `nvim`, and `imv-x11` are installed.
- **Gum required but missing:** If `CBC_USE_GUM=true`, install `gum` or
  set `CBC_USE_GUM=auto` or `CBC_USE_GUM=false` in
  `~/.config/cbc/cbc.config`.
- **Manifest modules missing after startup:** run `cbc pkg load` to
  install packages listed in `~/.config/cbc/packages.toml` and source
  their entrypoints in the current shell.
- **Terminal startup feels slow:** run `cbc doctor startup` to measure CBC
  source time, module loading, banner rendering, and related settings.
- **Zensical command missing:** activate `.venv` or run
  `.venv/bin/zensical build --clean` after installing
  `requirements-docs.txt`.
