#!/usr/bin/env bash
# Run from the repository root: bash tests/test_theme_reload.sh
set -eo pipefail

repo_root="$(pwd -P)"
if [ ! -f "$repo_root/custom_bash_commands.sh" ]; then
  printf '%s\n' 'Run this check from the CBC repository root.' >&2
  exit 1
fi

test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home"
export CBC_CONFIG_DIR="$HOME/.config/cbc"
export CBC_MODULE_ROOT="$CBC_CONFIG_DIR/modules"
export CBC_PACKAGE_MANIFEST="$CBC_CONFIG_DIR/packages.toml"
mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT/fixture" \
  "$HOME/.local/state/omarchy/current/theme"
printf '%s\n' 'CBC_USE_GUM=false' 'CBC_SHOW_BANNER=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_DIR/cbc.config"
: >"$HOME/.cbc_aliases.sh"
: >"$CBC_MODULE_ROOT/fixture/cbc-module.sh"

palette="$HOME/.local/state/omarchy/current/theme/colors.toml"
printf '%s\n' 'background = "#111c18"' 'foreground = "#c1c497"' \
  'accent = "#509475"' 'bright_blue = "#acd4cf"' >"$palette"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

legacy_path="$HOME/.config/omarchy/current/theme/colors.toml"
# Simulate the variables and obsolete helper left by older CBC releases.
CBC_OMARCHY_COLORS_FILE="$legacy_path"
cbc_theme_get_file_mtime() { stat -c %Y "$1" 2>/dev/null || true; }
source "$repo_root/custom_bash_commands.sh"
cbc_test >/dev/null
[ -z "$CBC_OMARCHY_COLORS_FILE" ] || fail 'Legacy default stayed pinned.'
if declare -F cbc_theme_get_file_mtime >/dev/null; then
  fail 'Obsolete helper survived migration.'
fi

# Capture arguments from the actual package list table without remote access.
gum() { printf '%s\n' "$@" >"$HOME/gum-last-call"; }
check_table_color() {
  local flag="$1" expected="$2" idx=0
  local -a args=()
  mapfile -t args <"$HOME/gum-last-call"
  [ "${args[0]}" = table ] || fail 'Package listing did not render a table.'
  for ((idx = 1; idx < ${#args[@]} - 1; idx++)); do
    if [ "${args[idx]}" = "$flag" ]; then
      [ "${args[idx + 1]}" = "$expected" ] || fail "Stale $flag color."
      return 0
    fi
  done
  fail "Missing $flag argument."
}

CBC_GUM_ACTIVE=true
cbc_pkg_list >/dev/null
check_table_color --cell.foreground ''
check_table_color --cell.background ''
check_table_color --header.background '12'
check_table_color --header.foreground '0'

# The same shell must pick up a subsequent theme change on its first table.
printf '%s\n' 'background = "#102030"' 'foreground = "#d0e0f0"' \
  'accent = "#456789"' >"$palette"
cbc_pkg_list >/dev/null
check_table_color --cell.foreground ''
check_table_color --cell.background ''
check_table_color --header.background '12'

# Explicit RGB palettes remain supported and refresh in the same shell.
CBC_OMARCHY_COLORS_FILE="$palette"
cbc_pkg_list >/dev/null
check_table_color --cell.foreground '#d0e0f0'
check_table_color --cell.background '#102030'
check_table_color --header.background '#456789'
printf '%s\n' 'background = "#111c18"' 'foreground = "#c1c497"' \
  'bright_blue = "#acd4cf"' >"$palette"
cbc_pkg_list >/dev/null
check_table_color --cell.foreground '#c1c497'
check_table_color --header.background '#acd4cf'

# Clearing an override must discard cached RGB values immediately.
CBC_OMARCHY_COLORS_FILE=""
cbc_pkg_list >/dev/null
check_table_color --cell.foreground ''
check_table_color --header.background '12'

# Genuine custom paths must survive an old-to-new reload too.
CBC_OMARCHY_COLORS_FILE="$HOME/custom.toml"
printf '%s\n' 'background = "#123456"' >"$CBC_OMARCHY_COLORS_FILE"
cbc_theme_get_file_mtime() { stat -c %Y "$1" 2>/dev/null || true; }
cbc_test >/dev/null
[ "$CBC_OMARCHY_COLORS_FILE" = "$HOME/custom.toml" ] ||
  fail 'Custom override was discarded.'
cbc_theme_refresh_palette
[ "$CATPPUCCIN_BASE" = '#123456' ] || fail 'Custom palette was not loaded.'

# Once migration finishes, even an explicit legacy-path override must survive.
mkdir -p "${legacy_path%/*}"
printf '%s\n' 'background = "#654321"' >"$legacy_path"
CBC_OMARCHY_COLORS_FILE="$legacy_path"
cbc_test >/dev/null
[ "$CBC_OMARCHY_COLORS_FILE" = "$legacy_path" ] ||
  fail 'Subsequent explicit legacy override was discarded.'
cbc_theme_refresh_palette
[ "$CATPPUCCIN_BASE" = '#654321' ] || fail 'Legacy override was not loaded.'

# Check real Gum output when installed, with truecolor enabled so accidental
# RGB colors cannot be hidden by automatic terminal capability downgrading.
unset -f gum
if command -v gum >/dev/null 2>&1; then
  CBC_GUM_ACTIVE=true
  CBC_OMARCHY_COLORS_FILE=""
  export TERM=xterm-256color COLORTERM=truecolor CLICOLOR_FORCE=1
  output="$(cbc_style_message CATPPUCCIN_RED 'palette marker')"
  [[ "$output" == *$'\e[31m'* ]] || fail 'Message lost its ANSI red role.'
  [[ "$output" != *$'\e[38;2;'* && "$output" != *$'\e[48;2;'* ]] ||
    fail 'Message contains fixed RGB colors.'
  for output in \
    "$(cbc_style_box CATPPUCCIN_BLUE 'box marker')" \
    "$(cbc_style_note 'note marker' 'body')" \
    "$(cbc_style_table 'Name' '16' 'table marker')"; do
    [[ "$output" == *$'\e['* ]] || fail 'Gum output has no styling.'
    [[ "$output" != *$'\e[38;2;'* && "$output" != *$'\e[48;2;'* ]] ||
      fail 'Gum output contains fixed RGB colors.'
  done
  output="$(cbc_style_message '#123456' 'literal marker')"
  [[ "$output" == *'38;2;18;52;86'* ]] ||
    fail 'Literal module color was not preserved.'
else
  printf '%s\n' 'SKIP: real Gum escape-sequence checks (gum unavailable)'
fi

printf '%s\n' 'PASS: terminal colors, reload migration, and RGB overrides'
