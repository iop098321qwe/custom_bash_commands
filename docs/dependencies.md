# Dependencies

## Required

- bash
- git
- curl
- sed
- awk
- find
- xargs
- man
- xdg-open
- setsid
- env and external kill (cancel parallel Git fetch process groups)
- mktemp
- Python 3.10 or newer
- fzf
- bat or batcat
- eza
- imv-x11
- nvim
- wl-copy

## Strongly Recommended

- gum (required when `CBC_USE_GUM=true`)

## Documentation Builds

- pip, installed inside the Python virtual environment
- Zensical, installed from `requirements-docs.txt`

## Release Tooling

- Node.js 22 or newer for `commit-and-tag-version` 13.3.0 (verified version)
- npm/npx to run `commit-and-tag-version`
- The optional `verg` wrapper is provided by the `commit-and-tag-version`
  CBC module and uses the repository's `.versionrc.cjs` automatically.
