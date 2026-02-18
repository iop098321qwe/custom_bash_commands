#!/usr/bin/env bash
CBC_VERSION="v306.21.0"

################################################################################
# CUSTOM BASH COMMANDS (by iop098321qwe)
################################################################################

CBC_CONFIG_DIR="${CBC_CONFIG_DIR:-$HOME/.config/cbc}"
CBC_MODULE_ROOT="${CBC_MODULE_ROOT:-$CBC_CONFIG_DIR/modules}"
CBC_PACKAGE_MANIFEST="${CBC_PACKAGE_MANIFEST:-$CBC_CONFIG_DIR/packages.toml}"
CBC_MODULE_ENTRYPOINT="cbc-module.sh"
CBC_CONFIG_FILE="$CBC_CONFIG_DIR/cbc.config"

CBC_SHOW_BANNER="true"
CBC_BANNER_MODE="full"
CBC_SOURCE_BASH_ALIASES="true"
CBC_LIST_SHOW_DESCRIPTIONS="false"

################################################################################
# CBC CONFIG
################################################################################

cbc_config_trim() {
  local text="$1"
  printf "%s" "$text" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

cbc_config_normalize_bool() {
  local value="${1,,}"

  case "$value" in
  true | yes | 1)
    printf '%s' "true"
    return 0
    ;;
  false | no | 0)
    printf '%s' "false"
    return 0
    ;;
  *)
    return 1
    ;;
  esac
}

cbc_config_apply() {
  local key="$1"
  local value="$2"
  local normalized=""

  case "$key" in
  CBC_SHOW_BANNER)
    if normalized=$(cbc_config_normalize_bool "$value"); then
      CBC_SHOW_BANNER="$normalized"
    fi
    ;;
  CBC_BANNER_MODE)
    value="${value,,}"
    case "$value" in
    full | minimal)
      CBC_BANNER_MODE="$value"
      ;;
    esac
    ;;
  CBC_SOURCE_BASH_ALIASES)
    if normalized=$(cbc_config_normalize_bool "$value"); then
      CBC_SOURCE_BASH_ALIASES="$normalized"
    fi
    ;;
  CBC_LIST_SHOW_DESCRIPTIONS)
    if normalized=$(cbc_config_normalize_bool "$value"); then
      CBC_LIST_SHOW_DESCRIPTIONS="$normalized"
    fi
    ;;
  esac
}

cbc_config_load() {
  [ -f "$CBC_CONFIG_FILE" ] || return 0

  local line=""
  local key=""
  local value=""

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(cbc_config_trim "$line")"

    if [ -z "$line" ]; then
      continue
    fi

    case "$line" in
    *=*)
      key="$(cbc_config_trim "${line%%=*}")"
      value="$(cbc_config_trim "${line#*=}")"
      value="${value%\"}"
      value="${value#\"}"
      value="${value%\'}"
      value="${value#\'}"
      cbc_config_apply "$key" "$value"
      ;;
    esac
  done <"$CBC_CONFIG_FILE"
}

cbc_config_load

###############################################################################
# GUM HELPERS
###############################################################################

CATPPUCCIN_ROSEWATER="#f5e0dc"
CATPPUCCIN_FLAMINGO="#f2cdcd"
CATPPUCCIN_PINK="#f5c2e7"
CATPPUCCIN_MAUVE="#cba6f7"
CATPPUCCIN_RED="#f38ba8"
CATPPUCCIN_MAROON="#eba0ac"
CATPPUCCIN_PEACH="#fab387"
CATPPUCCIN_YELLOW="#f9e2af"
CATPPUCCIN_GREEN="#a6e3a1"
CATPPUCCIN_TEAL="#94e2d5"
CATPPUCCIN_SKY="#89dceb"
CATPPUCCIN_SAPPHIRE="#74c7ec"
CATPPUCCIN_BLUE="#89b4fa"
CATPPUCCIN_LAVENDER="#b4befe"
CATPPUCCIN_TEXT="#cdd6f4"
CATPPUCCIN_SUBTEXT="#a6adc8"
CATPPUCCIN_OVERLAY="#6c7086"
CATPPUCCIN_SURFACE0="#313244"
CATPPUCCIN_SURFACE1="#45475a"
CATPPUCCIN_SURFACE2="#585b70"
CATPPUCCIN_BASE="#1e1e2e"

cbc_style_box() {
  local border_color="$1"
  shift
  gum style \
    --border rounded \
    --border-foreground "$border_color" \
    --foreground "$CATPPUCCIN_TEXT" \
    --background "$CATPPUCCIN_SURFACE0" \
    --padding "0 2" \
    --margin "0 0 1 0" \
    "$@"
}

cbc_style_message() {
  local color="$1"
  shift
  gum style \
    --foreground "$color" \
    --background "$CATPPUCCIN_BASE" \
    "$@"
}

cbc_style_note() {
  local title="$1"
  shift
  gum style \
    --border normal \
    --border-foreground "$CATPPUCCIN_LAVENDER" \
    --foreground "$CATPPUCCIN_TEXT" \
    --background "$CATPPUCCIN_SURFACE1" \
    --padding "0 2" \
    --margin "0 0 1 0" \
    "$title" "$@"
}

cbc_confirm() {
  local prompt="$1"
  shift
  gum confirm \
    --prompt.foreground "$CATPPUCCIN_LAVENDER" \
    --selected.foreground "$CATPPUCCIN_GREEN" \
    --selected.background "$CATPPUCCIN_SURFACE1" \
    --unselected.foreground "$CATPPUCCIN_RED" \
    "$prompt"
}

cbc_input() {
  local prompt="$1"
  shift
  local placeholder="$1"
  shift
  gum input \
    --prompt.foreground "$CATPPUCCIN_LAVENDER" \
    --cursor.foreground "$CATPPUCCIN_GREEN" \
    --prompt "$prompt" \
    --placeholder "$placeholder"
}

cbc_spinner() {
  local title="$1"
  shift
  gum spin --spinner dot --title "$title" --title.foreground "$CATPPUCCIN_MAUVE" -- "$@"
}

################################################################################
# CBC MODULE LOADER
################################################################################

cbc_pkg_trim() {
  local text="$1"
  printf "%s" "$text" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

cbc_pkg_ensure_config() {
  mkdir -p "$CBC_CONFIG_DIR" "$CBC_MODULE_ROOT"
}

cbc_pkg_module_name_from_use() {
  local use="$1"
  local name="${use##*/}"
  name="${name%.git}"
  printf "%s" "$name"
}

cbc_pkg_resolve_source() {
  local use="$1"
  local -n out_source="$2"
  local -n out_module_name="$3"

  out_source="$use"
  out_module_name="$(cbc_pkg_module_name_from_use "$use")"

  if [ -d "$use" ]; then
    out_source="$(cd "$use" && pwd)"
    out_module_name="$(basename "$out_source")"
    return
  fi

  if [[ "$use" =~ :// ]] || [[ "$use" == git@*:* ]]; then
    return
  fi

  if [[ "$use" == */* ]]; then
    out_source="https://github.com/${use}.git"
  fi
}

cbc_pkg_directory_checksum() {
  local dir="$1"
  if ! command -v sha256sum >/dev/null 2>&1; then
    echo ""
    return
  fi

  find "$dir" -type f ! -path "*/.git/*" -print0 2>/dev/null |
    sort -z |
    xargs -0 sha256sum 2>/dev/null |
    sha256sum 2>/dev/null |
    awk '{print $1}'
}

cbc_pkg_collect_metadata() {
  local use="$1"
  local source="$2"
  local -n out_rev="$3"
  local -n out_hash="$4"

  out_rev=""
  out_hash=""

  if ! command -v git >/dev/null 2>&1; then
    return
  fi

  if [ -d "$source/.git" ]; then
    out_rev="$(git -C "$source" rev-parse --short HEAD 2>/dev/null || true)"
    out_hash="$(git -C "$source" rev-parse HEAD 2>/dev/null || true)"
    return
  fi

  if [ -d "$source" ]; then
    out_hash="$(cbc_pkg_directory_checksum "$source")"
    out_rev="local"
    return
  fi

  local remote_hash
  remote_hash="$(git ls-remote "$source" HEAD 2>/dev/null | awk 'NR==1 {print $1}')"

  if [ -n "$remote_hash" ]; then
    out_hash="$remote_hash"
    out_rev="${remote_hash:0:7}"
  fi
}

cbc_pkg_capture_state() {
  local module_dir="$1"
  local -n out_rev="$2"
  local -n out_hash="$3"

  out_rev=""
  out_hash=""

  if [ -d "$module_dir/.git" ] && command -v git >/dev/null 2>&1; then
    out_rev="$(git -C "$module_dir" rev-parse --short HEAD 2>/dev/null || true)"
    out_hash="$(git -C "$module_dir" rev-parse HEAD 2>/dev/null || true)"
  else
    out_hash="$(cbc_pkg_directory_checksum "$module_dir")"
    out_rev="local"
  fi
}

cbc_pkg_read_manifest() {
  CBC_MANIFEST_USES=()
  CBC_MANIFEST_REVS=()
  CBC_MANIFEST_HASHES=()

  [ -f "$CBC_PACKAGE_MANIFEST" ] || return 0

  local current_use=""
  local current_rev=""
  local current_hash=""

  while IFS= read -r line || [ -n "$line" ]; do
    line="${line%%#*}"
    line="$(cbc_pkg_trim "$line")"

    if [ -z "$line" ]; then
      continue
    fi

    if [ "$line" = "[[module.deps]]" ]; then
      if [ -n "$current_use" ]; then
        CBC_MANIFEST_USES+=("$current_use")
        CBC_MANIFEST_REVS+=("$current_rev")
        CBC_MANIFEST_HASHES+=("$current_hash")
      fi

      current_use=""
      current_rev=""
      current_hash=""
      continue
    fi

    local key="$(cbc_pkg_trim "${line%%=*}")"
    local value="$(cbc_pkg_trim "${line#*=}")"

    value="${value%\"}"
    value="${value#\"}"

    case "$key" in
    use)
      current_use="$value"
      ;;
    rev)
      current_rev="$value"
      ;;
    hash)
      current_hash="$value"
      ;;
    esac
  done <"$CBC_PACKAGE_MANIFEST"

  if [ -n "$current_use" ]; then
    CBC_MANIFEST_USES+=("$current_use")
    CBC_MANIFEST_REVS+=("$current_rev")
    CBC_MANIFEST_HASHES+=("$current_hash")
  fi
}

cbc_pkg_write_manifest() {
  cbc_pkg_ensure_config

  {
    echo "# Generated by cbc pkg. Manual edits may be overwritten."
    echo ""
    for idx in "${!CBC_MANIFEST_USES[@]}"; do
      local use="${CBC_MANIFEST_USES[$idx]}"
      local rev="${CBC_MANIFEST_REVS[$idx]}"
      local hash="${CBC_MANIFEST_HASHES[$idx]}"

      echo "[[module.deps]]"
      echo "use = \"${use}\""
      echo "rev = \"${rev}\""
      echo "hash = \"${hash}\""
      echo ""
    done
  } >"$CBC_PACKAGE_MANIFEST"
}

cbc_pkg_record_manifest() {
  local use="$1"
  local rev="$2"
  local hash="$3"

  local updated=false
  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    if [ "${CBC_MANIFEST_USES[$idx]}" = "$use" ]; then
      CBC_MANIFEST_REVS[$idx]="$rev"
      CBC_MANIFEST_HASHES[$idx]="$hash"
      updated=true
      break
    fi
  done

  if [ "$updated" = false ]; then
    CBC_MANIFEST_USES+=("$use")
    CBC_MANIFEST_REVS+=("$rev")
    CBC_MANIFEST_HASHES+=("$hash")
  fi
}

cbc_pkg_resolve_remote_head() {
  local use="$1"
  local module_dir="$2"
  local -n out_remote="$3"
  local refresh_remote="${4:-true}"

  out_remote=""

  if ! command -v git >/dev/null 2>&1; then
    return
  fi

  if [ -d "$module_dir/.git" ]; then
    local upstream
    upstream="$(git -C "$module_dir" rev-parse --abbrev-ref --symbolic-full-name '@{u}' 2>/dev/null || true)"

    if [ -n "$upstream" ]; then
      if [ "$refresh_remote" = true ]; then
        git -C "$module_dir" fetch --quiet 2>/dev/null || true
      fi

      out_remote="$(git -C "$module_dir" rev-parse "$upstream" 2>/dev/null || true)"
      return
    fi

    if [ "$refresh_remote" = true ]; then
      out_remote="$(git -C "$module_dir" ls-remote origin HEAD 2>/dev/null | awk 'NR==1 {print $1}')"
      return
    fi

    out_remote="$(git -C "$module_dir" rev-parse origin/HEAD 2>/dev/null || true)"
    return
  fi

  local source=""
  local module_name=""
  cbc_pkg_resolve_source "$use" source module_name

  if [ "$refresh_remote" = true ]; then
    out_remote="$(git ls-remote "$source" HEAD 2>/dev/null | awk 'NR==1 {print $1}')"
  fi
}

cbc_pkg_update_status_line() {
  local use="$1"
  local module_dir="$2"
  local manifest_rev="$3"
  local manifest_hash="$4"

  if [ ! -d "$module_dir" ]; then
    echo "Status: Not installed; run 'cbc pkg load'."
    return
  fi

  if ! command -v git >/dev/null 2>&1; then
    echo "Status: Current (git unavailable; update checks skipped.)"
    return
  fi

  local current_rev=""
  local current_hash=""
  cbc_pkg_capture_state "$module_dir" current_rev current_hash

  local remote_head=""
  cbc_pkg_resolve_remote_head "$use" "$module_dir" remote_head

  if [ -n "$remote_head" ] && [ "$remote_head" != "$current_hash" ]; then
    echo "Status: UPDATE AVAILABLE"
    return
  fi

  if [ -n "$manifest_hash" ] && [ "$current_hash" != "$manifest_hash" ]; then
    echo "Status: UPDATE AVAILABLE"
    return
  fi

  if [ -n "$manifest_hash" ] && [ -n "$remote_head" ] &&
    [ "$remote_head" != "$manifest_hash" ]; then
    echo "Status: UPDATE AVAILABLE"
    return
  fi

  echo "Status: Current"
}

cbc_pkg_align_with_manifest() {
  cbc_pkg_read_manifest

  local git_available=true
  if ! command -v git >/dev/null 2>&1; then
    git_available=false

    if [ ${#CBC_MANIFEST_USES[@]} -gt 0 ]; then
      cbc_style_message "$CATPPUCCIN_YELLOW" \
        "Git unavailable; cloning remote modules will be skipped."
    fi
  fi

  local manifest_changed=false

  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    local use="${CBC_MANIFEST_USES[$idx]}"
    local manifest_rev="${CBC_MANIFEST_REVS[$idx]}"
    local manifest_hash="${CBC_MANIFEST_HASHES[$idx]}"

    local source=""
    local module_name=""
    cbc_pkg_resolve_source "$use" source module_name
    local module_dir="$CBC_MODULE_ROOT/$module_name"

    if [ ! -d "$module_dir" ]; then
      if [ -d "$source" ]; then
        if cbc_spinner "Copying module $module_name" \
          cp -R "$source" "$module_dir"; then
          cbc_style_message "$CATPPUCCIN_GREEN" \
            "Installed '$module_name' from local path in packages.toml."
        else
          cbc_style_message "$CATPPUCCIN_MAROON" \
            "Failed to copy '$module_name' from $source."
          continue
        fi
      elif [ "$git_available" = true ]; then
        if cbc_spinner "Cloning $module_name" \
          git clone "$source" "$module_dir"; then
          cbc_style_message "$CATPPUCCIN_GREEN" \
            "Installed '$module_name' from manifest."
        else
          cbc_style_message "$CATPPUCCIN_MAROON" \
            "Failed to clone '$module_name' from $source."
          continue
        fi
      else
        cbc_style_message "$CATPPUCCIN_MAROON" \
          "Cannot install '$module_name'; git is unavailable."
        continue
      fi
    fi

    local current_rev=""
    local current_hash=""
    cbc_pkg_capture_state "$module_dir" current_rev current_hash

    if [ "$current_rev" != "$manifest_rev" ] || [ "$current_hash" != "$manifest_hash" ]; then
      cbc_pkg_record_manifest "$use" "$current_rev" "$current_hash"
      manifest_changed=true
    fi
  done

  if [ "$manifest_changed" = true ]; then
    cbc_pkg_write_manifest
  fi
}

cbc_pkg_install() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Record a CBC module source in packages.toml."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg install <creator/repo|git-url|path>"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc pkg install creator/example-module" \
      "  cbc pkg install https://github.com/creator/example-module.git" \
      "  cbc pkg install ~/dev/example-module"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -eq 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "No module source provided. Use 'cbc pkg install <creator/repo>' or a git URL."
    return 1
  fi

  if [ $# -gt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  local use="$1"
  if [[ "$use" == -* ]]; then
    cbc_style_message "$CATPPUCCIN_RED" "Invalid option: $use"
    return 1
  fi

  cbc_pkg_ensure_config
  cbc_pkg_read_manifest

  local source=""
  local module_name=""
  cbc_pkg_resolve_source "$use" source module_name

  local detected_rev=""
  local detected_hash=""
  cbc_pkg_collect_metadata "$use" "$source" detected_rev detected_hash

  cbc_pkg_record_manifest "$use" "$detected_rev" "$detected_hash"
  cbc_pkg_write_manifest

  local status_note=""
  if [ -n "$detected_rev" ]; then
    status_note="Pinned at rev ${detected_rev:-unknown}."
  else
    status_note="Revision details unavailable; will capture during load."
  fi

  cbc_style_message "$CATPPUCCIN_GREEN" \
    "Recorded '$use' in packages.toml. Run 'cbc pkg load' to install." \
    "${status_note}"
}

cbc_pkg_uninstall() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Remove a CBC module from packages.toml and local modules."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg uninstall <creator/repo|module-name>"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc pkg uninstall creator/example-module" \
      "  cbc pkg uninstall example-module"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -eq 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "No module provided. Use 'cbc pkg uninstall <creator/repo|module-name>'."
    return 1
  fi

  if [ $# -gt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  local use="$1"
  if [[ "$use" == -* ]]; then
    cbc_style_message "$CATPPUCCIN_RED" "Invalid option: $use"
    return 1
  fi

  cbc_pkg_ensure_config
  cbc_pkg_read_manifest

  local source=""
  local module_name=""
  cbc_pkg_resolve_source "$use" source module_name
  local module_dir="$CBC_MODULE_ROOT/$module_name"

  local new_uses=()
  local new_revs=()
  local new_hashes=()
  local removed=false

  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    local current_use="${CBC_MANIFEST_USES[$idx]}"
    local current_name
    current_name="$(cbc_pkg_module_name_from_use "$current_use")"

    if [ "$current_use" = "$use" ] || [ "$current_name" = "$module_name" ]; then
      removed=true
      continue
    fi

    new_uses+=("$current_use")
    new_revs+=("${CBC_MANIFEST_REVS[$idx]}")
    new_hashes+=("${CBC_MANIFEST_HASHES[$idx]}")
  done

  if [ "$removed" = true ]; then
    CBC_MANIFEST_USES=("${new_uses[@]}")
    CBC_MANIFEST_REVS=("${new_revs[@]}")
    CBC_MANIFEST_HASHES=("${new_hashes[@]}")
    cbc_pkg_write_manifest
  fi

  local removed_local=false
  if [ -d "$module_dir" ]; then
    if cbc_spinner "Removing $module_name" rm -rf -- "$module_dir"; then
      removed_local=true
    else
      cbc_style_message "$CATPPUCCIN_MAROON" \
        "Failed to remove local files for '$module_name'."
    fi
  fi

  if [ "$removed" = true ] || [ "$removed_local" = true ]; then
    local removal_targets=()
    if [ "$removed" = true ]; then
      removal_targets+=("packages.toml")
    fi
    if [ "$removed_local" = true ]; then
      removal_targets+=("local modules")
    fi

    cbc_style_message "$CATPPUCCIN_GREEN" \
      "Removed '$module_name' from ${removal_targets[*]}." \
      "Restart your shell to fully unload sourced functions."
  else
    cbc_style_message "$CATPPUCCIN_YELLOW" \
      "No matching module found in packages.toml or local modules."
  fi
}

cbc_pkg_list() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  List CBC modules and their update status."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg list"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  cbc pkg list"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  cbc_pkg_ensure_config
  cbc_pkg_read_manifest

  local found=false
  local manifest_modules=()

  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    local use="${CBC_MANIFEST_USES[$idx]}"
    local manifest_hash="${CBC_MANIFEST_HASHES[$idx]}"
    local manifest_rev="${CBC_MANIFEST_REVS[$idx]}"

    local source=""
    local module_name=""
    cbc_pkg_resolve_source "$use" source module_name
    local module_dir="$CBC_MODULE_ROOT/$module_name"
    manifest_modules+=("$module_name")

    local last_update="Unknown"

    if [ -d "$module_dir/.git" ] && command -v git >/dev/null 2>&1; then
      last_update="$(git -C "$module_dir" log -1 --format=%cs 2>/dev/null || echo "Unknown")"
    elif [ -d "$module_dir" ]; then
      last_update="$(date -r "$module_dir" +%Y-%m-%d 2>/dev/null || echo "Unknown")"
    fi

    local status_line
    status_line="$(cbc_pkg_update_status_line "$use" "$module_dir" "$manifest_rev" "$manifest_hash")"

    if [ -d "$module_dir" ]; then
      cbc_style_box "$CATPPUCCIN_BLUE" "Module: $module_name" \
        "  Use: $use" \
        "  Recorded rev: ${manifest_rev:-unknown}" \
        "  Last update: $last_update" \
        "  $status_line"
    else
      cbc_style_box "$CATPPUCCIN_SAPPHIRE" "Module: $module_name" \
        "  Use: $use" \
        "  Recorded rev: ${manifest_rev:-unknown}" \
        "  Last update: $last_update" \
        "  Status: Not present locally; will synchronize on next load."
    fi

    found=true
  done

  shopt -s nullglob
  for module_dir in "$CBC_MODULE_ROOT"/*; do
    [ -d "$module_dir" ] || continue

    local module_name="$(basename "$module_dir")"
    if [[ " ${manifest_modules[*]} " == *" $module_name "* ]]; then
      continue
    fi

    found=true

    local status_line
    status_line="$(cbc_pkg_update_status_line "$module_name" "$module_dir" "" "")"

    cbc_style_box "$CATPPUCCIN_MAUVE" "Module: $module_name" \
      "  Use: Local install (not tracked in packages.toml)" \
      "  Last update: $(date -r "$module_dir" +%Y-%m-%d 2>/dev/null || echo "Unknown")" \
      "  $status_line"
  done
  shopt -u nullglob

  if [ "$found" = false ]; then
    cbc_style_message "$CATPPUCCIN_YELLOW" \
      "No CBC modules installed. Use 'cbc pkg install <creator/repo>' to add one."
  fi
}

cbc_pkg_update() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Update installed CBC modules and refresh the manifest."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg update"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  cbc pkg update"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  if ! command -v git >/dev/null 2>&1; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "Git is required to update modules. Install git and try again."
    return 1
  fi

  cbc_pkg_ensure_config
  cbc_pkg_read_manifest

  local updated_modules=()
  local skipped_modules=()
  local manifest_changed=false

  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    local use="${CBC_MANIFEST_USES[$idx]}"
    local manifest_hash="${CBC_MANIFEST_HASHES[$idx]}"

    local source=""
    local module_name=""
    cbc_pkg_resolve_source "$use" source module_name
    local module_dir="$CBC_MODULE_ROOT/$module_name"

    if [ ! -d "$module_dir" ]; then
      skipped_modules+=("$module_name (not installed; run 'cbc pkg load')")
      continue
    fi

    if [ ! -d "$module_dir/.git" ]; then
      skipped_modules+=("$module_name (not a git repository)")
      continue
    fi

    if ! cbc_spinner "Checking $module_name for updates..." \
      git -C "$module_dir" fetch --quiet --prune; then
      skipped_modules+=("$module_name (unable to refresh remote)")
      continue
    fi

    local remote_head=""
    cbc_pkg_resolve_remote_head "$use" "$module_dir" remote_head false

    local current_rev=""
    local current_hash=""
    cbc_pkg_capture_state "$module_dir" current_rev current_hash

    if [ -z "$remote_head" ]; then
      skipped_modules+=("$module_name (no upstream detected)")
      continue
    fi

    if [ "$remote_head" = "$current_hash" ]; then
      if [ "$manifest_hash" != "$current_hash" ]; then
        cbc_pkg_record_manifest "$use" "$current_rev" "$current_hash"
        manifest_changed=true
      fi

      skipped_modules+=("$module_name (already current)")
      continue
    fi

    if [ -n "$manifest_hash" ] && [ "$remote_head" = "$manifest_hash" ]; then
      skipped_modules+=("$module_name (already matches manifest)")
      continue
    fi

    if cbc_spinner "Updating $module_name" \
      git -C "$module_dir" merge --ff-only --quiet "$remote_head"; then
      updated_modules+=("$module_name")

      local new_rev=""
      local new_hash=""
      cbc_pkg_capture_state "$module_dir" new_rev new_hash
      cbc_pkg_record_manifest "$use" "$new_rev" "$new_hash"
      manifest_changed=true
    else
      skipped_modules+=("$module_name (update failed)")
    fi
  done

  if [ "$manifest_changed" = true ]; then
    cbc_pkg_write_manifest
  fi

  if [ ${#updated_modules[@]} -gt 0 ]; then
    local updated_body="Updated Modules"

    for module_name in "${updated_modules[@]}"; do
      updated_body+=$'\n'"  - $module_name"
    done

    cbc_style_message "$CATPPUCCIN_GREEN" "$updated_body"
  fi

  if [ ${#skipped_modules[@]} -gt 0 ]; then
    local skipped_body="Skipped Modules"

    for module_name in "${skipped_modules[@]}"; do
      skipped_body+=$'\n'"  - $module_name"
    done

    cbc_style_message "$CATPPUCCIN_MAROON" "$skipped_body"
  fi

  if [ ${#updated_modules[@]} -eq 0 ] && [ ${#skipped_modules[@]} -eq 0 ]; then
    cbc_style_message "$CATPPUCCIN_YELLOW" \
      "No CBC modules installed. Use 'cbc pkg install <creator/repo>' to add one."
  fi

  cbc_pkg_load_modules auto
}

cbc_pkg_load_modules() {
  local auto_load="$1"
  shift || true

  cbc_pkg_ensure_config
  cbc_pkg_align_with_manifest

  local loaded_any=false
  local skipped_modules=()

  shopt -s nullglob
  for module_dir in "$CBC_MODULE_ROOT"/*; do
    [ -d "$module_dir" ] || continue

    local entrypoint="$module_dir/$CBC_MODULE_ENTRYPOINT"
    local module_name="$(basename "$module_dir")"

    if [ -f "$entrypoint" ]; then
      # shellcheck disable=SC1090
      source "$entrypoint"
      loaded_any=true
    else
      skipped_modules+=("$module_name")
    fi
  done
  shopt -u nullglob

  if [ "$loaded_any" = false ] && [ "$auto_load" != "auto" ]; then
    cbc_style_message "$CATPPUCCIN_YELLOW" \
      "No modules to load from $CBC_MODULE_ROOT."
  fi

  if [ ${#skipped_modules[@]} -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_MAROON" \
      "Skipped modules missing $CBC_MODULE_ENTRYPOINT: ${skipped_modules[*]}"
  fi
}

cbc_pkg_load() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Load CBC modules from packages.toml and local modules."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg load"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  cbc pkg load"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  cbc_pkg_load_modules
}

cbc_pkg() {
  OPTIND=1
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Manage CBC modules through the packages.toml manifest."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc pkg [subcommand]" \
      "  cbc pkg install <creator/repo|git-url|path>" \
      "  cbc pkg list" \
      "  cbc pkg load" \
      "  cbc pkg uninstall <creator/repo|module-name>" \
      "  cbc pkg update"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc pkg" \
      "  cbc pkg install creator/example-module" \
      "  cbc pkg load" \
      "  cbc pkg uninstall creator/example-module" \
      "  cbc pkg update"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  local subcommand="${1:-list}"
  if [ -n "$1" ]; then
    shift
  fi

  case "$subcommand" in
  install)
    cbc_pkg_install "$@"
    ;;
  list)
    cbc_pkg_list "$@"
    ;;
  load)
    cbc_pkg_load "$@"
    ;;
  uninstall)
    cbc_pkg_uninstall "$@"
    ;;
  update)
    cbc_pkg_update "$@"
    ;;
  *)
    cbc_style_message "$CATPPUCCIN_RED" "Unknown cbc pkg command: $subcommand"
    usage
    return 1
    ;;
  esac
}

################################################################################
# CBC CONFIG
################################################################################

cbc_config_write_defaults() {
  mkdir -p "$CBC_CONFIG_DIR"

  cat <<'EOF' >"$CBC_CONFIG_FILE"
# CBC configuration file
# Location: ~/.config/cbc/cbc.config
#
# Format:
#   KEY=VALUE
#
# Rules:
# - Lines starting with '#' are comments.
# - Blank lines are ignored.
# - Unknown keys are ignored.
# - Values are case-insensitive for booleans.
#
# Boolean values:
#   true | false | yes | no | 1 | 0
#
# Notes:
# - This file is read when CBC loads.
# - If a value is invalid, CBC keeps its default.
# - Only the settings below are supported right now.
#
# -------------------------------------------------------------------
# 1) Startup banner
# -------------------------------------------------------------------
#
# CBC_SHOW_BANNER
# Controls whether CBC prints the banner when a new interactive shell
# session starts.
#
# - true  = show the banner (default)
# - false = do not show the banner
#
# Default: true
#
CBC_SHOW_BANNER=true
#
# CBC_BANNER_MODE
# Controls how much banner information is printed.
#
# - full    = current behavior (two lines, including version + links)
# - minimal = a single line with the version only
#
# Default: full
#
CBC_BANNER_MODE=full
#
# -------------------------------------------------------------------
# 2) Alias sourcing
# -------------------------------------------------------------------
#
# CBC_SOURCE_BASH_ALIASES
# Controls whether CBC will source ~/.bash_aliases after loading
# CBC functions and aliases.
#
# - true  = source ~/.bash_aliases (default)
# - false = skip sourcing ~/.bash_aliases
#
# Default: true
#
CBC_SOURCE_BASH_ALIASES=true
#
# -------------------------------------------------------------------
# 3) cbc list output
# -------------------------------------------------------------------
#
# CBC_LIST_SHOW_DESCRIPTIONS
# Controls whether `cbc list` defaults to showing descriptions (the
# same output you get from `cbc list -v`).
#
# - true  = behave like `cbc list -v`
# - false = behave like `cbc list` (default)
#
# Default: false
#
CBC_LIST_SHOW_DESCRIPTIONS=false
EOF
}

cbc_config_edit() {
  local reset=false
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the CBC config file in your editor."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc config edit [--reset]" \
      "  cbc config -e [--reset]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h, --help  Display this help message" \
      "  --reset     Overwrite the config with defaults before editing"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc config edit" \
      "  cbc config edit --reset" \
      "  cbc config -e"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Notes:" \
      "  Uses \$EDITOR when available and falls back to nvim."
  }

  while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
      show_help=true
      shift
      ;;
    --reset)
      reset=true
      shift
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: $1"
      return 1
      ;;
    esac
  done

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ ! -f "$CBC_CONFIG_FILE" ] || [ "$reset" = true ]; then
    cbc_config_write_defaults
    cbc_style_message "$CATPPUCCIN_GREEN" \
      "Wrote CBC config to $CBC_CONFIG_FILE."
  fi

  local -a editor_cmd=()
  if [ -n "${EDITOR:-}" ]; then
    read -r -a editor_cmd <<<"$EDITOR"
    if [ ${#editor_cmd[@]} -eq 0 ] || ! command -v "${editor_cmd[0]}" >/dev/null 2>&1; then
      editor_cmd=()
    fi
  fi

  if [ ${#editor_cmd[@]} -eq 0 ] && command -v nvim >/dev/null 2>&1; then
    editor_cmd=(nvim)
  fi

  if [ ${#editor_cmd[@]} -eq 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "No editor found. Set \$EDITOR or install nvim."
    return 1
  fi

  "${editor_cmd[@]}" "$CBC_CONFIG_FILE"
}

cbc_config() {
  local force=false
  local edit=false
  local show_help=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Generate or edit the CBC config file."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc config [-f]" \
      "  cbc config edit [--reset]" \
      "  cbc config -e [--reset]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h, --help  Display this help message" \
      "  -f          Overwrite the existing config file" \
      "  -e          Edit the config file" \
      "  edit        Edit the config file"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc config" \
      "  cbc config -f" \
      "  cbc config edit" \
      "  cbc config edit --reset" \
      "  cbc config -e"
  }

  while [ $# -gt 0 ]; do
    case "$1" in
    -h | --help)
      show_help=true
      shift
      ;;
    -f)
      force=true
      shift
      ;;
    -e)
      edit=true
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
    esac
  done

  if [ "$show_help" = true ]; then
    if [ "$edit" = true ] || [ "${1:-}" = "edit" ]; then
      cbc_config_edit --help
    else
      usage
    fi
    return 0
  fi

  if [ "$edit" = true ] || [ "${1:-}" = "edit" ]; then
    if [ "$force" = true ]; then
      cbc_style_message "$CATPPUCCIN_RED" \
        "Option -f cannot be used with 'cbc config edit'."
      return 1
    fi

    if [ "${1:-}" = "edit" ]; then
      shift
    fi

    cbc_config_edit "$@"
    return
  fi

  if [ $# -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  if [ -f "$CBC_CONFIG_FILE" ] && [ "$force" = false ]; then
    cbc_style_message "$CATPPUCCIN_YELLOW" \
      "Config already exists at $CBC_CONFIG_FILE." \
      "Use 'cbc config -f' to overwrite."
    return 0
  fi

  cbc_config_write_defaults
  cbc_style_message "$CATPPUCCIN_GREEN" \
    "Wrote CBC config to $CBC_CONFIG_FILE."
}

cbc() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Entry point for CBC subcommands."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc [subcommand]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Subcommands:" \
      "  config Manage the CBC configuration file" \
      "  doctor Run CBC diagnostics" \
      "  list   List CBC commands and aliases" \
      "  pkg    Manage CBC modules (install, list, load, uninstall, update)" \
      "  test   Reload CBC from a local repo" \
      "  update Check for CBC updates" \
      "  -h     Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc config" \
      "  cbc config edit" \
      "  cbc doctor" \
      "  cbc list" \
      "  cbc list -v" \
      "  cbc pkg" \
      "  cbc pkg install creator/example-module" \
      "  cbc test" \
      "  cbc update check"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  local subcommand="$1"
  if [ -n "$subcommand" ]; then
    shift
  fi

  case "$subcommand" in
  "" | -h | --help)
    usage
    ;;
  config)
    cbc_config "$@"
    ;;
  doctor)
    cbc_doctor "$@"
    ;;
  list)
    cbc_list "$@"
    ;;
  pkg)
    cbc_pkg "$@"
    ;;
  test)
    cbc_test "$@"
    ;;
  update)
    cbc_update "$@"
    ;;
  *)
    cbc_style_message "$CATPPUCCIN_RED" "Unknown cbc subcommand: $subcommand"
    usage
    return 1
    ;;
  esac
}

################################################################################
# SOURCE ALIAS FILE
################################################################################

if [ -f "$HOME/.cbc_aliases.sh" ]; then
  # shellcheck disable=SC1090
  source "$HOME/.cbc_aliases.sh"
else
  cbc_style_message "$CATPPUCCIN_YELLOW" \
    "Alias file not found; skipping $HOME/.cbc_aliases.sh."
fi

################################################################################
# WIKI
################################################################################

wiki() {
  OPTIND=1

  # Define the CBC wiki URL
  local wiki_url="https://github.com/iop098321qwe/custom_bash_commands/wiki"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the Custom Bash Commands wiki in your default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  wiki [-h|-c|-C|-A|-F]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -c    Copy the wiki URL to the clipboard" \
      "  -C    Open the wiki to the cheatsheet page" \
      "  -A    Open the wiki to the aliases page" \
      "  -F    Open the wiki to the command reference page"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  wiki" \
      "  wiki -A"
  }

  while getopts ":hcCAF" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    c)
      echo "$wiki_url" | wl-copy
      cbc_style_message "$CATPPUCCIN_GREEN" "Wiki URL copied to clipboard."
      return 0
      ;;
    C)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Cheatsheet..."
      setsid -f xdg-open "$wiki_url/Cheatsheet" >/dev/null 2>&1
      return 0
      ;;
    A)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Alias Reference..."
      setsid -f xdg-open "$wiki_url/Alias-Reference" >/dev/null 2>&1
      return 0
      ;;
    F)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Command Reference..."
      setsid -f xdg-open "$wiki_url/Command-Reference" >/dev/null 2>&1
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening CBC wiki..."
      setsid -f xdg-open "$wiki_url" >/dev/null 2>&1
      return 0
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Function to open the CBC wiki in the default browser
  open_wiki() {
    setsid -f xdg-open "$wiki_url" >/dev/null 2>&1
  }

  # Call the open_wiki function
  open_wiki
}

################################################################################
# CHANGES
################################################################################

changes() {
  OPTIND=1

  # Define the CBC wiki URL
  local changelog_url="https://github.com/iop098321qwe/custom_bash_commands/blob/main/CHANGELOG.md"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the Custom Bash Commands changelog in your default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  changes [-h|-c]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -c    Copy the changelog URL to the clipboard"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  changes"
  }

  while getopts ":hc" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    c)
      echo "$changelog_url" | wl-copy
      cbc_style_message "$CATPPUCCIN_GREEN" "Changelog URL copied to clipboard."
      return 0
      ;;
    *)
      # invalid options
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  # Function to open the changelog in the default browser
  open_changelog() {
    setsid -f xdg-open "$changelog_url" >/dev/null 2>&1
  }

  # Call the open_changelog function
  open_changelog
}

################################################################################
# README
################################################################################

readme() {
  OPTIND=1

  local readme_url="https://github.com/iop098321qwe/custom_bash_commands/blob/main/README.md"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the Custom Bash Commands README in your default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  readme [-h|-c]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -c    Copy the README URL to the clipboard"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  readme"
  }

  while getopts ":hc" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    c)
      echo "$readme_url" | wl-copy
      cbc_style_message "$CATPPUCCIN_GREEN" "README URL copied to clipboard."
      return 0
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  open_readme() {
    setsid -f xdg-open "$readme_url" >/dev/null 2>&1
  }

  open_readme
}

################################################################################
# RELEASES
################################################################################

releases() {
  OPTIND=1

  # Define the CBC wiki URL
  local releases_url="https://github.com/iop098321qwe/custom_bash_commands/releases"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the Custom Bash Commands releases in your default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  releases [-h|-c]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -c    Copy the releases URL to the clipboard"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  releases"
  }

  while getopts ":hc" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    c)
      echo "$releases_url" | wl-copy
      cbc_style_message "$CATPPUCCIN_GREEN" "Changelog URL copied to clipboard."
      return 0
      ;;
    *)
      # invalid options
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  # Function to open the changelog in the default browser
  open_releases() {
    setsid -f xdg-open "$releases_url" >/dev/null 2>&1
  }

  # Call the open_releases function
  open_releases
}

################################################################################
# DOTFILES
################################################################################

dotfiles() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Open the dotfiles repository in your default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  dotfiles [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  dotfiles"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Define the dotfiles repository URL
  local arch_dotfiles_url="https://github.com/iop098321qwe/dotfiles-arch"

  # Open the dotfiles repository in the default browser
  setsid -f xdg-open "$arch_dotfiles_url" >/dev/null 2>&1
}

###############################################################################
# CBC UPDATE CHECK
###############################################################################

cbc_version_is_newer() {
  local current="$1"
  local candidate="$2"

  [[ -z "$candidate" ]] && return 1
  [[ -z "$current" ]] && return 0

  local newest
  newest=$(printf '%s\n' "$current" "$candidate" | sort -V | tail -n1)
  [[ "$newest" == "$candidate" && "$candidate" != "$current" ]]
}

cbc_json_get_string() {
  local key="$1"
  local json="$2"
  local raw=""

  raw=$(printf '%s' "$json" | tr -d '\n' | awk -v key="$key" '
    BEGIN {
      pattern="\"" key "\"[[:space:]]*:[[:space:]]*\""
    }
    {
      if (match($0, pattern)) {
        i = RSTART + RLENGTH
        out = ""
        esc = 0
        while (i <= length($0)) {
          c = substr($0, i, 1)
          if (esc == 1) {
            out = out c
            esc = 0
            i++
            continue
          }
          if (c == "\\") {
            esc = 1
            i++
            continue
          }
          if (c == "\"") {
            print out
            exit
          }
          out = out c
          i++
        }
      }
    }
  ')

  printf '%s' "$raw"
}

cbc_json_unescape() {
  local value="$1"

  printf '%s' "$value" | sed \
    -e 's/\\\\/\\/g' \
    -e 's/\\"/"/g' \
    -e 's/\\n/ /g' \
    -e 's/\\r/ /g' \
    -e 's/\\t/ /g'
}

cbc_update_check() {
  local current_version="$CBC_VERSION"
  local release_api_url="https://api.github.com/repos/iop098321qwe/custom_bash_commands/releases/latest"

  local response status body
  response=$(curl -sSL --connect-timeout 10 --max-time 30 -w "\n%{http_code}" \
    "$release_api_url" 2>/dev/null || true)
  status=$(printf '%s\n' "$response" | tail -n1)
  body=$(printf '%s\n' "$response" | sed '$d')

  if [[ "$status" != "200" || -z "$body" ]]; then
    local error_message=""
    if [[ -n "$body" ]]; then
      error_message="$(cbc_json_get_string "message" "$body")"
    fi
    if [[ -n "$error_message" ]]; then
      error_message="$(cbc_json_unescape "$error_message")"
      cbc_style_message "$CATPPUCCIN_RED" \
        "Unable to check for updates: $error_message"
    else
      cbc_style_message "$CATPPUCCIN_RED" \
        "Unable to check for updates right now."
    fi
    return 1
  fi

  local latest_version_raw=""
  local latest_name_raw=""
  local latest_url_raw=""
  local body_raw=""

  latest_version_raw="$(cbc_json_get_string "tag_name" "$body")"
  latest_name_raw="$(cbc_json_get_string "name" "$body")"
  latest_url_raw="$(cbc_json_get_string "html_url" "$body")"
  body_raw="$(cbc_json_get_string "body" "$body")"

  local latest_version="$(cbc_json_unescape "$latest_version_raw")"
  local latest_name="$(cbc_json_unescape "$latest_name_raw")"
  local latest_url="$(cbc_json_unescape "$latest_url_raw")"

  if [[ -z "$latest_version" ]]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "Unable to parse the latest release information."
    return 1
  fi

  if cbc_version_is_newer "$current_version" "$latest_version"; then
    local update_lines=(
      "Custom Bash Commands update available!"
      "  Current: $current_version"
      "  Latest:  $latest_version${latest_name:+ ($latest_name)}"
    )
    [[ -n "$latest_url" ]] && update_lines+=("  Release: $latest_url")
    cbc_style_box "$CATPPUCCIN_SKY" "${update_lines[@]}"
  else
    cbc_style_box "$CATPPUCCIN_GREEN" \
      "Custom Bash Commands is up to date." \
      "  Current: $current_version" \
      "  Latest:  $latest_version${latest_name:+ ($latest_name)}"
  fi
}

cbc_update_run() {
  local SPARSE_DIR
  local REPO_URL
  local FILE_PATHS
  local new_filename
  local copy_errors=0
  local verbose=false
  local can_spin=true
  local source_path=""
  local target_script="$HOME/.custom_bash_commands.sh"
  local log_time_format="%Y-%m-%d %H:%M:%S"
  local git_env="GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=true GIT_PAGER=cat"

  if [ "${1:-}" = "true" ]; then
    verbose=true
  fi

  if ! command -v gum >/dev/null 2>&1; then
    can_spin=false
  fi

  if [ ! -t 0 ] || [ ! -t 1 ]; then
    can_spin=false
  fi

  if [ "$verbose" = true ]; then
    can_spin=false
  fi

  source_path="${BASH_SOURCE[0]}"

  cleanup_sparse_dir() {
    if [ -n "$SPARSE_DIR" ] && [ -d "$SPARSE_DIR" ]; then
      rm -rf "$SPARSE_DIR"
    fi
  }

  # Temporary directory for sparse checkout
  SPARSE_DIR=$(mktemp -d)
  trap cleanup_sparse_dir EXIT INT TERM

  # URL of the GitHub repository
  REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

  # List of file paths to download and move
  FILE_PATHS=(
    custom_bash_commands.sh
    cbc_aliases.sh
  )

  cbc_style_box "$CATPPUCCIN_BLUE" "Updating Custom Bash Commands"

  if [ "$verbose" = true ]; then
    local stdin_tty="no"
    local stdout_tty="no"
    if [ -t 0 ]; then
      stdin_tty="yes"
    fi
    if [ -t 1 ]; then
      stdout_tty="yes"
    fi
    printf '[%s] verbose: enabled\n' "$(date +"$log_time_format")"
    printf '[%s] tty: stdin=%s stdout=%s\n' \
      "$(date +"$log_time_format")" "$stdin_tty" "$stdout_tty"
    printf '[%s] can_spin: %s\n' "$(date +"$log_time_format")" "$can_spin"
    printf '[%s] gum: %s\n' "$(date +"$log_time_format")" \
      "$(command -v gum 2>/dev/null || printf '%s' 'missing')"
    printf '[%s] git: %s\n' "$(date +"$log_time_format")" \
      "$(command git --version 2>/dev/null || printf '%s' 'missing')"
    printf '[%s] repo_url: %s\n' "$(date +"$log_time_format")" "$REPO_URL"
    printf '[%s] sparse_dir: %s\n' "$(date +"$log_time_format")" "$SPARSE_DIR"
    printf '[%s] source_path: %s\n' "$(date +"$log_time_format")" "$source_path"
    printf '[%s] target_script: %s\n' \
      "$(date +"$log_time_format")" "$target_script"
    printf '[%s] file_paths: %s\n' \
      "$(date +"$log_time_format")" "${FILE_PATHS[*]}"
    printf '[%s] cp resolution:\n' "$(date +"$log_time_format")"
    type -a cp 2>/dev/null || true
    printf '[%s] git resolution:\n' "$(date +"$log_time_format")"
    type -a git 2>/dev/null || true
  fi

  if ! cbc_confirm "Pull the latest version and overwrite local files?"; then
    cbc_style_message "$CATPPUCCIN_YELLOW" "Update cancelled."
    return 0
  fi

  # Initialize an empty git repository and configure for sparse checkout
  local prep_log="$SPARSE_DIR/.cbc_update_prepare.log"
  local prep_cmd=""
  local prep_status=0
  rm -f "$prep_log"

  prep_cmd="{ $git_env command git -C \"$SPARSE_DIR\" init -q && \
  $git_env command git -C \"$SPARSE_DIR\" remote add origin \"$REPO_URL\" && \
  $git_env command git -C \"$SPARSE_DIR\" config core.sparseCheckout true; } \
  >\"$prep_log\" 2>&1"

  if [ "$verbose" = true ]; then
    printf '[%s] step: prepare sparse checkout\n' "$(date +"$log_time_format")"
    printf '[%s] command: %s\n' "$(date +"$log_time_format")" "$prep_cmd"
  fi

  if [ "$can_spin" = true ]; then
    cbc_spinner "Preparing temporary checkout" bash -c "$prep_cmd"
    prep_status=$?
  else
    bash -c "$prep_cmd"
    prep_status=$?
  fi

  if [ "$verbose" = true ]; then
    printf '[%s] prepare exit: %s\n' "$(date +"$log_time_format")" "$prep_status"
    if [ -s "$prep_log" ]; then
      printf '[%s] prepare output:\n' "$(date +"$log_time_format")"
      command cat "$prep_log"
    else
      printf '[%s] prepare output: (none)\n' "$(date +"$log_time_format")"
    fi
  fi

  if [ $prep_status -ne 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Failed to prepare sparse checkout."
    if [ -s "$prep_log" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Git error:"
      command cat "$prep_log"
    fi
    rm -f "$prep_log"
    return 1
  fi

  rm -f "$prep_log"

  for path in "${FILE_PATHS[@]}"; do
    echo "$path" >>"$SPARSE_DIR/.git/info/sparse-checkout"
  done

  local pull_log="$SPARSE_DIR/.cbc_update_pull.log"
  local pull_cmd=""
  local pull_status=0
  rm -f "$pull_log"

  pull_cmd="$git_env command git -C \"$SPARSE_DIR\" pull origin main \
  >\"$pull_log\" 2>&1"

  if [ "$verbose" = true ]; then
    printf '[%s] step: git pull\n' "$(date +"$log_time_format")"
    printf '[%s] command: %s\n' "$(date +"$log_time_format")" "$pull_cmd"
  fi

  if [ "$can_spin" = true ]; then
    cbc_spinner "Downloading updates" bash -c "$pull_cmd"
    pull_status=$?
  else
    bash -c "$pull_cmd"
    pull_status=$?
  fi

  if [ "$verbose" = true ]; then
    printf '[%s] git pull exit: %s\n' "$(date +"$log_time_format")" "$pull_status"
    if [ -s "$pull_log" ]; then
      printf '[%s] git pull output:\n' "$(date +"$log_time_format")"
      command cat "$pull_log"
    else
      printf '[%s] git pull output: (none)\n' "$(date +"$log_time_format")"
    fi
  fi

  if [ $pull_status -ne 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "Unable to download updates from the repository."
    if [ -s "$pull_log" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Git error:"
      command cat "$pull_log"
    fi
    rm -f "$pull_log"
    return 1
  fi

  rm -f "$pull_log"

  for path in "${FILE_PATHS[@]}"; do
    new_filename="$(basename "$path")"
    if [[ $new_filename != .* ]]; then
      new_filename=".$new_filename"
    fi

    local copy_log="$SPARSE_DIR/.cbc_update_copy_${new_filename}.log"
    local copy_cmd=""
    local copy_status=0
    rm -f "$copy_log"

    if [ "$verbose" = true ]; then
      printf '[%s] step: copy %s\n' \
        "$(date +"$log_time_format")" "$new_filename"
    fi

    copy_cmd="command cp -f -- \"$SPARSE_DIR/$path\" \"$HOME/$new_filename\" \
    >\"$copy_log\" 2>&1"

    if [ "$verbose" = true ]; then
      printf '[%s] command: %s\n' "$(date +"$log_time_format")" "$copy_cmd"
    fi

    if [ "$can_spin" = true ]; then
      cbc_spinner "Updating $new_filename" bash -c "$copy_cmd"
      copy_status=$?
    else
      bash -c "$copy_cmd"
      copy_status=$?
    fi

    if [ "$verbose" = true ]; then
      printf '[%s] copy exit: %s\n' "$(date +"$log_time_format")" "$copy_status"
      if [ -s "$copy_log" ]; then
        printf '[%s] copy output:\n' "$(date +"$log_time_format")"
        command cat "$copy_log"
      else
        printf '[%s] copy output: (none)\n' "$(date +"$log_time_format")"
      fi
    fi

    if [ $copy_status -ne 0 ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Failed to copy $path."
      if [ -s "$copy_log" ]; then
        cbc_style_message "$CATPPUCCIN_RED" "Copy error:"
        command cat "$copy_log"
      fi
      copy_errors=1
    fi

    rm -f "$copy_log"
  done

  if [ $copy_errors -eq 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Update incomplete. Please retry."
    return 1
  fi

  trap - EXIT INT TERM
  cleanup_sparse_dir

  local reload_cmd="source \"$target_script\""
  local reload_status=0

  if [ "$verbose" = true ]; then
    printf '[%s] step: reload\n' "$(date +"$log_time_format")"
    printf '[%s] command: %s\n' "$(date +"$log_time_format")" "$reload_cmd"
  fi

  if [ "$can_spin" = true ]; then
    cbc_spinner "Custom Bash Commands updated. Reloading..." bash -c "$reload_cmd"
    reload_status=$?
  else
    cbc_style_message "$CATPPUCCIN_GREEN" \
      "Custom Bash Commands updated. Reloading..."
    bash -c "$reload_cmd"
    reload_status=$?
  fi

  if [ "$verbose" = true ]; then
    printf '[%s] reload exit: %s\n' "$(date +"$log_time_format")" "$reload_status"
  fi

  if [ $reload_status -ne 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Failed to reload CBC."
    return 1
  fi

  # Source the updated commands in the current shell
  source "$target_script"
  display_version
}

cbc_update() {
  OPTIND=1
  local show_help=false
  local verbose=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Update CBC or check for updates."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc update [-v]" \
      "  cbc update check"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -v    Show verbose update output"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc update" \
      "  cbc update -v" \
      "  cbc update check"
  }

  while getopts ":hv" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    v)
      verbose=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  local subcommand="$1"
  if [ -n "$subcommand" ]; then
    shift
  fi

  case "$subcommand" in
  check)
    cbc_update_check
    ;;
  "" | -h | --help)
    cbc_update_run "$verbose"
    ;;
  *)
    cbc_style_message "$CATPPUCCIN_RED" "Unknown cbc update command: $subcommand"
    usage
    return 1
    ;;
  esac
}

################################################################################
# CBC TEST
################################################################################

cbc_test() {
  OPTIND=1
  local show_help=false
  local repo_path="$HOME/Documents/github_repositories/custom_bash_commands"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Reload CBC scripts from a local repository."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc test [repo-path]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Notes:" \
      "  Defaults to ~/Documents/github_repositories/custom_bash_commands."

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc test" \
      "  cbc test ~/dev/custom_bash_commands"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -gt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  if [ $# -eq 1 ]; then
    repo_path="$1"
  fi

  repo_path="${repo_path/#\~/$HOME}"

  local script_path="$repo_path/custom_bash_commands.sh"
  local alias_path="$repo_path/cbc_aliases.sh"

  if [ ! -f "$script_path" ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "Missing $script_path. Check the repo path and try again."
    return 1
  fi

  if [ ! -f "$alias_path" ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "Missing $alias_path. Check the repo path and try again."
    return 1
  fi

  # shellcheck disable=SC1090
  source "$script_path"
  # shellcheck disable=SC1090
  source "$alias_path"

  cbc_style_message "$CATPPUCCIN_GREEN" \
    "Reloaded CBC from $repo_path."
}

################################################################################
# CBC DOCTOR
################################################################################

cbc_doctor() {
  OPTIND=1
  local show_help=false
  local has_gum=true

  if ! command -v gum >/dev/null 2>&1; then
    has_gum=false
  fi

  usage() {
    if [ "$has_gum" = true ]; then
      cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
        "  Run diagnostics for CBC configuration, dependencies, and updates."

      cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
        "  cbc doctor [-h]"

      cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
        "  -h    Display this help message"

      cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
        "  cbc doctor"
      return
    fi

    printf '%s\n' "Description: Run diagnostics for CBC configuration, dependencies, and updates."
    printf '%s\n' "Usage: cbc doctor [-h]"
    printf '%s\n' "Options: -h  Display this help message"
    printf '%s\n' "Example: cbc doctor"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help=true
      ;;
    \?)
      if [ "$has_gum" = true ]; then
        cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      else
        printf '%s\n' "Invalid option: -$OPTARG"
      fi
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_help" = true ]; then
    usage
    return 0
  fi

  if [ $# -gt 0 ]; then
    if [ "$has_gum" = true ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    else
      printf '%s\n' "Error: Unexpected arguments: $*"
    fi
    return 1
  fi

  local ok=0
  local warn=0
  local fail=0

  local -a summary_lines=()
  local -a dependency_lines=()
  local -a file_lines=()
  local -a module_lines=()
  local -a network_lines=()

  cbc_doctor_pretty_path() {
    local path="$1"

    if [[ "$path" == "$HOME"* ]]; then
      printf '~%s' "${path#$HOME}"
      return
    fi

    printf '%s' "$path"
  }

  cbc_doctor_add_result() {
    local status="$1"
    local label="$2"
    local detail="$3"
    local -n out="$4"
    local line=""

    case "$status" in
    OK)
      ok=$((ok + 1))
      ;;
    WARN)
      warn=$((warn + 1))
      ;;
    FAIL)
      fail=$((fail + 1))
      ;;
    esac

    if [ -n "$detail" ]; then
      printf -v line '%-4s %s - %s' "$status" "$label" "$detail"
    else
      printf -v line '%-4s %s' "$status" "$label"
    fi

    out+=("$line")
  }

  cbc_doctor_print_box() {
    local color="$1"
    local title="$2"
    shift 2
    local -a lines=("$@")

    if [ "$has_gum" = true ]; then
      cbc_style_box "$color" "$title" "${lines[@]}"
      return
    fi

    printf '%s\n' "$title"
    local line
    for line in "${lines[@]}"; do
      printf '  %s\n' "$line"
    done
    printf '\n'
  }

  cbc_doctor_check_tool() {
    local cmd="$1"
    local label="$2"
    local required="$3"
    local out_name="$4"
    local resolved=""

    resolved="$(command -v "$cmd" 2>/dev/null || true)"

    if [ -n "$resolved" ]; then
      cbc_doctor_add_result "OK" "$label" "$resolved" "$out_name"
      return
    fi

    if [ "$required" = true ]; then
      cbc_doctor_add_result "FAIL" "$label" "missing" "$out_name"
      return
    fi

    cbc_doctor_add_result "WARN" "$label" "missing (optional)" "$out_name"
  }

  cbc_doctor_check_file() {
    local label="$1"
    local path="$2"
    local required="$3"
    local out_name="$4"
    local display

    display="$(cbc_doctor_pretty_path "$path")"

    if [ -f "$path" ]; then
      cbc_doctor_add_result "OK" "$label" "$display" "$out_name"
      return
    fi

    if [ "$required" = true ]; then
      cbc_doctor_add_result "FAIL" "$label" "missing: $display" "$out_name"
      return
    fi

    cbc_doctor_add_result "WARN" "$label" "missing: $display" "$out_name"
  }

  cbc_doctor_check_dir() {
    local label="$1"
    local path="$2"
    local required="$3"
    local out_name="$4"
    local display

    display="$(cbc_doctor_pretty_path "$path")"

    if [ -d "$path" ]; then
      cbc_doctor_add_result "OK" "$label" "$display" "$out_name"
      return
    fi

    if [ "$required" = true ]; then
      cbc_doctor_add_result "FAIL" "$label" "missing: $display" "$out_name"
      return
    fi

    cbc_doctor_add_result "WARN" "$label" "missing: $display" "$out_name"
  }

  cbc_doctor_check_tool "bash" "bash" true dependency_lines
  cbc_doctor_check_tool "git" "git" true dependency_lines
  cbc_doctor_check_tool "curl" "curl" true dependency_lines
  cbc_doctor_check_tool "sed" "sed" true dependency_lines
  cbc_doctor_check_tool "awk" "awk" true dependency_lines
  cbc_doctor_check_tool "sha256sum" "sha256sum" true dependency_lines
  cbc_doctor_check_tool "find" "find" true dependency_lines
  cbc_doctor_check_tool "sort" "sort" true dependency_lines
  cbc_doctor_check_tool "xargs" "xargs" true dependency_lines
  cbc_doctor_check_tool "man" "man" true dependency_lines
  cbc_doctor_check_tool "xdg-open" "xdg-open" true dependency_lines
  cbc_doctor_check_tool "setsid" "setsid" true dependency_lines
  cbc_doctor_check_tool "gum" "gum" true dependency_lines
  cbc_doctor_check_tool "fzf" "fzf" true dependency_lines

  if command -v bat >/dev/null 2>&1; then
    cbc_doctor_add_result "OK" "bat/batcat" "$(command -v bat)" dependency_lines
  elif command -v batcat >/dev/null 2>&1; then
    cbc_doctor_add_result "OK" "bat/batcat" "$(command -v batcat)" dependency_lines
  else
    cbc_doctor_add_result "FAIL" "bat/batcat" "missing" dependency_lines
  fi

  cbc_doctor_check_tool "eza" "eza" true dependency_lines
  cbc_doctor_check_tool "imv-x11" "imv-x11" true dependency_lines
  cbc_doctor_check_tool "nvim" "nvim" true dependency_lines
  cbc_doctor_check_tool "wl-copy" "wl-copy" true dependency_lines
  cbc_doctor_check_tool "zellij" "zellij" false dependency_lines
  cbc_doctor_check_tool "sudo" "sudo" false dependency_lines

  cbc_doctor_check_file "Main script" "$HOME/.custom_bash_commands.sh" true file_lines
  cbc_doctor_check_file "Alias catalog" "$HOME/.cbc_aliases.sh" false file_lines
  cbc_doctor_check_dir "Config dir" "$CBC_CONFIG_DIR" false file_lines
  cbc_doctor_check_file "Config file" "$CBC_CONFIG_FILE" false file_lines

  if [ "$CBC_SOURCE_BASH_ALIASES" = true ]; then
    local bash_aliases="$HOME/.bash_aliases"
    local bash_aliases_display
    bash_aliases_display="$(cbc_doctor_pretty_path "$bash_aliases")"

    if [ -f "$bash_aliases" ]; then
      cbc_doctor_add_result "OK" "Bash aliases" "$bash_aliases_display" file_lines
    else
      cbc_doctor_add_result "WARN" "Bash aliases" "missing: $bash_aliases_display" file_lines
    fi
  else
    cbc_doctor_add_result "OK" "Bash aliases" "disabled by config" file_lines
  fi

  local module_root_display
  module_root_display="$(cbc_doctor_pretty_path "$CBC_MODULE_ROOT")"
  if [ -d "$CBC_MODULE_ROOT" ]; then
    cbc_doctor_add_result "OK" "Module root" "$module_root_display" module_lines
  else
    cbc_doctor_add_result "FAIL" "Module root" "missing: $module_root_display" module_lines
  fi

  local manifest_display
  manifest_display="$(cbc_doctor_pretty_path "$CBC_PACKAGE_MANIFEST")"
  if [ -f "$CBC_PACKAGE_MANIFEST" ]; then
    cbc_doctor_add_result "OK" "Packages manifest" "$manifest_display" module_lines
  else
    cbc_doctor_add_result "OK" "Packages manifest" "not found (no modules tracked)" module_lines
  fi

  cbc_pkg_read_manifest

  local -a manifest_modules=()
  local idx
  for idx in "${!CBC_MANIFEST_USES[@]}"; do
    local use="${CBC_MANIFEST_USES[$idx]}"
    local source=""
    local module_name=""
    cbc_pkg_resolve_source "$use" source module_name
    manifest_modules+=("$module_name")

    local module_dir="$CBC_MODULE_ROOT/$module_name"
    if [ ! -d "$module_dir" ]; then
      cbc_doctor_add_result "WARN" "Module $module_name" \
        "missing; run 'cbc pkg load'" module_lines
      continue
    fi

    local entrypoint="$module_dir/$CBC_MODULE_ENTRYPOINT"
    if [ -f "$entrypoint" ]; then
      cbc_doctor_add_result "OK" "Module $module_name" "entrypoint ok" module_lines
    else
      cbc_doctor_add_result "WARN" "Module $module_name" \
        "missing $CBC_MODULE_ENTRYPOINT" module_lines
    fi
  done

  local local_modules=false
  shopt -s nullglob
  for module_dir in "$CBC_MODULE_ROOT"/*; do
    [ -d "$module_dir" ] || continue
    local_modules=true

    local module_name
    module_name="$(basename "$module_dir")"

    if [[ " ${manifest_modules[*]} " == *" $module_name "* ]]; then
      continue
    fi

    cbc_doctor_add_result "WARN" "Module $module_name" \
      "not tracked in packages.toml" module_lines
  done
  shopt -u nullglob

  if [ ${#CBC_MANIFEST_USES[@]} -eq 0 ] && [ "$local_modules" = false ]; then
    if [ -d "$CBC_MODULE_ROOT" ]; then
      cbc_doctor_add_result "OK" "Modules" "none installed" module_lines
    fi
  fi

  local github_api_url="https://api.github.com/repos/iop098321qwe/custom_bash_commands/releases/latest"
  if command -v curl >/dev/null 2>&1; then
    local response status body
    response=$(curl -sSL --connect-timeout 5 --max-time 10 -w "\n%{http_code}" \
      "$github_api_url" 2>/dev/null || true)
    status=$(printf '%s\n' "$response" | tail -n1)
    body=$(printf '%s\n' "$response" | sed '$d')

    if [ "$status" = "200" ]; then
      local latest_tag_raw=""
      local latest_tag=""
      latest_tag_raw="$(cbc_json_get_string "tag_name" "$body")"
      latest_tag="$(cbc_json_unescape "$latest_tag_raw")"

      if [ -n "$latest_tag" ]; then
        cbc_doctor_add_result "OK" "GitHub API" "latest release $latest_tag" network_lines
      else
        cbc_doctor_add_result "WARN" "GitHub API" "reachable; release tag missing" network_lines
      fi
    else
      local error_message=""
      local status_label="$status"

      if [ -n "$body" ]; then
        error_message="$(cbc_json_get_string "message" "$body")"
        error_message="$(cbc_json_unescape "$error_message")"
      fi

      if [ -z "$status_label" ]; then
        status_label="no response"
      fi

      if [ -n "$error_message" ]; then
        cbc_doctor_add_result "FAIL" "GitHub API" \
          "http $status_label: $error_message" network_lines
      else
        cbc_doctor_add_result "FAIL" "GitHub API" "http $status_label" network_lines
      fi
    fi
  else
    cbc_doctor_add_result "FAIL" "GitHub API" "curl missing" network_lines
  fi

  local github_repo_url="https://github.com/iop098321qwe/custom_bash_commands.git"
  if command -v git >/dev/null 2>&1; then
    local git_out=""
    local git_hash=""
    git_out="$(GIT_TERMINAL_PROMPT=0 GIT_ASKPASS=true git ls-remote \
      "$github_repo_url" HEAD 2>/dev/null || true)"
    git_hash="${git_out%%[[:space:]]*}"

    if [ -n "$git_hash" ]; then
      cbc_doctor_add_result "OK" "GitHub git" "HEAD $git_hash" network_lines
    else
      cbc_doctor_add_result "FAIL" "GitHub git" "ls-remote failed" network_lines
    fi
  else
    cbc_doctor_add_result "FAIL" "GitHub git" "git missing" network_lines
  fi

  local overall="OK"
  if [ "$fail" -gt 0 ]; then
    overall="FAIL"
  elif [ "$warn" -gt 0 ]; then
    overall="WARN"
  fi

  local source_path="${BASH_SOURCE[0]}"
  local source_display
  local config_display
  source_display="$(cbc_doctor_pretty_path "$source_path")"
  config_display="$(cbc_doctor_pretty_path "$CBC_CONFIG_FILE")"

  summary_lines=(
    "Overall: $overall"
    "Version: $CBC_VERSION"
    "Script: $source_display"
    "Config: $config_display"
    "Checks: OK=$ok WARN=$warn FAIL=$fail"
  )

  local -a file_module_lines=()
  file_module_lines+=("${file_lines[@]}")
  file_module_lines+=("${module_lines[@]}")

  cbc_doctor_print_box "$CATPPUCCIN_MAUVE" "Summary" "${summary_lines[@]}"
  cbc_doctor_print_box "$CATPPUCCIN_BLUE" "Dependencies" "${dependency_lines[@]}"
  cbc_doctor_print_box "$CATPPUCCIN_TEAL" "Files and Modules" \
    "${file_module_lines[@]}"
  cbc_doctor_print_box "$CATPPUCCIN_SAPPHIRE" "Network" "${network_lines[@]}"

  if [ "$fail" -gt 0 ]; then
    return 1
  fi
}

################################################################################
# DISPLAY VERSION
################################################################################

display_version() {
  # Function to display usage
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Displays the version number from the .custom_bash_commands file in the local repository."

    cbc_style_box "$CATPPUCCIN_TEAL" "Alias:" \
      "  dv"

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  display_version"

    cbc_style_box "$CATPPUCCIN_PEACH" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Example:" \
      "  display_version"
  }

  OPTIND=1

  while getopts "h" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  local banner_mode="${CBC_BANNER_MODE,,}"

  case "$banner_mode" in
  minimal)
    cbc_style_message "$CATPPUCCIN_YELLOW" "$CBC_VERSION"
    ;;
  *)
    cbc_style_message "$CATPPUCCIN_GREEN" "CUSTOM BASH COMMANDS (by iop098321qwe)"
    cbc_style_message "$CATPPUCCIN_YELLOW" "🔹🔹$CBC_VERSION🔹🔹CHANGELOG: 'changes'🔹🔹RELEASES: 'releases'🔹🔹WIKI: 'wiki'🔹🔹"
    ;;
  esac
}

################################################################################
# CBC LIST
################################################################################

cbc_list_render() {
  local filter="$1"
  local all_info="$2"
  local show_functions=true
  local show_aliases=true

  case "$filter" in
  commands)
    show_aliases=false
    ;;
  aliases)
    show_functions=false
    ;;
  esac

  local -a function_names=(
    "cbc"
    "cbc config"
    "cbc config edit"
    "cbc doctor"
    "cbc list"
    "cbc pkg"
    "cbc test"
    "cbc update"
    "cbc update check"
    "changes"
    "display_version"
    "dotfiles"
    "readme"
    "releases"
    "wiki"
  )

  local -a function_descs=(
    "Entry point for CBC subcommands"
    "Generate the CBC config file"
    "Edit the CBC config file"
    "Run CBC diagnostics"
    "List CBC commands and aliases"
    "Manage CBC modules (install, list, load, uninstall, update)"
    "Reload CBC scripts from a local repo"
    "Update CBC scripts and reload"
    "Check for CBC updates"
    "Open the CBC changelog in a browser"
    "Print the current CBC version"
    "Open the dotfiles repository"
    "Open the CBC README in a browser"
    "Open the CBC releases page"
    "Open the CBC wiki"
  )

  local -a alias_names=(
    "bat"
    "c"
    "dv"
    "editbash"
    "fman"
    "imv"
    "la"
    "lar"
    "le"
    "ll"
    "llt"
    "lsd"
    "ls"
    "lsf"
    "lsr"
    "lt"
    "myip"
    "please"
    "py"
    "python"
    "refresh"
    "s"
    "seebash"
    "ucbc"
    "v"
    "vim"
    "x"
    "z"
  )

  local -a alias_descs=(
    "batcat (Ubuntu only)"
    "clear"
    "display_version"
    "\$EDITOR ~/.bashrc"
    "compgen -c | fzf | xargs man"
    "imv-x11"
    "eza --icons=always --group-directories-first -a"
    "eza --icons=always -r --group-directories-first -a"
    "eza --icons=always --group-directories-first -s extension"
    "eza --icons=always --group-directories-first --smart-group --total-size -hl"
    "eza --icons=always --group-directories-first --smart-group --total-size -hlT"
    "eza --icons=always --group-directories-first -D"
    "eza --icons=always --group-directories-first"
    "eza --icons=always --group-directories-first -f"
    "eza --icons=always --group-directories-first -r"
    "eza --icons=always --group-directories-first -T"
    "curl http://ipecho.net/plain; echo"
    "sudo \$(history -p !!)"
    "python3"
    "python3"
    "source ~/.bashrc && clear"
    "sudo"
    "batcat ~/.bashrc"
    "cbc update"
    "nvim"
    "nvim"
    "chmod +x"
    "zellij"
  )

  cbc_list_format_details() {
    local -n out_lines="$1"
    local -n names="$2"
    local -n descs="$3"
    local max=0
    local name

    for name in "${names[@]}"; do
      local length=${#name}
      if ((length > max)); then
        max=$length
      fi
    done

    out_lines=()
    local idx
    for idx in "${!names[@]}"; do
      local padded
      printf -v padded '%-*s' "$max" "${names[$idx]}"
      out_lines+=("  ${padded}  ${descs[$idx]}")
    done
  }

  local -a functions=()
  local name
  for name in "${function_names[@]}"; do
    functions+=("  $name")
  done

  local -a aliases=()
  for name in "${alias_names[@]}"; do
    aliases+=("  $name")
  done

  local -a function_details=()
  local -a alias_details=()

  if [ "$all_info" = true ]; then
    if [ "$show_functions" = true ]; then
      cbc_list_format_details function_details function_names function_descs
      cbc_style_box "$CATPPUCCIN_MAUVE" "CBC Functions" "${function_details[@]}"
    fi
    if [ "$show_aliases" = true ]; then
      cbc_list_format_details alias_details alias_names alias_descs
      cbc_style_box "$CATPPUCCIN_BLUE" "CBC Aliases" "${alias_details[@]}"
    fi
  else
    if [ "$show_functions" = true ]; then
      cbc_style_box "$CATPPUCCIN_MAUVE" "CBC Functions" \
        "  Use 'cbc list -v' for descriptions." "${functions[@]}"
    fi
    if [ "$show_aliases" = true ]; then
      cbc_style_box "$CATPPUCCIN_BLUE" "CBC Aliases" "${aliases[@]}"
    fi
  fi
}

cbc_list() {
  OPTIND=1
  local all_info=false
  local filter="all"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  List available CBC commands and aliases."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc list [options] [commands|aliases]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -v    Show descriptions"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc list" \
      "  cbc list -v" \
      "  cbc list aliases" \
      "  cbc list commands"
  }

  while getopts ":hv" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    v)
      all_info=true
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$all_info" = false ] && [ "$CBC_LIST_SHOW_DESCRIPTIONS" = true ]; then
    all_info=true
  fi

  if [ $# -gt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  if [ $# -eq 1 ]; then
    case "$1" in
    aliases | alias)
      filter="aliases"
      ;;
    commands | command | functions | function)
      filter="commands"
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Unknown cbc list filter: $1"
      usage
      return 1
      ;;
    esac
  fi

  if command -v bat >/dev/null 2>&1; then
    cbc_list_render "$filter" "$all_info" | bat
    return
  fi

  if command -v batcat >/dev/null 2>&1; then
    cbc_list_render "$filter" "$all_info" | batcat
    return
  fi

  cbc_list_render "$filter" "$all_info"
}

###############################################################################
# Auto-load installed CBC modules
###############################################################################

cbc_pkg_load_modules auto

###############################################################################
# Call the function to display information once per interactive session
###############################################################################

if [[ $- == *i* ]] && [ "$CBC_SHOW_BANNER" = true ]; then
  if [ -z "${CBC_INFO_SHOWN:-}" ]; then
    CBC_INFO_SHOWN=1
    export CBC_INFO_SHOWN
    display_version
  fi
fi

###############################################################################
# Source the aliases file if it exists
###############################################################################

# If the .bash_aliases file exists, source it
if [ "$CBC_SOURCE_BASH_ALIASES" = true ] && [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
