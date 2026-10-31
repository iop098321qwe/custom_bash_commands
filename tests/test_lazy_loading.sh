#!/usr/bin/env bash
# Synthetic definition-only modules exercise the shared lazy-loading contract.
set -eo pipefail
repo_root="$PWD"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home" CBC_CONFIG_DIR="$test_home/config"
export CBC_MODULE_ROOT="$test_home/modules"
export CBC_PACKAGE_MANIFEST="$test_home/packages.toml"
mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT"
: >"$HOME/.cbc_aliases.sh"
printf '%s\n' 'CBC_SHOW_BANNER=false' 'CBC_USE_GUM=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_DIR/cbc.config"
source "$repo_root/custom_bash_commands.sh"
cbc -h >/dev/null
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

implementation="$HOME/implementation with spaces.sh"
cat >"$implementation" <<'EOF'
lazy_fixture() {
  lazy_helper "$@"
  export LAZY_FIXTURE_STATE=changed
  cd "$HOME"
  return 7
}
lazy_helper() { printf '<%s>\n' "$@"; }
EOF
cbc_lazy_register "$implementation" lazy_fixture lazy_helper
[[ "$(declare -f lazy_fixture)" == "${CBC_LAZY_STUBS[lazy_fixture]}" ]] ||
  fail 'Wrapper identity does not match Bash.'
declare -F lazy_fixture >/dev/null || fail 'Command discovery failed.'
complete -W 'fixture-value' lazy_fixture
complete -p lazy_fixture >/dev/null || fail 'Completion registration failed.'
status=0
lazy_fixture 'two words' '' '*.txt' >"$HOME/result" || status=$?
[[ "$status" == 7 && "$LAZY_FIXTURE_STATE" == changed &&
  "$PWD" == "$HOME" ]] || fail 'Status or current-shell effects lost.'
[[ "$(<"$HOME/result")" == $'<two words>\n<>\n<*.txt>' ]] ||
  fail 'Argument forwarding changed.'
[[ ${#CBC_LAZY_FILES[@]} == 0 ]] || fail 'Loaded wrappers stayed registered.'
# Deleting the source after first use must not affect subsequent calls.
rm "$implementation"
lazy_fixture again >/dev/null || status=$?
[[ "$status" == 7 ]] || fail 'Second invocation tried to reload.'

# Load another command from the same group without overwriting user changes.
cat >"$implementation" <<'EOF'
lazy_fixture() { lazy_helper "$@"; }
lazy_helper() { printf 'implementation\n'; }
EOF
cbc_lazy_register "$implementation" lazy_fixture lazy_helper
lazy_helper() { printf 'user override\n'; }
[[ "$(lazy_fixture)" == 'user override' ]] || fail 'User override lost.'
cbc_lazy_register "$implementation" lazy_fixture lazy_helper
unset -f lazy_helper
status=0
lazy_fixture >/dev/null 2>&1 || status=$?
[[ "$status" == 127 ]] || fail 'An explicitly unset helper was restored.'
if declare -F lazy_helper >/dev/null; then fail 'Unset override lost.'; fi
lazy_fixture() { printf 'later module\n'; }
# Reload registration deliberately restores the entrypoint's ownership.
cbc_lazy_register "$implementation" lazy_fixture lazy_helper
[[ "$(lazy_fixture)" == implementation ]] || fail 'Reload kept stale code.'

# Restoration must not expand aliases in an already parsed function again.
cbc_lazy_register "$implementation" lazy_fixture lazy_helper
lazy_helper() { printf 'alias-safe\n'; }
shopt -s expand_aliases
alias printf='printf duplicate'
output="$(lazy_fixture)"
unalias printf
shopt -u expand_aliases
[[ "$output" == alias-safe ]] || fail 'Override aliases expanded twice.'

# First use must parse with registration-time aliases, then restore callers.
cat >"$HOME/alias-implementation.sh" <<'EOF'
lazy_alias_fixture() { lazy_action; }
EOF
shopt -s expand_aliases
alias lazy_action='printf "registered\n"'
cbc_lazy_register "$HOME/alias-implementation.sh" lazy_alias_fixture
alias lazy_action='printf "caller\n"'
lazy_alias_fixture >"$HOME/alias-result"
[[ "$(<"$HOME/alias-result")" == registered &&
  "${BASH_ALIASES[lazy_action]}" == 'printf "caller\n"' ]] ||
  fail 'Registration-time alias parsing or caller aliases changed.'
unalias lazy_action
shopt -u expand_aliases

# Missing, incomplete, failed, and recursive loads must fail and be retryable.
cbc_lazy_register "$HOME/missing.sh" lazy_missing
if lazy_missing 2>/dev/null; then fail 'Missing implementation succeeded.'; fi
printf '%s\n' 'lazy_missing() { printf "repaired\n"; }' >"$HOME/missing.sh"
[[ "$(lazy_missing)" == repaired ]] || fail 'Missing-file retry failed.'
printf '%s\n' 'true' >"$HOME/incomplete.sh"
cbc_lazy_register "$HOME/incomplete.sh" lazy_incomplete
if lazy_incomplete 2>/dev/null; then fail 'Missing definition succeeded.'; fi
printf '%s\n' 'lazy_incomplete() { :; }' 'return 9' >"$HOME/incomplete.sh"
status=0
lazy_incomplete 2>/dev/null || status=$?
[[ "$status" == 9 && "$(declare -f lazy_incomplete)" == \
  "${CBC_LAZY_STUBS[lazy_incomplete]}" ]] ||
  fail 'Partial load not rolled back.'
printf '%s\n' 'lazy_incomplete() { printf "retry\n"; }' >"$HOME/incomplete.sh"
[[ "$(lazy_incomplete)" == retry ]] || fail 'Partial-load retry failed.'
printf '%s\n' 'lazy_recursive' >"$HOME/recursive.sh"
cbc_lazy_register "$HOME/recursive.sh" lazy_recursive
if lazy_recursive 2>/dev/null; then fail 'Recursive load succeeded.'; fi
[[ ${#CBC_LAZY_LOADING[@]} == 0 ]] || fail 'Recursion guard stayed set.'
if cbc_lazy_register "$implementation" valid_name 'bad;name' 2>/dev/null; then
  fail 'Unsafe identifier accepted.'
fi
if declare -F valid_name >/dev/null; then
  fail 'Registration was not atomic.'
fi
printf '%s\n' 'PASS: lazy discovery, state, overrides, reload, and recovery'
