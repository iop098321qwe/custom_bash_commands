#!/usr/bin/env bash
CBC_VERSION="v306.15.0"

################################################################################
# CUSTOM BASH COMMANDS (by iop098321qwe)
################################################################################

CBC_CONFIG_DIR="${CBC_CONFIG_DIR:-$HOME/.config/cbc}"
CBC_MODULE_ROOT="${CBC_MODULE_ROOT:-$CBC_CONFIG_DIR/modules}"
CBC_PACKAGE_MANIFEST="${CBC_PACKAGE_MANIFEST:-$CBC_CONFIG_DIR/packages.toml}"
CBC_MODULE_ENTRYPOINT="cbc-module.sh"

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

if command -v gum >/dev/null 2>&1; then
  CBC_HAS_GUM=1
else
  CBC_HAS_GUM=0
fi

cbc_style_box() {
  local border_color="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum style \
      --border rounded \
      --border-foreground "$border_color" \
      --foreground "$CATPPUCCIN_TEXT" \
      --background "$CATPPUCCIN_SURFACE0" \
      --padding "0 2" \
      --margin "0 0 1 0" \
      "$@"
  else
    printf '%s\n' "$@"
  fi
}

cbc_style_message() {
  local color="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum style \
      --foreground "$color" \
      --background "$CATPPUCCIN_BASE" \
      "$@"
  else
    printf '%s\n' "$*"
  fi
}

cbc_style_note() {
  local title="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum style \
      --border normal \
      --border-foreground "$CATPPUCCIN_LAVENDER" \
      --foreground "$CATPPUCCIN_TEXT" \
      --background "$CATPPUCCIN_SURFACE1" \
      --padding "0 2" \
      --margin "0 0 1 0" \
      "$title" "$@"
  else
    printf '%s\n' "$title" "$@"
  fi
}

cbc_confirm() {
  local prompt="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum confirm \
      --prompt.foreground "$CATPPUCCIN_LAVENDER" \
      --selected.foreground "$CATPPUCCIN_GREEN" \
      --selected.background "$CATPPUCCIN_SURFACE1" \
      --unselected.foreground "$CATPPUCCIN_RED" \
      "$prompt"
  else
    local response
    read -r -p "$prompt [y/N]: " response
    case "${response,,}" in
    y | yes) return 0 ;;
    *) return 1 ;;
    esac
  fi
}

cbc_input() {
  local prompt="$1"
  shift
  local placeholder="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum input \
      --prompt.foreground "$CATPPUCCIN_LAVENDER" \
      --cursor.foreground "$CATPPUCCIN_GREEN" \
      --prompt "$prompt" \
      --placeholder "$placeholder"
  else
    local input_value
    read -r -p "$prompt" input_value
    printf '%s' "$input_value"
  fi
}

cbc_spinner() {
  local title="$1"
  shift
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    gum spin --spinner dot --title "$title" --title.foreground "$CATPPUCCIN_MAUVE" -- "$@"
  else
    "$@"
  fi
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
  local use="$1"

  if [ -z "$use" ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "No module source provided. Use 'cbc pkg install <creator/repo>' or a git URL."
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
  local use="$1"

  if [ -z "$use" ]; then
    cbc_style_message "$CATPPUCCIN_RED" \
      "No module provided. Use 'cbc pkg uninstall <creator/repo|module-name>'."
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
    cbc_pkg_install "$1"
    ;;
  list)
    cbc_pkg_list
    ;;
  load)
    cbc_pkg_load_modules
    ;;
  uninstall)
    cbc_pkg_uninstall "$1"
    ;;
  update)
    cbc_pkg_update
    ;;
  *)
    cbc_style_message "$CATPPUCCIN_RED" "Unknown cbc pkg command: $subcommand"
    usage
    return 1
    ;;
  esac
}

cbc() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Entry point for CBC subcommands."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbc [subcommand]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Subcommands:" \
      "  pkg    Manage CBC modules (install, list, load, uninstall, update)" \
      "  -h     Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbc pkg" \
      "  cbc pkg install creator/example-module"
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
  pkg)
    cbc_pkg "$@"
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

source ~/.cbc_aliases.sh

################################################################################
# Append to end of .bashrc function
################################################################################

# Function to append the CBC script to the end of the .bashrc file
append_to_bashrc() {
  # Check if the CBC script is already sourced in the .bashrc file
  if ! grep -q ".custom_bash_commands.sh" "$HOME/.bashrc"; then
    # Append the CBC script to the end of the .bashrc file
    echo "###################################################################################################################################################################" >>"$HOME/.bashrc"
    echo "# Custom Additions" >>"$HOME/.bashrc"
    echo "###################################################################################################################################################################" >>"$HOME/.bashrc"
    echo " " >>"$HOME/.bashrc"
    echo "source ~/.custom_bash_commands.sh" >>"$HOME/.bashrc"
  fi
}

# Call the append_to_bashrc function
append_to_bashrc

################################################################################
# WIKI
################################################################################

wiki() {
  OPTIND=1

  # Define the CBC wiki URL
  wiki_url="https://github.com/iop098321qwe/custom_bash_commands/wiki"

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
      echo "$wiki_url" | xclip -selection clipboard
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
      echo "$changelog_url" | xclip -selection clipboard
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
      echo "$readme_url" | xclip -selection clipboard
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
      echo "$releases_url" | xclip -selection clipboard
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
  arch_dotfiles_url="https://github.com/iop098321qwe/dotfiles-arch"

  # Open the dotfiles repository in the default browser
  setsid -f xdg-open "$arch_dotfiles_url" >/dev/null 2>&1
}

################################################################################
# SETUP_DIRECTORIES
################################################################################

# Function to set up directories (Temporary, GitHub Repositories)
setup_directories() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Create commonly used directories (Temporary, GitHub Repositories, Grymm's Grimoires)."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  setup_directories [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  setup_directories"
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

  # Create the 'screenshots' directory if it does not exist
  mkdir -p ~/Documents/Temporary/screenshots/

  # Create the 'recordings/raw' directory if it does not exist
  mkdir -p ~/Documents/Temporary/recordings/raw/

  # Create the 'recordings/edited' directory if it does not exist
  mkdir -p ~/Documents/Temporary/recordings/edited/

  # Create the 'github_repositories' directory if it does not exist
  mkdir -p ~/Documents/github_repositories
}

# Call the setup_directories function
setup_directories

###############################################################################
# CHECK FOR CBC UPDATES
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

# Check GitHub release for newer version of the script
check_cbc_update() {
  local current_version="$CBC_VERSION"
  local release_api_url="https://api.github.com/repos/iop098321qwe/custom_bash_commands/releases/latest"
  local now check_interval notify_interval

  # Allow opt-in overrides while keeping sane defaults
  check_interval=${CBC_UPDATE_CHECK_INTERVAL:-43200}
  notify_interval=${CBC_UPDATE_NOTIFY_INTERVAL:-21600}
  [[ "$check_interval" =~ ^[0-9]+$ ]] || check_interval=43200
  [[ "$notify_interval" =~ ^[0-9]+$ ]] || notify_interval=21600

  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/custom_bash_commands"
  local cache_file="$cache_dir/update_check"
  local cache_timestamp="0" cached_version="" cached_name="" cached_summary="" cached_url="" last_notified="0"

  if [[ -r "$cache_file" ]]; then
    mapfile -t _cbc_cache_data <"$cache_file"
    cache_timestamp="${_cbc_cache_data[0]:-0}"
    cached_version="${_cbc_cache_data[1]}"
    cached_name="${_cbc_cache_data[2]}"
    cached_summary="${_cbc_cache_data[3]}"
    cached_url="${_cbc_cache_data[4]}"
    last_notified="${_cbc_cache_data[5]:-0}"
  fi

  now=$(date +%s)
  local should_refresh=1

  if [[ "$cache_timestamp" =~ ^[0-9]+$ ]] && ((now - cache_timestamp < check_interval)); then
    should_refresh=0
  fi

  if [[ -z "$cached_version" ]]; then
    should_refresh=1
  fi

  if ((should_refresh)); then
    local response status body
    response=$(curl -sSL -w "\n%{http_code}" "$release_api_url" 2>/dev/null || true)
    status=$(printf '%s\n' "$response" | tail -n1)
    body=$(printf '%s\n' "$response" | sed '$d')

    if [[ "$status" == "200" && -n "$body" ]]; then
      mapfile -t _cbc_parsed_release < <(
        python - <<'PY_HELPER'
import json
import re
import sys

try:
    data = json.load(sys.stdin)
except Exception:
    sys.exit(1)

def clean(value: str) -> str:
    if not value:
        return ""
    # Normalize whitespace to keep everything on one line
    return re.sub(r"\s+", " ", value.strip())[:200]

tag = clean(data.get("tag_name") or "")
name = clean(data.get("name") or "")

summary = ""
for line in (data.get("body") or "").splitlines():
    stripped = line.strip()
    if stripped:
        summary = stripped
        break
summary = clean(summary)

url = data.get("html_url") or ""

print(tag)
print(name)
print(summary)
print(url)
PY_HELPER
        <<<"$body"
      )

      if ((${#_cbc_parsed_release[@]} >= 1)) && [[ -n "${_cbc_parsed_release[0]}" ]]; then
        cache_timestamp=$now
        cached_version="${_cbc_parsed_release[0]}"
        cached_name="${_cbc_parsed_release[1]}"
        cached_summary="${_cbc_parsed_release[2]}"
        cached_url="${_cbc_parsed_release[3]}"
      fi
    elif [[ "$status" =~ ^[0-9]+$ ]]; then
      cache_timestamp=$now
    fi
  fi

  local should_notify=0
  if cbc_version_is_newer "$current_version" "$cached_version"; then
    [[ "$last_notified" =~ ^[0-9]+$ ]] || last_notified=0
    if ((now - last_notified >= notify_interval)); then
      should_notify=1
    fi
  fi

  if ((should_notify)); then
    local notification_lines=(
      "Custom Bash Commands update available!"
      "  Current: $current_version"
      "  Latest:  $cached_version${cached_name:+ ($cached_name)}"
    )
    [[ -n "$cached_summary" ]] && notification_lines+=("  Summary: $cached_summary")
    notification_lines+=("  Update with: updatecbc")
    [[ -n "$cached_url" ]] && notification_lines+=("  Release: $cached_url")

    if [[ "$CBC_HAS_GUM" -eq 1 ]]; then
      cbc_style_box "$CATPPUCCIN_SKY" "${notification_lines[@]}"
    else
      printf '%s\n' "${notification_lines[@]}"
    fi

    last_notified=$now
  fi

  if [[ -n "$cached_version" ]]; then
    mkdir -p "$cache_dir"
    printf '%s\n' \
      "$cache_timestamp" \
      "$cached_version" \
      "$cached_name" \
      "$cached_summary" \
      "$cached_url" \
      "$last_notified" \
      >"$cache_file"
  fi
}
# Automatically check for updates when the script is sourced
check_cbc_update

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

  # Display version details in a fancy box
  cbc_style_message "$CATPPUCCIN_GREEN" "CUSTOM BASH COMMANDS (by iop098321qwe)"
  cbc_style_message "$CATPPUCCIN_YELLOW" "🔹🔹$CBC_VERSION🔹🔹CHANGELOG: 'changes'🔹🔹RELEASES: 'releases'🔹🔹WIKI: 'wiki'🔹🔹"
}

################################################################################
# CBCS
################################################################################

cbcs() {
  OPTIND=1
  local all_info=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Display a list of available custom commands in this script."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  cbcs [-h|-a]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -a    Display all available commands with descriptions"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  cbcs" \
      "  cbcs -a"
  }

  while getopts ":ha" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    a)
      all_info=true
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  local -a functions=(
    "  dotfiles"
    "  cbc"
    "  cbc pkg"
    "  cbcs"
    "  changes"
    "  display_version"
    "  dotfiles"
    "  readme"
    "  regex_help"
    "  releases"
    "  setup_directories"
    "  updatecbc"
    "  wiki"
  )

  local -a aliases=(
    "  bat"
    "  c"
    "  comm"
    "  commm"
    "  commands"
    "  commandsmore"
    "  dv"
    "  editbash"
    "  fman"
    "  fzf"
    "  hsearch"
    "  hse"
    "  hs"
    "  historysearch"
    "  historysearchexact"
    "  imv"
    "  la"
    "  lar"
    "  le"
    "  line"
    "  ll"
    "  llt"
    "  lsd"
    "  ls"
    "  lsf"
    "  lsr"
    "  lt"
    "  myip"
    "  nv"
    "  please"
    "  py"
    "  python"
    "  refresh"
    "  rh"
    "  s"
    "  seebash"
    "  test"
    "  ucbc"
    "  v"
    "  vim"
    "  x"
    "  z"
  )

  local -a function_details=(
    "  dotfiles      Open the arch dotfiles repository"
    "  cbc                Entry point for CBC subcommands"
    "  cbc pkg            Manage CBC modules (install, list, load, uninstall, update)"
    "  cbcs               List CBC functions and aliases"
    "  changes            Open the CBC changelog in a browser"
    "  display_version    Print the current CBC version"
    "  dotfiles           Open the dotfiles repository"
    "  readme             Open the CBC README in a browser"
    "  regex_help         Regex cheat-sheets with flavor selection"
    "  releases           Open the CBC releases page"
    "  setup_directories  Create common directories under ~/Documents"
    "  updatecbc          Update CBC scripts and reload"
    "  wiki               Open the CBC wiki"
  )

  local -a alias_details=(
    "  bat                batcat (Ubuntu only)"
    "  c                  clear"
    "  comm               commands"
    "  commm              commandsmore"
    "  commands           cbcs | batcat"
    "  commandsmore       cbcs -a | batcat"
    "  dv                 display_version"
    "  editbash           \$EDITOR ~/.bashrc"
    "  fman               compgen -c | fzf | xargs man"
    "  fzf                fzf -m"
    "  hsearch            historysearch"
    "  hse                historysearchexact"
    "  hs                 historysearch"
    "  historysearch      history | sort -nr | fzf ... | xclip"
    "  historysearchexact  history | sort -nr | fzf -e ... | xclip"
    "  imv                imv-x11"
    "  la                 eza --icons=always --group-directories-first -a"
    "  lar                eza --icons=always -r --group-directories-first -a"
    "  le                 eza --icons=always --group-directories-first -s extension"
    "  line               prompt for line + file and open in nvim"
    "  ll                 eza --icons=always --group-directories-first --smart-group --total-size -hl"
    "  llt                eza --icons=always --group-directories-first --smart-group --total-size -hlT"
    "  lsd                eza --icons=always --group-directories-first -D"
    "  ls                 eza --icons=always --group-directories-first"
    "  lsf                eza --icons=always --group-directories-first -f"
    "  lsr                eza --icons=always --group-directories-first -r"
    "  lt                 eza --icons=always --group-directories-first -T"
    "  myip               curl http://ipecho.net/plain; echo"
    "  nv                 fzf multi-select into nvim"
    "  please             sudo \$(history -p !!)"
    "  py                 python3"
    "  python             python3"
    "  refresh            source ~/.bashrc && clear"
    "  rh                 regex_help"
    "  s                  sudo"
    "  seebash            batcat ~/.bashrc"
    "  test               source repo scripts for testing"
    "  ucbc               updatecbc"
    "  v                  nvim"
    "  vim                nvim"
    "  x                  chmod +x"
    "  z                  zellij"
  )

  if [ "$all_info" = true ]; then
    cbc_style_box "$CATPPUCCIN_MAUVE" "CBC Functions" "${function_details[@]}"
    cbc_style_box "$CATPPUCCIN_BLUE" "CBC Aliases" "${alias_details[@]}"
  else
    cbc_style_box "$CATPPUCCIN_MAUVE" "CBC Functions" \
      "  Use 'cbcs -a' for descriptions." "${functions[@]}"
    cbc_style_box "$CATPPUCCIN_BLUE" "CBC Aliases" "${aliases[@]}"
  fi
}

################################################################################
# REGEX HELP
################################################################################

regex_help() {
  OPTIND=1

  local default_flavor="pcre"
  local requested_flavor=""
  local interactive=false
  local list_only=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Display regex cheat-sheets for popular flavors with rich examples."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  regex_help [-f <flavor>] [-i] [-l] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -f <flavor>    Show the cheat-sheet for a specific regex flavor" \
      "  -i             Interactively choose a flavor (gum, fzf, or select)" \
      "  -l             List the available flavors and their typical tools" \
      "  -h             Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  regex_help                    # Defaults to PCRE" \
      "  regex_help -i                 # Pick a flavor interactively" \
      "  regex_help -f posix-basic     # Show the POSIX Basic overview"
  }

  while getopts ":hf:il" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    f)
      requested_flavor="$OPTARG"
      ;;
    i)
      interactive=true
      ;;
    l)
      list_only=true
      ;;
    :) # Missing argument
      cbc_style_message "$CATPPUCCIN_RED" "Error: -$OPTARG requires a value"
      return 1
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Error: Unsupported flag -$OPTARG"
      usage
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ $# -gt 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Unexpected arguments: $*"
    return 1
  fi

  local -a flavor_order=(
    pcre
    python
    javascript
    posix-extended
    posix-basic
  )

  local -A flavor_names=(
    [pcre]="PCRE (Perl compatible regular expressions)"
    [python]="Python (re module)"
    [javascript]="JavaScript / ECMAScript"
    [posix - extended]="POSIX Extended (ERE)"
    [posix - basic]="POSIX Basic (BRE)"
  )

  local -A flavor_tools=(
    [pcre]="ripgrep, grep -P, Perl, PHP, VS Code, most editors"
    [python]="Python's re module, Django URL routing, pytest"
    [javascript]="Browsers, Node.js, frontend build tools"
    [posix - extended]="egrep, awk, modern sed -E"
    [posix - basic]="grep, traditional sed, legacy Unix utilities"
  )

  regex_normalize_flavor() {
    local raw="${1,,}"
    raw=${raw// /}
    raw=${raw//_/}
    raw=${raw//-/}
    case "$raw" in
    "") return 1 ;;
    pcre | perl | perlcompatible | perlregex | perlcompatibleregex)
      printf '%s' "pcre"
      ;;
    python | py)
      printf '%s' "python"
      ;;
    javascript | js | ecmascript | node | nodejs)
      printf '%s' "javascript"
      ;;
    posixextended | extended | ere)
      printf '%s' "posix-extended"
      ;;
    posixbasic | basic | bre)
      printf '%s' "posix-basic"
      ;;
    *)
      return 1
      ;;
    esac
  }

  regex_print_section() {
    local title="$1"
    shift
    cbc_style_box "$CATPPUCCIN_TEAL" "$title" "$@"
  }

  regex_select_flavor() {
    local selection=""
    local -a options=()
    local entry

    for entry in "${flavor_order[@]}"; do
      options+=("$entry|${flavor_names[$entry]} — ${flavor_tools[$entry]}")
    done

    if [ "$CBC_HAS_GUM" -eq 1 ]; then
      selection=$(printf '%s\n' "${options[@]}" |
        gum choose --header "Select a regex flavor" --limit 1 2>/dev/null)
    elif command -v fzf >/dev/null 2>&1; then
      selection=$(printf '%s\n' "${options[@]}" |
        fzf --prompt="Regex flavor > " \
          --header="TAB or arrows to move, ENTER to confirm" \
          --delimiter='|' --with-nth=2.. 2>/dev/null)
    fi

    if [ -z "$selection" ] && [ -t 0 ] && [ -t 1 ]; then
      local PS3="Choose a regex flavor (default ${flavor_names[$default_flavor]}): "
      select selection in "${options[@]}"; do
        if [ -n "$selection" ]; then
          break
        fi
      done
    fi

    if [ -z "$selection" ]; then
      return 1
    fi

    printf '%s\n' "${selection%%|*}"
  }

  regex_show_flavor() {
    local flavor="$1"

    cbc_style_box "$CATPPUCCIN_BLUE" "${flavor_names[$flavor]}" \
      "  Typical tools: ${flavor_tools[$flavor]}" \
      "  Tip: Use 'regex_help -l' to explore every option."

    case "$flavor" in
    pcre)
      regex_print_section "Anchors" \
        "  ^  Start of string (or line with (?m))" \
        "  $  End of string (or line with (?m))" \
        "  \\A  Absolute start of string" \
        "  \\z  Absolute end of string" \
        "  \\b  Word boundary" \
        "  \\B  Non-word boundary"

      regex_print_section "Quantifiers" \
        "  *   Zero or more" \
        "  +   One or more" \
        "  ?   Zero or one" \
        "  {m,n}  Between m and n (omit n for open range)" \
        "  *?, +?, ??  Lazy versions" \
        "  {m,n}?  Lazy bounded quantifier"

      regex_print_section "Character classes" \
        "  .        Any char except newline (use (?s) for dotall)" \
        "  \\d / \\D  Digit / not digit" \
        "  \\w / \\W  Word / not word" \
        "  \\s / \\S  Whitespace / not whitespace" \
        "  \\h / \\v  Horizontal / vertical whitespace" \
        "  \\p{L}    Unicode property (letters, numbers, etc.)"

      regex_print_section "Grouping & references" \
        "  (...)        Capturing group" \
        "  (?:...)      Non-capturing group" \
        "  (?<name>...) Named capturing group" \
        "  \\1, \\g<name>  Backreferences" \
        "  (?=...), (?!...)  Lookahead" \
        "  (?<=...), (?<!...) Lookbehind"

      regex_print_section "Flags" \
        "  (?i) case-insensitive   (?m) multiline ^/$" \
        "  (?s) dotall             (?x) verbose mode" \
        "  (?U) swap greedy/lazy   (?J) duplicate names"

      cbc_style_note "Example:" \
        "  (?i)^(?<user>[\\w.-]+)@(?<domain>[\\w.-]+\\.[A-Za-z]{2,})$" \
        "  • Captures case-insensitive emails with named groups."
      ;;
    python)
      regex_print_section "Anchors" \
        "  ^ / $    Start or end of string (line with re.MULTILINE)" \
        "  \\A / \\Z  Start / end of string regardless of flags" \
        "  \\b / \\B  Word boundary / non-boundary"

      regex_print_section "Quantifiers" \
        "  * 0+   + 1+   ? 0 or 1   {m,n} bounded" \
        "  Append ? for lazy variants (e.g., *?, +?, {m,n}?)"

      regex_print_section "Character classes" \
        "  . matches any char except newline (unless re.DOTALL)" \
        "  \\d, \\w, \\s mirror Unicode sets with re.UNICODE (default)" \
        "  \\N matches any char except newline" \
        "  Classes like [[:alpha:]] need re module's re.ASCII flag"

      regex_print_section "Grouping & references" \
        "  (?P<name>...)    Named capture" \
        "  (?P=name)        Named backreference" \
        "  (?=...), (?!...) Lookahead" \
        "  (?<=...), (?<!...) Lookbehind (fixed-width)" \
        "  (?(id)yes|no)    Conditional on group matched"

      regex_print_section "Flags" \
        "  re.I / (?i) ignore case    re.M / (?m) multiline" \
        "  re.S / (?s) dotall        re.X / (?x) verbose" \
        "  re.A / (?a) ASCII classes  re.U legacy alias"

      cbc_style_note "Example:" \
        "  (?P<slug>[a-z0-9-]+)(?:/(?P<page>\\d+))?$" \
        "  • Django-friendly URL slug with optional page number."
      ;;
    javascript)
      regex_print_section "Anchors" \
        "  ^ / $  Start / end of string" \
        "  \\b / \\B  Word boundary / non-boundary" \
        "  (?<=^|\\s) simulate start-of-word when \\b is insufficient"

      regex_print_section "Quantifiers" \
        "  * 0+   + 1+   ? 0 or 1   {m,n} bounded" \
        "  Lazy versions use ? (e.g., .*?)" \
        "  Possessive quantifiers x*+ available in modern engines"

      regex_print_section "Character classes" \
        "  . matches any char except newline (use [\\s\\S] for dotall)" \
        "  \\d, \\w, \\s follow ECMAScript definitions" \
        "  \\p{Letter} requires the /u flag for Unicode sets" \
        "  Character class escapes like [\u{1F4A9}] need /u"

      regex_print_section "Grouping & references" \
        "  (?<name>...) Named capture (ES2018+)" \
        "  \\1 or \\k<name> Backreferences" \
        "  (?=...), (?!...) Lookahead" \
        "  (?<=...), (?<!...) Lookbehind (modern runtimes only)"

      regex_print_section "Flags" \
        "  /i ignore case   /m multiline ^/$" \
        "  /s dotall        /u Unicode" \
        "  /g global match  /y sticky (anchor to lastIndex)"

      cbc_style_note "Example:" \
        "  const rx = /^(?<tag>[a-z]+)(?:-(?<variant>\\w+))?$/i;" \
        "  // Capture <tag>-<variant> attributes case-insensitively."
      ;;
    posix-extended)
      regex_print_section "Anchors" \
        "  ^ start of line    $ end of line" \
        "  Use \\b inside character classes (e.g., [[:<:]]) for words"

      regex_print_section "Quantifiers" \
        "  * 0+   + 1+   ? 0 or 1   {m,n} bounded" \
        "  No lazy or possessive variants"

      regex_print_section "Character classes" \
        "  . matches any char except newline" \
        "  [:class:] named classes: [:alpha:], [:digit:], [:alnum:], [:space:]" \
        "  Bracket expressions like [^abc] negate character sets" \
        "  No \\d / \\w shortcuts—use [:digit:], [:alnum:], etc."

      regex_print_section "Grouping & alternation" \
        "  (...) capture group    (?:...) unavailable" \
        "  | alternation          Backreferences with \\1, \\2" \
        "  No lookaround or named groups"

      regex_print_section "Usage notes" \
        "  Works with egrep, awk, and sed -E" \
        "  Portable across most Unix-like systems" \
        "  Ideal when scripting with POSIX tools that support ERE"

      cbc_style_note "Example:" \
        "  egrep '^[[:alnum:]_]+@[[:alnum:].-]+\\.[[:alpha:]]{2,}$' file" \
        "  • Email validation using portable character classes."
      ;;
    posix-basic)
      regex_print_section "Anchors" \
        "  ^ start of line    $ end of line" \
        "  [[:<:]] and [[:>:]] for word boundaries (GNU extensions)"

      regex_print_section "Quantifiers" \
        "  * 0+   \{m,n\} bounded" \
        "  +, ?, |, () are literals unless escaped" \
        "  Use \+, \?, \|, \(, \) for regex operators"

      regex_print_section "Character classes" \
        "  . matches any char except newline" \
        "  [:class:] works inside [] just like ERE" \
        "  Escapes like \\d or \\w are not supported"

      regex_print_section "Grouping & references" \
        "  \( ... \) capture group" \
        "  \{m\} literal braces require escaping: \\{" \
        "  Backreferences: \\1, \\2" \
        "  No alternation without \| and no non-capturing groups"

      regex_print_section "Usage notes" \
        "  Default for grep and sed without -E" \
        "  Preferred when targeting the most portable scripts" \
        "  Escaping operators is the most common pitfall"

      cbc_style_note "Example:" \
        "  grep '\\<[[:digit:]]\\{3\\}\\>' numbers.txt" \
        "  • Find three-digit numbers in GNU grep (word boundaries)."
      ;;
    esac
  }

  if $list_only; then
    local -a lines=("  Available regex flavors:")
    local key
    for key in "${flavor_order[@]}"; do
      lines+=("    - ${flavor_names[$key]} [${key}] — ${flavor_tools[$key]}")
    done
    cbc_style_box "$CATPPUCCIN_BLUE" "Regex flavors" "${lines[@]}"
    return 0
  fi

  local normalized=""

  if [ -n "$requested_flavor" ]; then
    if ! normalized=$(regex_normalize_flavor "$requested_flavor"); then
      cbc_style_message "$CATPPUCCIN_RED" \
        "Error: Unknown regex flavor '$requested_flavor'"
      cbc_style_note "Hint:" \
        "  Use 'regex_help -l' to see supported flavors." \
        "  Examples: pcre, python, javascript, posix-extended, posix-basic."
      return 1
    fi
  elif $interactive; then
    if ! normalized=$(regex_select_flavor); then
      cbc_style_message "$CATPPUCCIN_RED" "No selection made; showing default."
      normalized="$default_flavor"
    fi
  else
    normalized="$default_flavor"
  fi

  regex_show_flavor "$normalized"

  cbc_style_note "Need more?" \
    "  Combine 'rg --pcre2', 'python -m re', or 'node --eval' with these" \
    "  snippets to test patterns quickly in your favorite environment."
}

################################################################################
# UPDATECBC
################################################################################

updatecbc() {
  # Initialize OPTIND to 1 since it is a global variable within the script
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Update the Custom Bash Commands repository and reload configuration."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  updatecbc [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  updatecbc"
  }

  # Parse options using getopts
  while getopts ":h" opt; do
    case ${opt} in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      ;;
    esac
  done

  shift $((OPTIND - 1))

  local SPARSE_DIR
  local REPO_URL
  local FILE_PATHS
  local new_filename
  local copy_errors=0

  # Temporary directory for sparse checkout
  SPARSE_DIR=$(mktemp -d)

  # URL of the GitHub repository
  REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

  # List of file paths to download and move
  FILE_PATHS=(
    custom_bash_commands.sh
    cbc_aliases.sh
  )

  cbc_style_box "$CATPPUCCIN_BLUE" "Updating Custom Bash Commands"

  if ! cbc_confirm "Pull the latest version and overwrite local files?"; then
    cbc_style_message "$CATPPUCCIN_YELLOW" "Update cancelled."
    rm -rf "$SPARSE_DIR"
    return 0
  fi

  # Initialize an empty git repository and configure for sparse checkout
  if ! cbc_spinner "Preparing temporary checkout" \
    bash -c "cd '$SPARSE_DIR' && git init -q && git remote add origin '$REPO_URL' \
    && git config core.sparseCheckout true"; then
    cbc_style_message "$CATPPUCCIN_RED" "Failed to prepare sparse checkout."
    rm -rf "$SPARSE_DIR"
    return 1
  fi

  for path in "${FILE_PATHS[@]}"; do
    echo "$path" >>"$SPARSE_DIR/.git/info/sparse-checkout"
  done

  if ! cbc_spinner "Downloading updates" \
    bash -c "cd '$SPARSE_DIR' && git pull origin main -q"; then
    cbc_style_message "$CATPPUCCIN_RED" "Unable to download updates from the repository."
    rm -rf "$SPARSE_DIR"
    return 1
  fi

  for path in "${FILE_PATHS[@]}"; do
    new_filename="$(basename "$path")"
    if [[ $new_filename != .* ]]; then
      new_filename=".$new_filename"
    fi

    if ! cbc_spinner "Updating $new_filename" \
      cp "$SPARSE_DIR/$path" "$HOME/$new_filename"; then
      cbc_style_message "$CATPPUCCIN_RED" "Failed to copy $path."
      copy_errors=1
    fi
  done

  rm -rf "$SPARSE_DIR"
  cd ~ || return
  clear

  if [ $copy_errors -eq 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Update incomplete. Please retry."
    return 1
  fi

  cbc_style_message "$CATPPUCCIN_GREEN" "Custom Bash Commands updated. Reloading..."

  # Source the updated commands
  source ~/.custom_bash_commands.sh
  display_version
}

###############################################################################
# Auto-load installed CBC modules
###############################################################################

cbc_pkg_load_modules auto

###############################################################################
# Call the function to display information once per interactive session
###############################################################################

if [[ $- == *i* ]]; then
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
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
