#!/usr/bin/env bash
# Run from the repository root: bash tests/test_manifest_dates.sh
set -eo pipefail
repo_root="$PWD"
test_home="$(mktemp -d)"
trap 'rm -rf -- "$test_home"' EXIT
export HOME="$test_home" CBC_CONFIG_DIR="$test_home/config"
export CBC_MODULE_ROOT="$test_home/modules"
export CBC_PACKAGE_MANIFEST="$test_home/packages.toml"
export GIT_CONFIG_NOSYSTEM=1 GIT_CONFIG_GLOBAL=/dev/null
export GIT_AUTHOR_NAME=Fixture GIT_COMMITTER_NAME=Fixture
export GIT_AUTHOR_EMAIL=fixture@example.com
export GIT_COMMITTER_EMAIL=fixture@example.com
mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT" "$HOME/plain"
: >"$HOME/.cbc_aliases.sh"
printf '%s\n' 'CBC_SHOW_BANNER=false' 'CBC_USE_GUM=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_DIR/cbc.config"
source "$repo_root/custom_bash_commands.sh"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }
timestamp='^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9:]{8}[+]00:00$'

# Registration is not installation; even non-Git copies get a timestamp.
cbc pkg install "$HOME/plain" >/dev/null
! grep -q installed_at "$CBC_PACKAGE_MANIFEST" || fail 'Premature date.'
cbc_pkg_align_with_manifest >/dev/null
cbc_pkg_read_manifest
[[ "${CBC_MANIFEST_INSTALLED_AT[0]}" =~ $timestamp ]] || fail 'Copy date.'
[[ -z "${CBC_MANIFEST_COMMIT_DATES[0]}" ]] || fail 'Non-Git commit date.'

git init --quiet --initial-branch=main "$HOME/gitmod"
: >"$HOME/gitmod/cbc-module.sh"
git -C "$HOME/gitmod" add cbc-module.sh
GIT_COMMITTER_DATE='2020-02-03T04:05:06-05:00' \
  git -C "$HOME/gitmod" commit --quiet -m fixture
cbc pkg install "$HOME/gitmod" >/dev/null
cbc_pkg_align_with_manifest >/dev/null
cbc_pkg_read_manifest
[[ "${CBC_MANIFEST_COMMIT_DATES[1]}" == \
  '2020-02-03T04:05:06-05:00' ]] || fail 'Commit offset lost.'
[[ "${CBC_MANIFEST_INSTALLED_AT[1]}" =~ $timestamp ]] || fail 'Git date.'

# A sentinel makes no-op preservation deterministic without sleeping.
CBC_MANIFEST_INSTALLED_AT[1]='2001-01-01T00:00:00+00:00'
cbc_pkg_write_manifest
cbc_pkg_align_with_manifest >/dev/null
cbc_pkg_read_manifest
[[ "${CBC_MANIFEST_INSTALLED_AT[1]}" == \
  '2001-01-01T00:00:00+00:00' ]] || fail 'No-op changed install date.'
cbc pkg uninstall plain >/dev/null
cbc_pkg_read_manifest
[[ "${CBC_MANIFEST_INSTALLED_AT[0]}" == \
  '2001-01-01T00:00:00+00:00' ]] || fail 'Removal misaligned dates.'
[[ "${CBC_MANIFEST_COMMIT_DATES[0]}" == \
  '2020-02-03T04:05:06-05:00' ]] || fail 'Removal lost commit date.'

# Legacy manifests backfill only facts available from Git.
sed -i '/commit_date =/d; /installed_at =/d' "$CBC_PACKAGE_MANIFEST"
cbc_pkg_align_with_manifest >/dev/null
cbc_pkg_read_manifest
[[ -n "${CBC_MANIFEST_COMMIT_DATES[0]}" ]] || fail 'Legacy commit date.'
[[ -z "${CBC_MANIFEST_INSTALLED_AT[0]}" ]] || fail 'Invented history.'
printf 'Manifest timestamp checks passed.\n'
