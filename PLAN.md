# CBC AUR and alias-module migration plan

## Purpose and status

Prepare Custom Bash Commands (CBC) for AUR installation while preserving
its role as the module loader, package manager, and shell entry point.
Move general-purpose aliases into user-approved CBC modules.

Status: planning draft preserved at repository-root `PLAN.md` for future
work. No migration implementation, module creation, package construction,
or AUR publication has occurred. Preserving and committing this document
does not authorize executing its tasks.

Repository baseline inspected: `CBC_VERSION="v4.2.0"`.
Recheck the actual source and repository instructions before execution.
Checkpoints below are acceptance gates, not assumptions of completion.

## Confirmed user decisions

- CBC remains the module loader and entry point. Keep `cbc pkg` in core.
- `cbc_aliases.sh` should contain only CBC-specific shortcuts.
- General-purpose aliases belong in separately selected CBC modules.
- Prioritize AUR installation, retain a portable core, retire the existing
  home-copy installer, and document manual sourcing without a separate
  core self-updater.
- The user creates new modules manually using `mkmod` under
  `/home/grymm/Documents/github_repositories/cbc_modules`.
- Ask the user about alias destinations, record the answer, and only then
  plan the agreed extraction. Do not silently exclude any alias.
- Modules must be created and prepared before packaging and completing
  the transition to AUR installation.
- Use Conventional Commits. The requested branch workflow is
  `nbccpr feature` for preserving this plan in the repository.
- At completion, ask whether the plan is complete to the user's liking.
  Remove this plan only after explicit permission.

## Operating rules for future sessions

1. Read this plan, `AGENTS.md`, and current repository state first.
2. Summarize the next incomplete gate and any newly discovered conflicts.
3. Preserve unapproved behaviors; ask before expanding scope.
4. Record approved decisions and evidence after each completed phase.
5. Distinguish proposed, user-approved, implemented, and verified states.
6. Never read, modify, stage, commit, or otherwise touch `todo.txt`.
7. Never edit `CHANGELOG.md` manually or with AI. Use release tooling.
8. Do not modify the user's live shell configuration automatically.
9. Do not run `mkmod` or create module repositories for the user.
10. Ask separately before publishing to GitHub or the AUR, creating tags,
    installing on the live system, or deleting legacy user files.

## Phase 0: approve and preserve the plan

### Branch and commit workflow

- Inspect the branch, default remote branch, and worktree read-only.
- Proposed branch: `feature/plan-aur-alias-migration`.
- Select the base using the Conventional Branch and nbccpr skills.
- Do not treat a feature branch as a reason to use `feat` for a plan.
- Re-read the applicable skills before executing the workflow.
- Do not use broad staging or stashing that would touch `todo.txt`.
- If pre-existing changes cannot be isolated without touching protected
  files, stop and ask. Preserve user changes and exclude them from commits.
- Commit the approved repository plan with a short explanatory body:

  ```text
  docs(plan): define CBC AUR and alias-module migration
  ```

- Audit `AGENTS.md` after adding root `PLAN.md`; include its tracked-file
  entry and any necessary guidance in a separate documentation commit.
- Stage only explicit in-scope paths. Keep README/AGENTS changes in their
  own documentation commit, separate from the plan and implementation.
- Verify the branch before committing and pushing. Push only that branch
  with upstream tracking and verify the created commits reached it.
- Do not amend published history without explicit authorization.
- No pull request is implied solely by the `nbccpr` command.

Acceptance: user approves the plan; its repository copy is committed and
pushed; implementation has not started implicitly. Storing the draft does
not imply approval of its contents or permission to start migration.

## Phase 1: baseline and architecture decisions

Record existing behavior before changing it:

- Main script and alias sourcing order, including `~/.bash_aliases`.
- Config parsing, terminal palettes, banner behavior, and shell options.
- Eager module entrypoints and `cbc_lazy_register` behavior.
- Manifest dates, updates, deleted-upstream fallback, and error handling.
- Installed-file diagnostics and startup profiling assumptions.
- Public commands and functions used by existing modules.
- Dependencies genuinely required by core versus optional commands.

Run existing isolated regression tests and save results. Measure startup
separately, not concurrently with other benchmarks.

### Decisions requiring user approval

1. Final AUR name, upstream release source, and AUR maintainer account.
   `custom-bash-commands` is a proposal, not a checked available name.
2. Packaged file layout and portable script/alias path resolution.
3. Treatment of `ucbc`, `cbc update`, and `cbc update check`.
4. Whether `cbc test` becomes a development-only reload command or retires.
5. Keep, change, or remove default sourcing of `~/.bash_aliases`.
6. Alias collision policy and documented user-override order.
7. Whether packages need enable/disable state separate from installation.
8. Whether existing module metadata can support discovery or needs a small
   explicit registration API for aliases and descriptions.
9. Compatibility window, breaking-release version, and migration notices.
10. System module directories are out of scope unless expressly approved;
    retain user-managed CBC modules rather than add unnecessary machinery.

Acceptance: record approved answers before implementing affected behavior.

## Phase 2: interactive alias inventory and decisions

There are 27 alias definitions in the current catalog, including the
conditional Ubuntu-family `bat` alias. The entries below preserve the
current definitions; none is approved for removal or modification.
Code blocks preserve exact existing commands and are line-length exceptions.

### CBC-specific aliases: confirm retention and semantics

```bash
alias dv='display_version'
alias ucbc='cbc update'
```

- `dv`: proposed to remain in `cbc_aliases.sh`; ask for confirmation.
- `ucbc`: proposed to remain CBC-specific, but its future behavior must
  be agreed with the replacement for core self-updating.

### Shell and session helpers: destination unresolved

```bash
alias editbash='$EDITOR ~/.bashrc'
alias refresh='source ~/.bashrc && clear'
alias seebash='bat ~/.bashrc'
alias c='clear'
alias s='sudo'
alias x='chmod +x'
```

Discuss grouping versus separate modules. Note `$EDITOR` handling and
the `bat` dependency; moving aliases does not authorize fixing them.

### Manual-page helper: destination unresolved

```bash
alias fman='compgen -c | fzf | xargs man'
```

Discuss `fzf`, `man`, and pipeline behavior before deciding its module.

### Image viewer: destination unresolved

```bash
alias imv='imv-x11'
```

Confirm desired behavior on the user's Wayland desktop; do not silently
replace the viewer or change this alias while extracting it.

### Network and privilege helpers: destinations unresolved

```bash
alias myip='curl http://ipecho.net/plain; echo'
alias please='sudo $(history -p !!)'
```

Discuss the plain HTTP third-party endpoint and history expansion risks.
Any HTTPS, endpoint, quoting, or functional change needs approval separate
from the move. These aliases need not share one module.

### Editor aliases: destination unresolved

```bash
alias vim='nvim'
alias v='nvim'
```

Confirm whether both should remain together, with `nvim` as a dependency.

### Eza aliases: destination unresolved

```bash
alias la="eza --icons=always --group-directories-first -a"
alias lar="eza --icons=always -r --group-directories-first -a"
alias le="eza --icons=always --group-directories-first -s extension"
alias ll="eza --icons=always --group-directories-first --smart-group --total-size -hl"
alias llt="eza --icons=always --group-directories-first --smart-group --total-size -hlT"
alias lsd="eza --icons=always --group-directories-first -D"
alias ls="eza --icons=always --group-directories-first"
alias lsf="eza --icons=always --group-directories-first -f"
alias lsr="eza --icons=always --group-directories-first -r"
alias lt="eza --icons=always --group-directories-first -T"
```

Proposed discussion topic: a single eza alias module. Confirm all ten,
including replacing `ls`, icon assumptions, and total-size behavior.

### Python aliases: destination unresolved

```bash
alias py='python3'
alias python='python3'
```

Confirm both separately; overriding `python` can affect virtual environment
expectations. Do not remove it on that basis without user approval.

### Conditional bat compatibility: destination unresolved

```bash
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID_LIKE" in
    *ubuntu*)
      alias bat='batcat'
      ;;
  esac
fi
```

Preserve the existing condition in the inventory. Decide whether this
belongs in a portability module, another module, or an explicitly approved
retirement. AUR-first does not by itself authorize dropping portability.

### Required interactive procedure

For each alias or user-approved group:

1. Show its exact definition, dependencies, and current side effects.
2. Ask: keep in core, move to which existing/new module, or retire?
3. Ask whether to preserve exact behavior or plan a separate change.
4. Record the answer for every alias; a group answer must name its members.
5. Agree a module name and repository identity; do not invent either.
6. Ask the user to create it with `mkmod` in the confirmed module directory.
7. Verify the actual `mkmod` interface with the user before giving commands.
8. Wait for the user to confirm the module exists and is ready to inspect.
9. Record its path, entrypoint, source, version, and remaining work.
10. Validate the prepared module before marking aliases ready to extract.

Track each alias using these fields as decisions arrive:

- Alias name and original definition.
- User-approved destination and approval reference.
- Behavior changes, if any, explicitly approved separately.
- Module created by user: pending/confirmed.
- Module prepared and tests passed: pending/verified.
- Removed from core: not started/implemented.
- Replacement load and discovery: pending/verified.

Acceptance: every alias has an explicit disposition. Every replacement
module exists and is prepared before removing its aliases or starting
package construction. Retired aliases require explicit approval too.

## Phase 3: prepare and verify user-created modules

- Inspect the actual scaffold and existing CBC module conventions.
- Confirm whether module edits are performed by the user or authorized
  for the implementation agent; manual creation remains the user's task.
- Keep aliases eager in entrypoints; lazy registration is for appropriate
  function implementations, not a substitute for defining aliases.
- Define dependencies, descriptions, supported environments, and licensing.
- Preserve alias spelling and behavior except for approved changes.
- Document installation using the existing `cbc pkg` source contract.
- Agree repository publication, versions, and credentials independently.
  Local validation does not require publishing every module immediately.
- Test each module alone and together in isolated homes and Bash shells.
- Verify repeated sourcing, deterministic order, missing dependencies,
  user overrides, and command discovery.
- Note that uninstalling a module does not automatically undo aliases in
  an already-running shell; agree and document reload/new-shell behavior.
- Verify a usable installation source and record any publication blocker.

Acceptance: user confirms modules are ready, and every moved alias has a
verified replacement. Do not finish the AUR transition with missing modules.

## Phase 4: package-compatible core and workflow retirement

### Paths and startup

- Proposed shared files: `/usr/share/cbc/custom_bash_commands.sh` and
  `/usr/share/cbc/cbc_aliases.sh`; approve the final layout first.
- Resolve bundled files relative to the sourced script, using Bash-safe
  techniques and no new external startup processes.
- Keep runtime config, manifests, and modules in user-controlled paths.
- Do not write package-owned files at runtime or require root for `cbc pkg`.
- Document one explicit sourcing line for the user's `.bashrc`.
- Do not automatically enable CBC system-wide via `/etc/profile.d`.
- Preserve no-network startup and no automatic manifest installation.
- Preserve lazy-loading, error recovery, colors, and banner controls.

### Remove or replace obsolete behavior deliberately

- Retire `install_cbc.sh` after replacing references and installer tests.
  Do not reuse it inside `package()` or an installation hook.
- Remove canonical clone-location checks and installer-created personal
  directories. Manual sourcing must work from arbitrary trusted locations.
- Remove the core sparse-checkout updater and home-file overwrite logic.
- Replace or retire `cbc update` only after its user-approved decision.
  Prefer actionable package-manager guidance over invoking privileged
  upgrades implicitly. Do not conflate core and module updates.
- Retain `cbc pkg update` and its Git/manifest behavior.
- Decide whether upstream release checks remain informational; do not
  misreport a newer upstream version as an available AUR package update.
- Adapt or retire `cbc test` without losing a safe development reload path.
- Update `ucbc`, help, completion if present, examples, and diagnostics.
- Audit startup profiling and doctor for installed-file path assumptions.
- Keep structured JSON diagnostics compatible where possible; explicitly
  version/document unavoidable schema changes rather than silently drift.
- Replace the hard-coded general alias catalog with agreed module-aware
  discovery. Distinguish available commands from actually loaded aliases.
- Keep GitHub Pages, upstream release tooling, version bumping, and release
  updater tests unless evidence shows a specific part is obsolete.
  AUR packaging does not itself replace those workflows.
- Check catalog entries such as `dotfiles` against real definitions before
  changing them; resolve existing drift without inventing implementations.

Acceptance: portable and packaged layouts work, core aliases are approved,
and no supported core workflow overwrites package-managed files.

## Phase 5: legacy installation migration and rollback

1. Detect legacy home scripts and sourcing lines read-only.
2. Explain duplicate sourcing, stale aliases, and old updater hazards.
3. Provide user-run backup and migration instructions; never source an
   entire live `.bashrc` merely to test packaging.
4. Verify module replacements and preserve config and manifest data.
5. Have the user replace the old sourcing line with the packaged path.
6. Verify a fresh shell and rollback path before optional cleanup.
7. Ask separately before removing old home files or backup copies.

Rollback must restore the user's previous sourcing arrangement and retain
module/config data. Package removal must not delete anything in `$HOME`.
Existing shells can retain old functions and aliases; document restarting
them rather than promising that replacing files resets shell state.

Acceptance: document and test both fresh installation and legacy migration
in temporary homes; obtain user approval before live-system migration.

## Phase 6: build the Arch package

Only start package construction after the module preparation gate passes.
Check current Arch packaging guidance when implementing.

- Choose where packaging sources live and who maintains the AUR Git repo.
- Create `PKGBUILD` and generated `.SRCINFO`; do not assume a GitHub push
  publishes either to the AUR.
- Package a pinned stable release archive with verified checksums.
- Use release `pkgver` without its leading `v`; increment `pkgrel` for
  packaging-only revisions. Confirm actual release/tag naming first.
- Assess `arch=('any')` for architecture-independent shell content.
- Select the correct license identifier from actual upstream licensing.
- Install read-only shared scripts and appropriate documentation; shell
  functions do not require a misleading standalone `cbc` executable.
- Separate hard core dependencies from optional feature dependencies.
  Python, Node, and documentation tooling must not become runtime
  dependencies merely because development uses them.
- Reassess dependencies formerly required solely by general aliases.
  Their module docs should own those requirements.
- Avoid unnecessary `.install` hooks; never edit home files or run CBC as
  root during installation, upgrade, or removal.
- Use appropriate file modes and staged `$pkgdir` paths.
- Avoid overlapping files or redundant `provides`/`conflicts` declarations.
- Validate source archive contents, tag/version agreement, and checksums.
- Generate metadata with `makepkg --printsrcinfo` and review it.
- Run `namcap` and an Arch clean-chroot build; review justified warnings.
- Verify package contents and that no development secrets or personal
  paths enter the archive.

Acceptance: reproducible package recipe, clean build, reviewed metadata,
and isolated install/upgrade/remove checks pass without home mutations.

## Phase 7: regression, integration, and documentation gates

Run and adapt existing checks, retaining their original guarantees:

```bash
bash tests/test_startup.sh
bash tests/test_lazy_loading.sh
bash tests/test_manifest_dates.sh
bash tests/test_pkg_update.sh
bash tests/test_theme_reload.sh
python3 tests/test_doctor.py
python3 tests/test_banner.py
node --test tests/test_version_updater.cjs
python3 tests/benchmark_startup.py --runs 40
```

Add focused tests for:

- Arbitrary manual source paths and packaged source paths.
- Packaged core alias lookup, including paths containing spaces.
- No legacy alias requirement or misleading missing-alias warning.
- All approved module aliases and conditional behavior.
- User alias precedence and repeated module reloads.
- Discovery without phantom aliases or stale updater commands.
- Core updates cannot overwrite files; module updates still work.
- Read-only shared files and independent multi-user runtime state.
- No network, package builds, or subprocess regressions at startup.
- Preserved Bash shell options and current-shell effects.
- Package installation/removal leave user config and modules untouched.
- Legacy transition, duplicate sourcing, fresh-shell behavior, rollback.
- User-confirmed supported Omarchy 4.5 stable environment smoke test.

Update `README.md`, SOPs, dependencies, command references, and help.
Add migration and maintainer release instructions. Run the documented
Zensical clean build when documentation changes. Audit `AGENTS.md` after
changes, including tracked files, paths, test commands, and architecture.

Acceptance: record exact commands, results, skipped checks, and blockers.
Do not declare unrun live-system or AUR installation tests successful.

## Phase 8: release and AUR publication

- Confirm whether the incompatible install/alias changes need a major
  release; do not choose a version without approval.
- Preview and use the existing release tooling to update `CBC_VERSION`,
  tags, and generated changelog. Never hand-edit the changelog.
- Ensure the upstream release exists before finalizing AUR source URLs.
- Rebuild from the actual released archive and regenerate `.SRCINFO`.
- Obtain explicit approval to publish the AUR package and module sources.
- Push packaging to the separate AUR Git repository with reviewed metadata.
- Verify the AUR page and an exact-name install using `yay`.
- No Omarchy stable mirror promotion is required for direct AUR installs.
  Inclusion in Omarchy's prebuilt repository is a separate process.
- Record maintainer responsibilities for new releases, checksum updates,
  packaging revisions, AUR comments, and compatibility testing.

Acceptance: core installation, module installation, fresh-shell loading,
core upgrade, module upgrade, and package removal are verified or clearly
recorded as awaiting authorized testing.

## Implementation commit guide

Use actual change impact, not a blanket `feat` type. Example boundaries:

```text
refactor(core): resolve bundled scripts relative to the source file
feat(discovery): list aliases registered by loaded CBC modules
refactor(aliases)!: move general aliases into opt-in modules
feat(update)!: replace core self-updates with package guidance
build(arch): package CBC for AUR installation
test(migration): cover packaged startup and legacy installation
docs(migration): explain AUR installation and alias module setup
```

These are provisional headers; select them from the actual approved diff.
Pair tests with behavior where appropriate. Use breaking-change footers to
explain required user action. Keep README/AGENTS-only documentation commits
separate. Commit modules in their own repositories with user authorization.
Never include unrelated user changes or manually edited changelog content.

## Completion and approved plan removal

Do not delete this document just because implementation appears finished.

1. Review every gate, alias disposition, unresolved decision, and test.
2. Present delivered changes, module locations, installation instructions,
   maintenance obligations, and any remaining limitations to the user.
3. Ensure durable docs contain the necessary information from this plan.
4. Ask explicitly: "Is PLAN.md complete to your liking, and do you give
   permission to remove it?"
5. If approval is withheld, preserve the plan and address requested work.
6. If permission is granted, remove only the approved plan copy/copies.
   Ask which copies if repository and external drafts both still exist.
7. Update `AGENTS.md` to remove any stale tracked-plan reference, and commit
   that documentation separately as required by repository conventions.
8. Commit repository plan removal with an appropriate header and body, for
   example `docs(plan): remove the completed CBC migration plan`.
9. Push only under applicable authorization and report final verification.

## Resume point

Next action: user review of this draft and explicit authorization to begin
migration planning or implementation. Repository preservation is authorized
separately and does not start the migration. All per-alias destinations
remain pending.
Start Phase 2 discussions with CBC-specific aliases, then proceed through
the inventory at the user's preferred pace. No alias disappears merely
because its proposed module has not been created yet.
