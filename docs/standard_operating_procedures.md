# Standard Operating Procedures (SOPs)

## Table of Contents

1. [Purpose](#purpose)
2. [Scope](#scope)
3. [Guiding Principles](#guiding-principles)
4. [Creating New Functions](#creating-new-functions)
5. [Creating New Aliases](#creating-new-aliases)
6. [Keeping `cbc list` Accurate](#keeping-cbc-list-accurate)
7. [Documentation Updates](#documentation-updates)
8. [Manual Testing Checklist](#manual-testing-checklist)

## Purpose

Define consistent, reliable steps for adding CBC functions and aliases so the
codebase, discovery commands, and docs stay aligned.

## Scope

These procedures apply to updates in:

- `custom_bash_commands.sh` (functions and helper logic)
- `cbc_aliases.sh` (alias catalog)
- `docs/` (supporting documentation)

## Guiding Principles

- Keep changes grouped with related commands for faster discovery.
- Provide clear, user-facing help text for every function.
- Ensure `cbc list` remains the single source of truth for command discovery.
- Update docs whenever behavior changes or new workflows are added.

## Creating New Functions

Functions live in `custom_bash_commands.sh`. Follow the existing section
layout, and include a `usage()` helper that supports `-h`.

```bash
################################################################################
# FUNCTION NAME
################################################################################

function_name() {
  usage() {
    # Describe purpose, usage, options, and examples.
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    *)
      # Error handling
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Function logic here.
}
```

Steps:

1. Add the function near related functions in `custom_bash_commands.sh`.
2. Include `usage()` and `-h` handling consistent with existing patterns.
3. Update the `cbc list` arrays so the function appears in both the catalog and
   detailed descriptions.
4. Update `docs/` if the new function changes usage, dependencies, or user
   workflow.

## Creating New Aliases

Aliases live in `cbc_aliases.sh`. Keep them grouped under the existing
section headers (CBC-specific, single-letter, `eza`, Python, and so on).

```bash
alias alias_name='alias_command'
```

Steps:

1. Add the alias near related aliases in `cbc_aliases.sh`.
2. Update the alias lists in `cbc list` so `cbc list` and `cbc list -v` stay
   accurate.
3. Update `docs/` if the alias changes workflows or expected dependencies.

## Keeping `cbc list` Accurate

`cbc list` is the primary discovery command. When adding or removing functions
or aliases, update these arrays in `custom_bash_commands.sh`:

- `functions`
- `aliases`
- `function_details`
- `alias_details`

## Documentation Updates

Update documentation whenever you change behavior, dependencies, or user
workflows:

- `docs/standard_operating_procedures.md` for process changes.
- `docs/dependencies.md` when new tools are required or removed.
- `README.md` when the user-facing workflow changes or new commands are added.

## Manual Testing Checklist

No automated tests are tracked. Validate changes manually:

1. Source the updated scripts or open a new shell session.
2. Run the new function or alias with `-h` to confirm usage text.
3. Run `cbc list` and `cbc list -v` to confirm catalogs are current.
4. Verify any external commands used by the change are available.
