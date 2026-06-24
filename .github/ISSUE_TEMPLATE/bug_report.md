---
name: Bug report
about: Report a CBC command, alias, installer, config, module, or docs bug
title: ""
labels: ""
assignees: ""
---

## Summary

Describe the failing Custom Bash Commands (CBC) behavior and the affected
workflow.

## Affected Area

Select all that apply:

- `cbc` subcommand or helper function
- `cbc_aliases.sh` alias
- `install_cbc.sh` installer
- `cbc config` or `~/.config/cbc/cbc.config`
- `cbc pkg` module management
- Startup sourcing or shell initialization
- Documentation, links, or release references
- Other:

## Environment

- CBC version (`display_version` or `dv`):
- Linux distribution and version:
- Bash version (`bash --version`):
- Terminal emulator:
- Install method (`./install_cbc.sh`, manual copy, or `cbc update`):
- Repository path:
- Config path if customized:
- Relevant config values (`CBC_USE_GUM`, banner settings, and aliases):

## Dependencies

Mention any relevant tool versions, missing commands, or path issues.

- `gum`:
- `git`:
- `curl`:
- `fzf`:
- `eza`:
- `bat` or `batcat`:
- `wl-copy`:
- Other:

## Steps To Reproduce

1. Start a new shell or source `~/.custom_bash_commands.sh`.
2. Run `...`.
3. Observe `...`.

## Actual Behavior

Paste the exact output, error message, or terminal behavior.

```text
...
```

## Expected Behavior

Describe what CBC should have done instead.

## Diagnostics

If the bug involves startup, config, modules, updates, dependencies, or styled
output, include relevant command output.

```bash
cbc doctor
cbc doctor startup
cbc list -v
```

```text
Paste output here.
```

## Additional Context

Add screenshots, recordings, module manifest entries, config snippets, or links
when they help explain the bug.
