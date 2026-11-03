#!/usr/bin/env bash
# Run from the repository root: bash tests/test_pkg_update.sh
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
mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT"
: >"$HOME/.cbc_aliases.sh"
printf '%s\n' 'CBC_SHOW_BANNER=false' 'CBC_USE_GUM=false' \
  'CBC_SOURCE_BASH_ALIASES=false' >"$CBC_CONFIG_DIR/cbc.config"
source "${1:-$repo_root/custom_bash_commands.sh}"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

# Each module has a deleted upstream and a surviving default branch.
for jobs in 1 4; do
  CBC_MODULE_ROOT="$HOME/modules-$jobs"
  mkdir -p "$CBC_MODULE_ROOT"
  CBC_MANIFEST_USES=() CBC_MANIFEST_REVS=() CBC_MANIFEST_HASHES=()
  for name in projectmod smartsort; do
    default=main
    [[ "$name" == smartsort ]] && default=develop
    remote="$HOME/$name-$jobs.git"
    seed="$HOME/seed-$name-$jobs"
    module="$CBC_MODULE_ROOT/$name"
    git init --bare --quiet --initial-branch="$default" "$remote"
    git clone --quiet "$remote" "$seed" 2>/dev/null
    printf '%s\n' \
      'cbc_lazy_register "${BASH_SOURCE[0]%/*}/impl.sh" fixture_'"$name" \
      >"$seed/cbc-module.sh"
    printf 'fixture_%s() { printf "old\\n"; }\n' "$name" >"$seed/impl.sh"
    git -C "$seed" add cbc-module.sh impl.sh
    git -C "$seed" commit --quiet -m 'fixture: initial module'
    git -C "$seed" push --quiet origin "$default"
    git -C "$seed" push --quiet origin HEAD:lazy-feature
    git clone --quiet "$remote" "$module"
    git -C "$module" checkout --quiet -b lazy-feature origin/lazy-feature
    cbc_pkg_capture_state "$module" old_rev old_hash
    cbc_pkg_record_manifest "fixture/$name" "$old_rev" "$old_hash"
    printf 'fixture_%s() { printf "new\\n"; }\n' "$name" >"$seed/impl.sh"
    git -C "$seed" commit --quiet -am 'fixture: updated implementation'
    git -C "$seed" push --quiet origin "$default" :lazy-feature
    source "$module/cbc-module.sh"
    # Load one implementation eagerly to also test replacement on update.
    if [[ "$name" == projectmod ]]; then
      fixture_projectmod >"$HOME/old-output"
      [[ "$(<"$HOME/old-output")" == old ]] || fail 'Initial load failed.'
    fi
  done
  cbc_pkg_write_manifest
  cbc pkg update --jobs "$jobs" >"$HOME/update-output"
  [[ "$(<"$HOME/update-output")" != *'No upstream detected'* ]] ||
    fail 'Deleted upstream prevented update.'
  cbc_pkg_read_manifest
  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    name="${CBC_MANIFEST_USES[$idx]##*/}"
    module="$CBC_MODULE_ROOT/$name"
    expected="$(git --git-dir="$HOME/$name-$jobs.git" rev-parse HEAD)"
    [[ "$(git -C "$module" rev-parse HEAD)" == "$expected" &&
      "${CBC_MANIFEST_HASHES[$idx]}" == "$expected" ]] ||
      fail "Commit or manifest not updated for $name (jobs=$jobs)."
    resolved=""
    cbc_pkg_resolve_remote_head "fixture/$name" "$module" resolved true
    [[ "$resolved" == "$expected" ]] ||
      fail 'Live remote fallback did not resolve the default branch.'
    [[ "$(declare -f "fixture_$name")" == \
      "${CBC_LAZY_STUBS[fixture_$name]}" ]] || fail 'Reload was not lazy.'
    "fixture_$name" >"$HOME/new-output"
    [[ "$(<"$HOME/new-output")" == new ]] || fail 'Stale implementation.'
  done
done

# A valid nondefault upstream must win over origin/HEAD.
git -C "$module" branch --set-upstream-to=origin/main >/dev/null 2>&1 ||
  git -C "$module" branch --set-upstream-to=origin/develop >/dev/null
git -C "$module" update-ref refs/remotes/origin/alternate HEAD~1
git -C "$module" config branch.lazy-feature.merge refs/heads/alternate
resolved=""
cbc_pkg_resolve_remote_head fixture/smartsort "$module" resolved false
[[ "$resolved" == "$(git -C "$module" rev-parse HEAD~1)" ]] ||
  fail 'Valid upstream was not preferred.'
git -C "$module" branch --unset-upstream
cbc_pkg_resolve_remote_head fixture/smartsort "$module" resolved false
[[ "$resolved" == "$(git -C "$module" rev-parse origin/HEAD)" ]] ||
  fail 'Missing upstream did not fall back to default.'
# Newer Git can recreate origin/HEAD on fetch; retain the missing-ref case.
git -C "$module" config remote.origin.followRemoteHEAD never
git -C "$module" symbolic-ref --delete refs/remotes/origin/HEAD
cbc_pkg_resolve_remote_head fixture/smartsort "$module" resolved false
[[ -z "$resolved" ]] || fail 'Missing default produced a bogus revision.'
cbc pkg update --jobs 1 >"$HOME/skipped-output"
[[ "$(<"$HOME/skipped-output")" == *'No upstream detected'* ]] ||
  fail 'Missing default was not reported as skipped.'

# Rebased feature commits can leave a clean but diverged local branch.
module="$CBC_MODULE_ROOT/projectmod"
seed="$HOME/seed-projectmod-4"
printf '%s\n' '# local history' >>"$module/impl.sh"
git -C "$module" commit --quiet -am 'fixture: local history'
printf '%s\n' '# remote history' >>"$seed/impl.sh"
git -C "$seed" commit --quiet -am 'fixture: remote history'
git -C "$seed" push --quiet origin main
before="$(git -C "$module" rev-parse HEAD)"
cbc pkg update --jobs 1 >"$HOME/failed-output" 2>"$HOME/failed-error"
[[ "$(<"$HOME/failed-output")" == *'Update failed'* &&
  "$(<"$HOME/failed-error")" == *'Not possible to fast-forward'* ]] ||
  fail 'Diverged update did not report the Git failure.'
[[ "$(git -C "$module" rev-parse HEAD)" == "$before" ]] ||
  fail 'Failed update changed the installed commit.'

# Exercise real Gum when available: failures must retain Git diagnostics.
if command -v gum >/dev/null 2>&1; then
  gum() {
    printf '%s\n' "$@" >"$HOME/spinner-args"
    command gum "$@"
  }
  CBC_GUM_ACTIVE=true
  status=0
  cbc_spinner 'Updating diverged fixture' \
    git -C "$module" merge --ff-only --quiet origin/HEAD \
    >"$HOME/spinner-error" 2>&1 || status=$?
  [[ $'\n'"$(<"$HOME/spinner-args")"$'\n' == *$'\n--show-error\n'* &&
    "$status" -ne 0 &&
    "$(<"$HOME/spinner-error")" == *'Not possible to fast-forward'* ]] ||
    fail 'Gum hid the Git failure or changed its exit status.'
fi
printf '%s\n' 'PASS: upstream fallback, updates, lazy reloads, and failures'
