#!/usr/bin/env bash
# Run from the repository root: bash tests/test_startup.sh
set -eo pipefail

repo_root="$PWD"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home" CBC_CONFIG_DIR="$test_home/config"
export CBC_MODULE_ROOT="$test_home/modules"
export CBC_PACKAGE_MANIFEST="$test_home/packages.toml"
mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT/01 first" \
  "$CBC_MODULE_ROOT/02-second" "$CBC_MODULE_ROOT/missing"
: >"$HOME/.cbc_aliases.sh"
printf '%s\n' 'CBC_SHOW_BANNER=false' 'CBC_USE_GUM=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_DIR/cbc.config"
printf '%s\n' 'module_order+=first' 'startup_fixture() { :; }' \
  >"$CBC_MODULE_ROOT/01 first/cbc-module.sh"
printf '%s\n' 'module_order+=second' \
  >"$CBC_MODULE_ROOT/02-second/cbc-module.sh"

fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
module_order=""
module_dir=caller-sentinel
shopt -s nullglob
source "$repo_root/custom_bash_commands.sh" >"$HOME/startup-output"
[[ "$module_order" == firstsecond ]] || fail 'Module load order changed.'
[[ "$module_dir" == caller-sentinel ]] || fail 'Module iterator leaked.'
shopt -q nullglob || fail 'Loader disabled the caller nullglob option.'
[[ "$(<"$HOME/startup-output")" == *'missing cbc-module.sh: missing'* ]] ||
  fail 'Missing-entrypoint warning disappeared.'
shopt -u nullglob
cbc_pkg_source_modules auto >/dev/null
if shopt -q nullglob; then fail 'Loader enabled nullglob.'; fi

# Config is data, including comments, quotes, whitespace, and invalid values.
printf '%s\n' '# comment' '  # indented comment' \
  ' CBC_SHOW_BANNER = "YES" # comment' \
  "CBC_SOURCE_BASH_ALIASES='0'" 'CBC_LIST_SHOW_DESCRIPTIONS=1' \
  'CBC_BANNER_MODE=MINIMAL' 'CBC_USE_GUM=FALSE' \
  'CBC_SHOW_BANNER=invalid' 'PATH=must-not-assign' \
  'CBC_SHOW_BANNER=$(touch must-not-execute)' >"$CBC_CONFIG_FILE"
saved_path="$PATH"
cbc_config_load
[[ "$CBC_SHOW_BANNER" == true && "$CBC_SOURCE_BASH_ALIASES" == false &&
  "$CBC_LIST_SHOW_DESCRIPTIONS" == true && "$CBC_BANNER_MODE" == minimal &&
  "$CBC_USE_GUM" == false && "$PATH" == "$saved_path" ]] ||
  fail 'Config compatibility changed.'
printf '%s' 'CBC_SHOW_BANNER=no' >"$CBC_CONFIG_FILE"
cbc_config_load
[[ "$CBC_SHOW_BANNER" == false ]] || fail 'Unterminated config lost.'

# The ordinary banner must not launch Gum. Explicit RGB still uses it.
gum() { printf 'gum called\n' >>"$HOME/gum-calls"; }
CBC_GUM_ACTIVE=true
CBC_BANNER_MODE=minimal
CBC_OMARCHY_COLORS_FILE=""
export TERM=xterm-256color CLICOLOR_FORCE=1
unset NO_COLOR
output="$(display_version)"
[[ "$output" == $'\e[33m'"$CBC_VERSION"$'\e[0m' ]] ||
  fail 'Minimal banner styling changed.'
[[ ! -f "$HOME/gum-calls" ]] || fail 'Banner launched Gum.'
NO_COLOR=1 output="$(NO_COLOR=1 display_version)"
[[ "$output" == "$CBC_VERSION" ]] || fail 'NO_COLOR was ignored.'
unset NO_COLOR CLICOLOR_FORCE
output="$(display_version)"
[[ "$output" == "$CBC_VERSION" ]] || fail 'Redirected output has ANSI.'
CBC_BANNER_MODE=full
output="$(display_version)"
[[ "$output" == *'CUSTOM BASH COMMANDS (by iop098321qwe)'* &&
  "$output" == *"$CBC_VERSION"* && "$output" == *"WIKI: 'wiki'"* ]] ||
  fail 'Full banner content changed.'
CBC_OMARCHY_COLORS_FILE="$HOME/palette.toml"
printf '%s\n' 'foreground = "#abcdef"' >"$CBC_OMARCHY_COLORS_FILE"
display_version >/dev/null
[[ -s "$HOME/gum-calls" ]] || fail 'RGB rendering bypassed Gum.'
unset -f gum

# No subshells, external commands, or manifest writes on normal startup.
mkdir -p "$HOME/empty-modules"
CBC_MODULE_ROOT="$HOME/empty-modules"
mkdir -p "$CBC_MODULE_ROOT/lazy-fixture"
printf '%s\n' 'cbc_lazy_register "$HOME/deferred.sh" startup_deferred' \
  >"$CBC_MODULE_ROOT/lazy-fixture/cbc-module.sh"
CBC_OMARCHY_COLORS_FILE=""
printf '%s\n' 'CBC_SHOW_BANNER=false' 'CBC_USE_GUM=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_FILE"
export CBC_MODULE_ROOT
bash --noprofile --norc -c '
  set -T
  trap '\''if ((BASH_SUBSHELL)); then
    printf "subshell\n" >>"$HOME/subshells"
  fi'\'' DEBUG
  source "$1"
' _ "$repo_root/custom_bash_commands.sh"
[[ ! -e "$HOME/subshells" && ! -e "$CBC_PACKAGE_MANIFEST" ]] ||
  fail 'Startup forked or wrote package metadata.'

cbc_doctor_time_call duration true
[[ "$duration" =~ ^[0-9]+$ ]] || fail 'Timing result is not numeric.'
if cbc_doctor_time_call duration false; then
  fail 'Timing helper lost the command failure status.'
fi

# Exercise the real installer in its required path under the fixture home.
# This also checks that the core still ships as the existing two-file layout.
install_repo="$HOME/Documents/github_repositories/custom_bash_commands"
mkdir -p "$install_repo"
cp "$repo_root/custom_bash_commands.sh" "$repo_root/cbc_aliases.sh" \
  "$repo_root/install_cbc.sh" "$install_repo/"
printf '%s\n' 'source "$HOME/.custom_bash_commands.sh"' \
  'declare -F cbc_lazy_register >/dev/null || return 1' >"$HOME/.bashrc"
(
  builtin cd "$install_repo"
  sleep() { :; }
  export -f sleep
  bash install_cbc.sh >/dev/null
)
cmp "$repo_root/custom_bash_commands.sh" "$HOME/.custom_bash_commands.sh"
cmp "$repo_root/cbc_aliases.sh" "$HOME/.cbc_aliases.sh"
printf '%s\n' 'PASS: startup config, modules, banner, and timing'
