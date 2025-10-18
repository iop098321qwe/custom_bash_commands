#!/usr/bin/env bash

# -------------------------------------------------------------------------------------------------
# Charmbracelet Gum helpers (Catppuccin Mocha palette)
# -------------------------------------------------------------------------------------------------

# Only initialize styling helpers if they have not been defined already. This allows the module to
# be sourced alongside custom_bash_commands.sh without overwriting shared helpers.
if [ -z "${CBC_HAS_GUM+x}" ]; then
  if command -v gum >/dev/null 2>&1; then
    CBC_HAS_GUM=1
  else
    CBC_HAS_GUM=0
  fi
fi

: "${CATPPUCCIN_ROSEWATER:=#f5e0dc}"
: "${CATPPUCCIN_FLAMINGO:=#f2cdcd}"
: "${CATPPUCCIN_PINK:=#f5c2e7}"
: "${CATPPUCCIN_MAUVE:=#cba6f7}"
: "${CATPPUCCIN_RED:=#f38ba8}"
: "${CATPPUCCIN_MAROON:=#eba0ac}"
: "${CATPPUCCIN_PEACH:=#fab387}"
: "${CATPPUCCIN_YELLOW:=#f9e2af}"
: "${CATPPUCCIN_GREEN:=#a6e3a1}"
: "${CATPPUCCIN_TEAL:=#94e2d5}"
: "${CATPPUCCIN_SKY:=#89dceb}"
: "${CATPPUCCIN_SAPPHIRE:=#74c7ec}"
: "${CATPPUCCIN_BLUE:=#89b4fa}"
: "${CATPPUCCIN_LAVENDER:=#b4befe}"
: "${CATPPUCCIN_TEXT:=#cdd6f4}"
: "${CATPPUCCIN_SUBTEXT:=#a6adc8}"
: "${CATPPUCCIN_OVERLAY:=#6c7086}"
: "${CATPPUCCIN_SURFACE0:=#313244}"
: "${CATPPUCCIN_SURFACE1:=#45475a}"
: "${CATPPUCCIN_SURFACE2:=#585b70}"
: "${CATPPUCCIN_BASE:=#1e1e2e}"

if ! declare -f cbc_style_box >/dev/null 2>&1; then
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
fi

if ! declare -f cbc_style_message >/dev/null 2>&1; then
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
fi

if ! declare -f cbc_confirm >/dev/null 2>&1; then
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
fi

if ! declare -f cbc_spinner >/dev/null 2>&1; then
  cbc_spinner() {
    local title="$1"
    shift
    if [ "$CBC_HAS_GUM" -eq 1 ]; then
      gum spin --spinner dot --title "$title" --title.foreground "$CATPPUCCIN_MAUVE" -- "$@"
    else
      "$@"
    fi
  }
fi

# This script will contain all of the logic associated with the pron module.
# It should be sourced by the main script if the pron module is enabled.
#
# Part of this should also include building a module system for the CBC script.
# This will allow for the easy addition of new modules in the future.
# Potentially, some of the functions that are already written into the main CBC script should be moved here.
#
# Potential other modules:
# * cbc-pron
#   - this will contain all of the logic for the personal pron module
# * cbc-git
#   - this will contain all of the logic for the git shortcuts module
# * cbc-sorting
#   - this will contain all of the logic for the file sorting module
# * cbc-install
#   - this will contain all of the logic for the software quick-installation module
#
# Some of the functions that are currently in the main script that should be moved here:
#
# * pron
# * pronlist
# * uml
# * phopen
# * phsearch
#
# MANY MORE TO BE ADDED
#
# Consider writing multi-stage functions for the pron module, such as:
#
# * ph open
# * ph search
# * ph list

################################################################################################################################################################
# Functions
################################################################################################################################################################

################################################################################
# PRONLIST
################################################################################

# pronlist
# Description: Function to process URLs listed in _batch.txt and download files
#              using yt-dlp with a specified configuration file. The titles of
#              the downloaded files are saved to individual output files.
# Usage: pronlist [-h] [-l line_number]
# Options:
#   -h    Show this help message and exit
#   -l    Process a specific line number from _batch.txt
#
# Example: pronlist
#          pronlist -l 3
#
# Requires:
#   - _batch.txt: File containing URLs (one per line)
#   - _configs.txt: yt-dlp configuration file
################################################################################

# Function to generate a list of what each url downloads using yt-dlp
pronlist() {
  # Function to display usage information for the script
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Processes each URL in the selected .txt file and uses yt-dlp with the _configs.txt" \
      "  configuration file to generate a sanitized output file listing the downloaded titles."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" "  pronlist [-h] [-l]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Show this help message and exit" \
      "  -l    Select and process a specific line from the selected .txt file"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  pronlist" \
      "  pronlist -l 3"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Requires:" \
      "  - _batch.txt: File containing URLs (one per line)" \
      "  - _configs.txt: yt-dlp configuration file"
  }

  # Function to check the presence of the configuration file
  check_config_file() {
    if [ ! -f "_configs.txt" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: _configs.txt not found in the current directory."
      return 1
    fi
  }

  # Function to display a selection menu for batch files using fzf
  select_batch_file() {
    local selected_file
    selected_file=$(find . -maxdepth 1 -name "*.txt" 2>/dev/null | fzf --prompt="Select a batch file: ")

    if [ -z "$selected_file" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: No file selected."
      return 1
    fi

    echo "${selected_file#./}"
  }

  # Function to reset variables for clean execution
  reset_variables() {
    OPTIND=1                 # Reset option index for getopts parsing
    line=""                  # Reset the line content
    output_file=""           # Reset the output file name
    batch_file=""            # Reset the batch file name
    use_line_selection=false # Reset the line selection flag
  }

  # Function to prompt user whether to overwrite an existing file
  prompt_overwrite() {
    local file="$1"
    if cbc_confirm "File '$file' already exists. Overwrite?"; then
      return 0
    fi
    cbc_style_message "$CATPPUCCIN_YELLOW" "Skipping existing file: $file"
    return 1
  }

  # Reset variables at the start
  reset_variables

  # Parse command-line options using getopts
  while getopts "hl" opt; do
    case "$opt" in
    h)
      usage # Display usage information
      return 0
      ;;
    l)
      use_line_selection=true # Indicate that fzf should be used to select a line
      ;;
    ?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1)) # Shift parsed options to access remaining arguments

  # Prompt the user to select a batch file
  batch_file=$(select_batch_file) || return 1

  # Check if the configuration file exists
  check_config_file || return 1

  # If the -l flag is provided, select a specific line using fzf
  if [ "$use_line_selection" = true ]; then
    line=$(cat "$batch_file" | fzf --prompt="Select a URL line: ")
    if [ -z "$line" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: No URL selected."
      return 1
    fi

    # Generate a sanitized filename based on the URL
    output_file="$(echo "$line" | sed -E 's|.*\.com||; s|[^a-zA-Z0-9]|_|g').txt"

    # Check if the output file exists and prompt for overwrite
    if [ -f "$output_file" ]; then
      prompt_overwrite "$output_file" || return 0
    fi

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Processing selected URL:" "  $line"

    # Execute yt-dlp and save the output to the file
    yt-dlp --cookies-from-browser brave -f b "$line" --print "%(title)s" | tee "$output_file"

    cbc_style_message "$CATPPUCCIN_GREEN" "Processing complete."
    reset_variables # Reset variables after processing
    return 0
  fi

  # Default behavior: Process each line in the selected batch file
  while IFS= read -r line || [ -n "$line" ]; do
    # Skip empty lines
    if [ -z "$line" ]; then
      continue
    fi

    # Generate a sanitized filename based on the URL
    output_file="$(echo "$line" | sed -E 's|.*\.com||; s|[^a-zA-Z0-9]|_|g').txt"

    # Check if the output file exists and prompt for overwrite
    if [ -f "$output_file" ]; then
      prompt_overwrite "$output_file" || continue
    fi

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Processing URL:" "  $line"

    # Execute yt-dlp and save the output to the file
    yt-dlp --cookies-from-browser brave -f b "$line" --print "%(title)s" | tee "$output_file"
  done <"$batch_file"

  cbc_style_message "$CATPPUCCIN_GREEN" "Processing complete."
  reset_variables # Reset variables after all lines are processed
}

################################################################################
# SOPEN
################################################################################

# sopen
# Description: Function to open .mp4 files in the current directory that match
#              patterns generated from lines in a selected .txt file.
# Usage: sopen
# Options:

# Example: sopen  --- Prompts for a .txt file and opens matching .mp4 files.

##########

# Function to open .mp4 files matching patterns from a .txt file
sopen() {
  # Use fzf to select a .txt file in the current directory
  local file
  file=$(find . -maxdepth 1 -type f -name "*.txt" | fzf --prompt="Select a .txt file: ")

  # If no file is selected, exit the function
  if [ -z "$file" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "No file selected. Exiting..."
    return 1
  fi

  # Function to create a regex pattern from a line by:
  # 1) Converting all non-alphanumeric characters to spaces
  # 2) Replacing spaces with '.*'
  # 3) Adding '.*' at the start and end of the pattern
  generate_pattern() {
    local input="$1"

    # Convert all non-alphanumeric characters to spaces and normalize spaces
    # Example: "foo/bar'baz" -> "foo bar baz"
    local cleaned_line
    cleaned_line=$(echo "$input" | sed 's/[^[:alnum:]]/ /g' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//')

    # Replace spaces with '.*'
    # "foo bar baz" -> "foo.*bar.*baz"
    local base_pattern
    base_pattern=$(echo "$cleaned_line" | sed 's/[[:space:]]\+/.*/g')

    # Add '.*' at the start and end of the pattern
    # "foo.*bar.*baz" -> ".*foo.*bar.*baz.*"
    echo ".*${base_pattern}.*"
  }

  # Read each line in the selected file
  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Generate a regex pattern from the cleaned line
    local pattern
    pattern=$(generate_pattern "$line")

    # Search for .mp4 files in the current directory that match the pattern
    local mp4_files
    mp4_files=$(find . -maxdepth 1 -type f -name "*.mp4" -printf "%f\n" | grep -E -i "$pattern")

    # If matching .mp4 files are found, open them
    if [[ -n "$mp4_files" ]]; then
      #echo "Opening .mp4 files matching: '$line' (Pattern: $pattern)"
      while IFS= read -r mp4; do
        #echo "Opening: $mp4"
        xdg-open "./$mp4" &
      done <<<"$mp4_files"
    else
      cbc_style_message "$CATPPUCCIN_YELLOW" "No .mp4 files found matching: '$line'"
    fi
  done <"$file"
}

################################################################################
# SOPENEXACT
################################################################################

# sopenexact
# Description: Function to open .mp4 files in the current directory that match
#              patterns generated from lines in a selected .txt file.
# Usage: sopenexact
# Options:

# Example: sopenexact  --- Prompts for a .txt file and opens matching .mp4 files.

##########

# Function to open .mp4 files matching patterns from a .txt file
sopenexact() {
  # Use fzf to select a .txt file in the current directory
  local file
  file=$(find . -maxdepth 1 -type f -name "*.txt" | fzf -e --prompt="Select a .txt file: ")

  # If no file is selected, exit the function
  if [ -z "$file" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "No file selected. Exiting..."
    return 1
  fi

  # Function to create a regex pattern from a line by:
  # 1) Converting all non-alphanumeric characters to spaces
  # 2) Replacing spaces with '.*'
  # 3) Adding '.*' at the start and end of the pattern
  generate_pattern() {
    local input="$1"

    # Convert all non-alphanumeric characters to spaces and normalize spaces
    # Example: "foo/bar'baz" -> "foo bar baz"
    local cleaned_line
    cleaned_line=$(echo "$input" | sed 's/[^[:alnum:]]/ /g' | sed 's/[[:space:]]\+/ /g' | sed 's/^ *//;s/ *$//')

    # Replace spaces with '.*'
    # "foo bar baz" -> "foo.*bar.*baz"
    local base_pattern
    base_pattern=$(echo "$cleaned_line" | sed 's/[[:space:]]\+/.*/g')

    # Add '.*' at the start and end of the pattern
    # "foo.*bar.*baz" -> ".*foo.*bar.*baz.*"
    echo ".*${base_pattern}.*"
  }

  # Read each line in the selected file
  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Generate a regex pattern from the cleaned line
    local pattern
    pattern=$(generate_pattern "$line")

    # Search for .mp4 files in the current directory that match the pattern
    local mp4_files
    mp4_files=$(find . -maxdepth 1 -type f -name "*.mp4" -printf "%f\n" | grep -E -i "$pattern")

    # If matching .mp4 files are found, open them
    if [[ -n "$mp4_files" ]]; then
      #echo "Opening .mp4 files matching: '$line' (Pattern: $pattern)"
      while IFS= read -r mp4; do
        #echo "Opening: $mp4"
        xdg-open "./$mp4" &
      done <<<"$mp4_files"
    else
      cbc_style_message "$CATPPUCCIN_YELLOW" "No .mp4 files found matching: '$line'"
    fi
  done <"$file"
}

################################################################################
# RANDOM
################################################################################

# random
# Description: Function to open a random .mp4 file in the current directory
# Usage: random
# Options:
#   -h    Display this help message

# Example: random  ---Opens a random .mp4 file in the current directory.

################################################################################

# Function to open a random .mp4 file in the current directory
random() {
  # Function to display help message
  show_help() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Function to open a random .mp4 file in the current directory."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" "  random [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" "  random"
  }

  # Parse options using getopts
  while getopts ":h" opt; do
    case $opt in
    h)
      show_help
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      show_help
      return 1
      ;;
    esac
  done

  # Gather all .mp4 files in the current directory
  mp4_files=(./*.mp4)

  # Check if there are any mp4 files
  if [ ${#mp4_files[@]} -eq 0 ] || [ ! -e "${mp4_files[0]}" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "No mp4 files found in the current directory."
    return 1
  fi

  # Select a random file from the list
  random_file=$(find . -maxdepth 1 -type f -name "*.mp4" | shuf -n 1)

  # Open the random file using the default application
  nohup xdg-open "$random_file" 2>/dev/null

  # Check if the file was opened successfully
  if [ $? -ne 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Failed to open the file: $random_file"
    return 1
  fi

  cbc_style_message "$CATPPUCCIN_GREEN" "Opened: $random_file"
}

# Place this entire function in your .bashrc or other shell configuration file.
# Then, reload your shell or source .bashrc to use it.

################################################################################
# SORTALPHA
################################################################################

# TODO: Add comments and -h flag for clarity in the function
sortalpha() {
  # initialize local variables
  local extension=""
  local first_letter=""

  # Reset getopts index to handle multiple runs
  OPTIND=1

  # parse options using getopts
  while getopts ":h" opt; do
    case $opt in
    h)
      cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
        "  Sort files in the current directory alphabetically grouped by extension."
      cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" "  sortalpha [-h]"
      cbc_style_box "$CATPPUCCIN_TEAL" "Options:" "  -h    Display this help message"
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # HELPER: check if fzf is installed
  check_fzf_install() {
    if ! command -v fzf >/dev/null 2>&1; then
      cbc_style_message "$CATPPUCCIN_RED" "fzf is not installed. Please install fzf first."
      return 1
    fi
  }

  # HELPER: check if the extension variable is empty
  check_ext() {
    if [ -z "$extension" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "No extension selected. Exiting..."
      return 1
    fi
  }

  # HELPER: choose extension to sort files by
  select_extension() {
    # prompt the user to select an extension to sort files by and assign to "extension" variable
    extension=$(find . -maxdepth 1 -type f | sed 's/.*\.//' | sort -u | fzf --prompt="Select an extension to sort files by: ")

    # check if the extension variable is empty
    check_ext || return 1

    # display a message to the user for the extension to sort files by
    cbc_style_message "$CATPPUCCIN_SKY" "Sorting files by extension: $extension"
  }

  # HELPER: iterate through each file in the current directory and move to a new directory based on the first letter of the file
  move_files() {
    check_ext || return 1
    for file in *."$extension"; do
      if [ -f "$file" ]; then
        first_letter=$(echo "$file" | cut -c1 | tr '[:upper:]' '[:lower:]')
        mkdir -p "$first_letter"
        mv "$first_letter"*."$extension" "$first_letter"/
      fi
    done
    cbc_style_message "$CATPPUCCIN_GREEN" "File sorting alphabetically completed successfully."
  }

  # MAIN LOGIC

  # Check if fzf is installed
  check_fzf_install || return 1

  # select extension to sort files by
  select_extension || return 1

  # move files to new directories based on the first letter of the file
  move_files
  cbc_style_message "$CATPPUCCIN_SUBTEXT" "No way to undo what you have just done... Maybe use ranger and manually move back? :)"
}

################################################################################
# PHSEARCH
################################################################################

# phsearch
# Description: Prompts the user for a search term, constructs a search URL, and opens it
# Usage: phsearch
# Options:
#   -h    Display this help message

# Example: phsearch
# Enter search term: funny cats
# Opens: https://www.example.com/video/search?search=funny+cats

################################################################################
# Function to prompt for a search term, construct a URL, and open it in the default browser
phsearch() {
  OPTIND=1 # Reset getopts index to handle multiple runs

  # Function to display help
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Prompts the user for a search term, constructs a search URL, and opens it." \
      "  Uses Gum for prompts when available."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" "  phsearch [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" "  phsearch"
  }

  # Parse options
  while getopts "h" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    *)
      usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # Prompt user for a search term
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    search_term=$(gum input \
      --prompt.foreground "$CATPPUCCIN_LAVENDER" \
      --cursor.foreground "$CATPPUCCIN_GREEN" \
      --placeholder "Enter search term..." \
      --prompt "Search Term » ")
  else
    read -r -p "Enter search term: " search_term
  fi

  if [ -z "$search_term" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "No search term entered. Exiting..."
    return 1
  fi

  # Replace spaces in the search term with '+' using parameter expansion
  formatted_term=${search_term// /+}

  # Construct the search URL
  search_url="https://www.pornhub.com/video/search?search=${formatted_term}"

  cbc_style_message "$CATPPUCCIN_SKY" "🔍 Searching for: $search_term"
  cbc_style_box "$CATPPUCCIN_TEAL" "URL:" "  $search_url"

  if cbc_confirm "Open this search in your browser?"; then
    nohup xdg-open "$search_url" >/dev/null 2>&1 &
    cbc_style_message "$CATPPUCCIN_GREEN" "✅ Search opened successfully!"
  else
    cbc_style_message "$CATPPUCCIN_RED" "❌ Search canceled."
  fi
}

################################################################################################################################################################
# Aliases
################################################################################################################################################################

alias batch_open='file=$(cat _master_batch.txt | fzf --prompt="Select a file: "); while IFS= read -r line; do xdg-open "$line"; done < "$file"'
alias bo='batch_open'
alias iopen='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias iopenexact='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias io='iopen'
alias ioe='iopenexact'
alias mopen='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias mopenexact='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias mo='mopen'
alias moe='mopenexact'
alias pron='fzf --multi=1 < _master_batch.txt | xargs -I {} yt-dlp --config-locations _configs.txt --batch-file {}'
alias pronfile='cd /media/$USER/T7 Shield/yt-dlp'
alias pronupdate='pronfile && pron || pron'
alias pu='pronupdate'
alias so='sopen'
alias soe='sopenexact'
alias update_master_list='cat _master_batch.txt | xargs -I {} cat {} | sort -u > _temp_master_list.txt && mv _temp_master_list.txt _master_list.txt && batcat _master_list.txt'
alias uml='update_master_list'
alias vault='cd ~/Documents/grymms_grimoires && ls'
alias vopen='find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias vopenexact='find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias vo='vopen'
alias voe='vopenexact'
