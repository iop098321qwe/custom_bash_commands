# Custom Bash Commands

Custom Bash Commands (CBC) is a Bash-based toolkit for Linux shells. This
minimal Zensical site verifies that the documentation build is configured and
ready for GitHub Pages.

## Available Pages

- [Dependencies](dependencies.md)
- [Standard Operating Procedures](standard_operating_procedures.md)
- [TODO](todo.md)

## Local Preview

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements-docs.txt
zensical serve
```

## Static Build

```bash
zensical build --clean
```
