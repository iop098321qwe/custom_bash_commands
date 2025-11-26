#!/usr/bin/env bash
VERSION="v305.6.0"

###############################################################################
# Charmbracelet Gum helpers (Catppuccin Mocha palette)
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

###################################################################################################################################################################
# CUSTOM BASH COMMANDS
###################################################################################################################################################################

################################################################################################################################################################
# PRON MODULE
################################################################################################################################################################

# TODO: Find a way to make pron module work with the cbcs command to show help information.
# this should modularize the code better and allow users to optionally load/unload the pron module.

###################################################################################################################################################################
# BATCHOPEN
###################################################################################################################################################################

batchopen() {
  # Reset getopts in case this function is called multiple times
  OPTIND=1
  local file=""

  # Usage/help function
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Opens a .txt file of URLs and iterates through each line, opening them in the default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  batchopen [options] [file]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h      Display this help message" \
      "  -f      Specify a file containing URLs (one per line)"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  batchopen -f sites.txt" \
      "  batchopen  (will prompt for a file via fzf)"
  }

  # Parse command-line flags
  while getopts "hf:" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    f)
      file="$OPTARG"
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1))

  # If no file was specified with -f, let user pick a .txt file via fzf
  if [ -z "$file" ]; then
    file="$(find . -maxdepth 1 -type f -name "*.txt" | fzf --prompt="Select a .txt file: ")"
    if [ -z "$file" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "No file selected. Exiting..."
      return 1
    fi
  fi

  # If the file still doesn't exist, exit
  if [ ! -f "$file" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: File '$file' not found."
    return 1
  fi

  # For each line in the file, open the URL in the default browser
  while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Attempt to open each URL in the system default browser
    if command -v brave-browser >/dev/null 2>&1; then
      nohup brave-browser "$line" &
    elif command -v xdg-open >/dev/null 2>&1; then
      nohup xdg-open "$line" &
    elif command -v open >/dev/null 2>&1; then
      nohup open "$line"
    else
      cbc_style_box "$CATPPUCCIN_RED" "No recognized browser open command found. Please open this URL manually:" "$line"
    fi
  done <"$file"
}

################################################################################
# PHOPEN
################################################################################

phopen() {
  URL_PREFIX="https://www.pornhub.com/view_video.php?viewkey="
  OPTIND=1

  while getopts "h" opt; do
    case "$opt" in
    h)
      cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
        "  Opens special .mp4 files in the browser using fzf and a predefined URL prefix."
      cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" "  phopen [-h]"
      cbc_style_box "$CATPPUCCIN_TEAL" "Options:" "  -h    Display this help message"
      cbc_style_box "$CATPPUCCIN_PEACH" "Example:" "  phopen"
      return 0
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  selected="$(find . -maxdepth 1 -type f -name "*.mp4" | fzf -e -m --prompt='Select your .mp4 file(s): ')"
  [ -z "$selected" ] && return 0

  while IFS= read -r file; do
    filename="${file%.*}"
    if [[ "$filename" =~ \[(.*)\] ]]; then
      content="${BASH_REMATCH[1]}"
      url="${URL_PREFIX}${content}"

      if command -v xdg-open >/dev/null 2>&1; then
        nohup xdg-open "$url"
      elif command -v open >/dev/null 2>&1; then
        nohup open "$url"
      else
        cbc_style_box "$CATPPUCCIN_RED" "No recognized browser open command found. Please open this URL manually:" "$url"
      fi
    fi
  done <<<"$selected"
}

################################################################################
# PHSEARCH
################################################################################

phsearch() {
  # Function to display usage
  usage() {
    # Description Box
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Prompts the user for a search term, constructs a search URL, and opens it in the default browser."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  phsearch [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  phsearch"
  }

  OPTIND=1

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

  # Prompt user for a search term using gum input
  if [ "$CBC_HAS_GUM" -eq 1 ]; then
    search_term=$(gum input \
      --prompt.foreground "$CATPPUCCIN_LAVENDER" \
      --cursor.foreground "$CATPPUCCIN_GREEN" \
      --placeholder "Enter search term..." \
      --prompt "Search Term » ")
  else
    read -r -p "Enter search term: " search_term
  fi

  # Exit if no input is given
  if [[ -z "$search_term" ]]; then
    cbc_style_message "$CATPPUCCIN_RED" "No search term entered. Exiting..."
    return 1
  fi

  # Replace spaces in the search term with '+' using parameter expansion
  formatted_term=${search_term// /+}

  # Construct the search URL
  search_url="https://www.pornhub.com/video/search?search=${formatted_term}"

  # Show the search URL before opening it
  cbc_style_message "$CATPPUCCIN_SKY" "🔍 Searching for: $search_term"
  cbc_style_box "$CATPPUCCIN_TEAL" "URL:" "  $search_url"

  # Ask for confirmation before opening
  if cbc_confirm "Open this search in your browser?"; then
    cbc_spinner "Opening browser..." nohup xdg-open "$search_url" >/dev/null 2>&1 &
    cbc_style_message "$CATPPUCCIN_GREEN" "✅ Search opened successfully!"
  else
    cbc_style_message "$CATPPUCCIN_RED" "❌ Search canceled."
  fi
}

################################################################################
# PRONLIST
################################################################################

pronlist() {
  # Function to display usage information for the script
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Processes each URL in the selected .txt file and uses yt-dlp with the _configs.txt" \
      "  configuration file to generate a sanitized output file listing the downloaded titles."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  pronlist [-h | -l]"

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
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
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

sopen() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Opens .mp4 files in the current directory that match patterns" \
      "  generated from lines in a selected .txt file."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  sopen [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  sopen"
  }

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
      while IFS= read -r mp4; do
        xdg-open "./$mp4" &
      done <<<"$mp4_files"
      cbc_style_message "$CATPPUCCIN_GREEN" "Opened files matching: '$line'"
    else
      cbc_style_message "$CATPPUCCIN_YELLOW" "No .mp4 files found matching: '$line'"
    fi
  done <"$file"
}

################################################################################
# SOPENEXACT
################################################################################

sopenexact() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Opens .mp4 files in the current directory that match exact" \
      "  patterns generated from lines in a selected .txt file."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  sopenexact [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  sopenexact"
  }

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
      while IFS= read -r mp4; do
        xdg-open "./$mp4" &
      done <<<"$mp4_files"
      cbc_style_message "$CATPPUCCIN_GREEN" "Opened files matching: '$line'"
    else
      cbc_style_message "$CATPPUCCIN_YELLOW" "No .mp4 files found matching: '$line'"
    fi
  done <"$file"
}

################################################################################################################################################################

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
# REPEAT
################################################################################

repeat() {
  OPTIND=1        # Reset getopts index to handle multiple runs
  local delay=0   # Default delay is 0 seconds
  local verbose=0 # Default verbose mode is off
  local count     # Declare count as a local variable to limit its scope

  # Function to display help
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Repeats any given command a specified number of times."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  repeat [-h] count [-d delay] [-v] command [arguments...]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h            Display this help message and return" \
      "  -d delay      Delay in seconds between each repetition" \
      "  -v            Enable verbose mode for debugging and tracking runs"

    cbc_style_box "$CATPPUCCIN_LAVENDER" "Arguments:" \
      "  count         The number of times to repeat the command" \
      "  command       The command(s) to be executed (use ';' to separate multiple commands)" \
      "  [arguments]   Optional arguments passed to the command(s)"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  repeat 3 echo \"Hello, World!\"" \
      "  repeat 5 -d 2 -v echo \"Hello, World!\""
  }

  # Parse options first
  while getopts "hd:v" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    d)
      delay="$OPTARG"
      if ! echo "$delay" | grep -Eq '^[0-9]+$'; then
        cbc_style_message "$CATPPUCCIN_RED" "Error: DELAY must be a non-negative integer."
        return 1
      fi
      ;;
    v)
      verbose=1
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      usage
      return 1
      ;;
    esac
  done
  shift $((OPTIND - 1)) # Remove parsed options from arguments

  # Check if help flag was invoked alone
  if [ "$OPTIND" -eq 2 ] && [ "$#" -eq 0 ]; then
    return 0
  fi

  # Ensure count argument exists
  if [ "$#" -lt 2 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Missing count and command arguments."
    usage
    return 1
  fi

  count=$1 # Assign count within local scope
  shift

  # Ensure count is a valid positive integer
  if ! echo "$count" | grep -Eq '^[0-9]+$'; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: COUNT must be a positive integer."
    usage
    return 1
  fi

  # Ensure a command is provided
  if [ "$#" -lt 1 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: No command provided."
    usage
    return 1
  fi

  # Combine remaining arguments as a single command string
  local cmd="$*"

  # Repeat the command COUNT times with optional delay
  for i in $(seq 1 "$count"); do
    if [ "$verbose" -eq 1 ]; then
      cbc_style_message "$CATPPUCCIN_SKY" "Running iteration $i of $count: $cmd"
    fi
    eval "$cmd"
    if [ "$delay" -gt 0 ] && [ "$i" -lt "$count" ]; then
      if [ "$verbose" -eq 1 ]; then
        cbc_style_message "$CATPPUCCIN_SUBTEXT" "Sleeping for $delay seconds..."
      fi
      sleep "$delay"
    fi
  done
}

################################################################################
# SMARTSORT
################################################################################

smartsort() {
  local mode=""            # Sorting mode (ext, alpha, time, size, type)
  local interactive_mode=0 # Flag for interactive refinements
  local target_dir="."     # Destination directory for sorted folders
  local first_letter=""
  local file=""
  local time_grouping="month"
  local type_granularity="top-level"
  local small_threshold_bytes=1048576   # 1MB default
  local medium_threshold_bytes=10485760 # 10MB default
  local summary_details=""
  local -a selected_extensions=()

  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Organises files in the current directory according to the mode you choose." \
      "  Available modes:" \
      "    - ext   : Group by file extension (supports multi-selection)." \
      "    - alpha : Group by the first character of the filename." \
      "    - time  : Group by modification time (year, month, or day)." \
      "    - size  : Group by file size buckets (customisable thresholds)." \
      "    - type  : Group by MIME type (top-level or full type)."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  smartsort [-h] [-i] [-m mode] [-d directory]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h            Display this help message." \
      "  -i            Enable interactive prompts for advanced configuration." \
      "  -m mode       Specify the sorting mode directly (ext|alpha|time|size|type)." \
      "  -d directory  Destination root for sorted folders (defaults to current directory)."

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  smartsort -i" \
      "  smartsort -m type -d ./sorted" \
      "  smartsort -i -m size"
  }

  smartsort_select_mode() {
    local selection=""
    if command -v fzf >/dev/null 2>&1; then
      selection=$(printf "ext\nalpha\ntime\nsize\ntype\n" |
        fzf --prompt="Select sorting mode: " --header="Choose how to organise files")
    elif [ "$CBC_HAS_GUM" -eq 1 ]; then
      selection=$(gum choose --cursor.foreground "$CATPPUCCIN_GREEN" \
        --selected.foreground "$CATPPUCCIN_GREEN" \
        --header "Select how to organise files" ext alpha time size type)
    else
      cbc_style_message "$CATPPUCCIN_SUBTEXT" "Enter sorting mode (ext/alpha/time/size/type):"
      read -r selection
    fi
    printf '%s' "$selection"
  }

  smartsort_prompt_target_dir() {
    local input
    input=$(cbc_input "Destination directory (blank keeps current): " "$(pwd)/sorted")
    if [ -n "$input" ]; then
      target_dir="$input"
    fi
  }

  smartsort_unique_extensions() {
    local -a extensions=()
    while IFS= read -r path; do
      local base ext_label
      base=${path#./}
      if [[ "$base" == *.* && "$base" != .* ]]; then
        ext_label=${base##*.}
      else
        ext_label="no-extension"
      fi
      extensions+=("$ext_label")
    done < <(find . -maxdepth 1 -type f -print)

    if [ "${#extensions[@]}" -eq 0 ]; then
      return 1
    fi

    printf '%s\n' "${extensions[@]}" | sort -u
    return 0
  }

  smartsort_choose_extensions() {
    local -a available=()
    if ! mapfile -t available < <(smartsort_unique_extensions); then
      return 1
    fi

    cbc_style_message "$CATPPUCCIN_SUBTEXT" "Select extensions to include (leave empty to include all)."

    if command -v fzf >/dev/null 2>&1; then
      mapfile -t selected_extensions < <(printf '%s\n' "${available[@]}" |
        fzf --multi --prompt="Extensions: " \
          --header="Tab to toggle multiple extensions. (Esc for all)" \
          --height=12 --border)
    elif [ "$CBC_HAS_GUM" -eq 1 ]; then
      local selection=""
      if selection=$(gum choose --no-limit \
        --cursor.foreground "$CATPPUCCIN_GREEN" \
        --selected.foreground "$CATPPUCCIN_GREEN" \
        --header "Select one or more extensions (Esc for all)" "${available[@]}"); then
        if [ -n "$selection" ]; then
          IFS=$'\n' read -r -a selected_extensions <<<"$selection"
        else
          selected_extensions=()
        fi
      else
        local exit_code=$?
        if [ $exit_code -eq 130 ] || [ -z "$selection" ]; then
          selected_extensions=()
        else
          return $exit_code
        fi
      fi
    else
      local input
      input=$(cbc_input "Extensions (space separated, blank for all): " "${available[*]}")
      if [ -n "$input" ]; then
        read -r -a selected_extensions <<<"$input"
      else
        selected_extensions=()
      fi
    fi

    return 0
  }

  smartsort_get_mod_date() {
    local path="$1"
    local format="$2"
    local mod_date=""

    if mod_date=$(date -r "$path" +"$format" 2>/dev/null); then
      printf '%s' "$mod_date"
      return 0
    fi

    if mod_date=$(stat -f "%Sm" -t "$format" "$path" 2>/dev/null); then
      printf '%s' "$mod_date"
      return 0
    fi

    printf '%s' "unknown"
    return 0
  }

  smartsort_get_file_size() {
    local path="$1"
    local size=""

    if size=$(stat -c%s "$path" 2>/dev/null); then
      printf '%s' "$size"
      return 0
    fi

    if size=$(stat -f%z "$path" 2>/dev/null); then
      printf '%s' "$size"
      return 0
    fi

    return 1
  }

  smartsort_prompt_time_grouping() {
    local selection=""
    if command -v fzf >/dev/null 2>&1; then
      selection=$(printf "month\nyear\nday\n" |
        fzf --prompt="Select time grouping: " --header="Choose modification time grouping granularity")
    elif [ "$CBC_HAS_GUM" -eq 1 ]; then
      selection=$(gum choose --cursor.foreground "$CATPPUCCIN_GREEN" \
        --selected.foreground "$CATPPUCCIN_GREEN" \
        --header "Choose modification time grouping" month year day)
    else
      cbc_style_message "$CATPPUCCIN_SUBTEXT" "Group files by (month/year/day):"
      read -r selection
    fi

    case "$selection" in
    year) time_grouping="year" ;;
    day) time_grouping="day" ;;
    month | "") time_grouping="month" ;;
    *)
      cbc_style_message "$CATPPUCCIN_YELLOW" "Unknown selection '$selection'. Using month grouping."
      time_grouping="month"
      ;;
    esac
  }

  smartsort_prompt_size_thresholds() {
    cbc_style_message "$CATPPUCCIN_SUBTEXT" "Configure size buckets in whole megabytes (press Enter to keep defaults)."
    local input_small
    local input_medium

    input_small=$(cbc_input "Max size for 'small' files (MB): " "$((small_threshold_bytes / 1024 / 1024))")
    input_medium=$(cbc_input "Max size for 'medium' files (MB): " "$((medium_threshold_bytes / 1024 / 1024))")

    if [ -n "$input_small" ]; then
      if echo "$input_small" | grep -Eq '^[0-9]+$'; then
        small_threshold_bytes=$((input_small * 1024 * 1024))
      else
        cbc_style_message "$CATPPUCCIN_RED" "Invalid value '$input_small'. Keeping default small bucket size."
        small_threshold_bytes=1048576
      fi
    fi

    if [ -n "$input_medium" ]; then
      if echo "$input_medium" | grep -Eq '^[0-9]+$'; then
        medium_threshold_bytes=$((input_medium * 1024 * 1024))
      else
        cbc_style_message "$CATPPUCCIN_RED" "Invalid value '$input_medium'. Keeping default medium bucket size."
        medium_threshold_bytes=10485760
      fi
    fi

    if [ "$medium_threshold_bytes" -le "$small_threshold_bytes" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Medium bucket must be larger than small bucket. Reverting to defaults."
      small_threshold_bytes=1048576
      medium_threshold_bytes=10485760
    fi
  }

  smartsort_prompt_type_granularity() {
    local selection=""
    if command -v fzf >/dev/null 2>&1; then
      selection=$(printf "top-level\nfull\n" |
        fzf --prompt="Select MIME grouping: " --header="Choose MIME granularity")
    elif [ "$CBC_HAS_GUM" -eq 1 ]; then
      selection=$(gum choose --cursor.foreground "$CATPPUCCIN_GREEN" \
        --selected.foreground "$CATPPUCCIN_GREEN" \
        --header "Choose MIME granularity" "top-level" full)
    else
      cbc_style_message "$CATPPUCCIN_SUBTEXT" "Group by MIME (top-level/full):"
      read -r selection
    fi

    case "$selection" in
    full) type_granularity="full" ;;
    top-level | "") type_granularity="top-level" ;;
    *)
      cbc_style_message "$CATPPUCCIN_YELLOW" "Unknown selection '$selection'. Using top-level grouping."
      type_granularity="top-level"
      ;;
    esac
  }

  while getopts ":hm:id:" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    i)
      interactive_mode=1
      ;;
    m)
      mode="$OPTARG"
      ;;
    d)
      target_dir="$OPTARG"
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    :)
      cbc_style_message "$CATPPUCCIN_RED" "Option -$OPTARG requires an argument."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ -z "$target_dir" ]; then
    target_dir="."
  fi

  if [ "$interactive_mode" -eq 1 ]; then
    if [ -z "$mode" ]; then
      mode=$(smartsort_select_mode)
      if [ -z "$mode" ]; then
        cbc_style_message "$CATPPUCCIN_RED" "No sorting mode selected. Exiting..."
        return 1
      fi
    else
      cbc_style_message "$CATPPUCCIN_SUBTEXT" "Interactive refinements enabled for mode: $mode"
    fi

    if [ "$target_dir" = "." ]; then
      smartsort_prompt_target_dir
    fi
  fi

  if [ -z "$mode" ]; then
    mode="ext"
  fi

  case "$mode" in
  ext | alpha | time | size | type) ;;
  *)
    cbc_style_message "$CATPPUCCIN_RED" "Invalid sorting mode: $mode"
    return 1
    ;;
  esac

  if [ "$target_dir" != "." ]; then
    if ! mkdir -p "$target_dir"; then
      cbc_style_message "$CATPPUCCIN_RED" "Failed to create destination directory: $target_dir"
      return 1
    fi
  fi

  local absolute_target
  absolute_target=$(cd "$target_dir" 2>/dev/null && pwd)
  if [ -z "$absolute_target" ]; then
    absolute_target="$target_dir"
  fi

  if [ -z "$(find . -maxdepth 1 -type f -print -quit)" ]; then
    cbc_style_message "$CATPPUCCIN_YELLOW" "No files found in the current directory to sort."
    return 0
  fi

  if [ "$mode" = "ext" ] && [ "$interactive_mode" -eq 1 ]; then
    if ! smartsort_choose_extensions; then
      cbc_style_message "$CATPPUCCIN_YELLOW" "No files with extensions found for sorting."
      return 0
    fi
  fi

  if [ "$mode" = "time" ] && [ "$interactive_mode" -eq 1 ]; then
    smartsort_prompt_time_grouping
  fi

  if [ "$mode" = "size" ] && [ "$interactive_mode" -eq 1 ]; then
    smartsort_prompt_size_thresholds
  fi

  if [ "$mode" = "type" ] && [ "$interactive_mode" -eq 1 ]; then
    smartsort_prompt_type_granularity
  fi

  case "$mode" in
  ext)
    if [ "${#selected_extensions[@]}" -gt 0 ]; then
      summary_details="Extensions: ${selected_extensions[*]}"
    else
      summary_details="Extensions: all"
    fi
    ;;
  time)
    summary_details="Time grouping: $time_grouping"
    ;;
  size)
    summary_details="Size buckets (MB): small≤$((small_threshold_bytes / 1024 / 1024)), medium≤$((medium_threshold_bytes / 1024 / 1024)), large>medium"
    ;;
  type)
    summary_details="MIME grouping: $type_granularity"
    ;;
  *)
    summary_details=""
    ;;
  esac

  local -a summary_lines=(
    "  Sorting Mode    : $mode"
    "  Interactive Mode: $([[ "$interactive_mode" -eq 1 ]] && echo Enabled || echo Disabled)"
    "  Target Directory: $absolute_target"
  )

  if [ -n "$summary_details" ]; then
    summary_lines+=("  Details         : $summary_details")
  fi

  cbc_style_box "$CATPPUCCIN_LAVENDER" "Selected Options:" "${summary_lines[@]}"

  if ! cbc_confirm "Proceed with sorting?"; then
    cbc_style_message "$CATPPUCCIN_YELLOW" "Sorting operation canceled."
    return 0
  fi

  sort_by_extension() {
    local include_all=1
    local path=""

    if [ "${#selected_extensions[@]}" -gt 0 ]; then
      include_all=0
    fi

    cbc_style_message "$CATPPUCCIN_BLUE" "Sorting files by extension..."

    while IFS= read -r path; do
      [ -f "$path" ] || continue
      local base ext_label target_subdir matched=0
      base=${path#./}
      if [[ "$base" == *.* && "$base" != .* ]]; then
        ext_label=${base##*.}
      else
        ext_label="no-extension"
      fi

      if [ "$include_all" -eq 0 ]; then
        for selected in "${selected_extensions[@]}"; do
          if [ "$selected" = "$ext_label" ]; then
            matched=1
            break
          fi
        done
        if [ "$matched" -eq 0 ]; then
          continue
        fi
      fi

      target_subdir="$target_dir/$ext_label"
      mkdir -p "$target_subdir"
      mv "$path" "$target_subdir/"
    done < <(find . -maxdepth 1 -type f -print)

    cbc_style_message "$CATPPUCCIN_GREEN" "Files have been sorted into extension-based directories."
  }

  sort_by_alpha() {
    cbc_style_message "$CATPPUCCIN_BLUE" "Sorting files alphabetically by the first letter..."

    while IFS= read -r path; do
      [ -f "$path" ] || continue
      local base letter target_subdir
      base=${path#./}
      letter=$(printf '%s' "$base" | cut -c1 | tr '[:upper:]' '[:lower:]')
      if [ -z "$letter" ]; then
        letter="misc"
      fi
      target_subdir="$target_dir/$letter"
      mkdir -p "$target_subdir"
      mv "$path" "$target_subdir/"
    done < <(find . -maxdepth 1 -type f -print)

    cbc_style_message "$CATPPUCCIN_GREEN" "Files have been sorted into directories based on their first letter."
  }

  sort_by_time() {
    local date_format="%Y-%m"
    case "$time_grouping" in
    year) date_format="%Y" ;;
    day) date_format="%Y-%m-%d" ;;
    *) date_format="%Y-%m" ;;
    esac

    cbc_style_message "$CATPPUCCIN_BLUE" "Sorting files by modification time..."

    while IFS= read -r path; do
      [ -f "$path" ] || continue
      local mod_date target_subdir
      mod_date=$(smartsort_get_mod_date "$path" "$date_format")
      if [ -z "$mod_date" ]; then
        mod_date="unknown"
      fi
      target_subdir="$target_dir/$mod_date"
      mkdir -p "$target_subdir"
      mv "$path" "$target_subdir/"
    done < <(find . -maxdepth 1 -type f -print)

    cbc_style_message "$CATPPUCCIN_GREEN" "Files have been sorted into date-based directories."
  }

  sort_by_size() {
    cbc_style_message "$CATPPUCCIN_BLUE" "Sorting files by size into categories..."

    while IFS= read -r path; do
      [ -f "$path" ] || continue
      local size category="unknown" target_subdir
      if ! size=$(smartsort_get_file_size "$path"); then
        cbc_style_message "$CATPPUCCIN_YELLOW" "Unable to determine size for $path. Skipping."
        continue
      fi

      if [ "$size" -lt "$small_threshold_bytes" ]; then
        category="small"
      elif [ "$size" -lt "$medium_threshold_bytes" ]; then
        category="medium"
      else
        category="large"
      fi

      target_subdir="$target_dir/$category"
      mkdir -p "$target_subdir"
      mv "$path" "$target_subdir/"
    done < <(find . -maxdepth 1 -type f -print)

    cbc_style_message "$CATPPUCCIN_GREEN" "Files have been sorted into size-based directories."
  }

  sort_by_type() {
    if ! command -v file >/dev/null 2>&1; then
      cbc_style_message "$CATPPUCCIN_RED" "The 'file' command is required for type sorting."
      return 1
    fi

    cbc_style_message "$CATPPUCCIN_BLUE" "Sorting files by MIME type..."

    while IFS= read -r path; do
      [ -f "$path" ] || continue
      local mime category target_subdir
      mime=$(file --brief --mime-type "$path")
      if [ "$type_granularity" = "full" ]; then
        category=${mime//\//_}
      else
        category=${mime%%/*}
      fi
      if [ -z "$category" ]; then
        category="unknown"
      fi
      target_subdir="$target_dir/$category"
      mkdir -p "$target_subdir"
      mv "$path" "$target_subdir/"
    done < <(find . -maxdepth 1 -type f -print)

    cbc_style_message "$CATPPUCCIN_GREEN" "Files have been sorted into MIME type directories."
  }

  case "$mode" in
  ext) sort_by_extension || return 1 ;;
  alpha) sort_by_alpha || return 1 ;;
  time) sort_by_time || return 1 ;;
  size) sort_by_size || return 1 ;;
  type) sort_by_type || return 1 ;;
  esac

  cbc_style_message "$CATPPUCCIN_GREEN" "Sorting operation completed successfully."
  cbc_style_message "$CATPPUCCIN_SUBTEXT" "There is no way to undo what you just did. Stay tuned for possible undo in the future."
}

################################################################################
# RANDOM
################################################################################

random() {
  OPTIND=1

  # Function to display help message
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Function to open a random .mp4 file in the current directory."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  random [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  random"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      usage
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

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
      "  -C    Open the wiki to the commands section" \
      "  -A    Open the wiki to the aliases section" \
      "  -F    Open the wiki to the functions section"

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
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Commands documentation..."
      nohup xdg-open "$wiki_url/Commands" >/dev/null 2>&1 &
      return 0
      ;;
    A)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Aliases documentation..."
      nohup xdg-open "$wiki_url/Aliases" >/dev/null 2>&1 &
      return 0
      ;;
    F)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening Functions documentation..."
      nohup xdg-open "$wiki_url/Functions" >/dev/null 2>&1 &
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      return 1
      ;;
    *)
      cbc_style_message "$CATPPUCCIN_SKY" "Opening CBC wiki..."
      nohup xdg-open "$wiki_url" >/dev/null 2>&1 &
      return 0
      ;;
    esac
  done

  shift $((OPTIND - 1))
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
    nohup xdg-open "$changelog_url"
  }

  # Call the open_changelog function
  open_changelog
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
  dotfiles_url="https://github.com/iop098321qwe/dotfiles"

  # Open the dotfiles repository in the default browser
  xdg-open "$dotfiles_url"
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

  # Create the 'grymms_grimoires' directory if it does not exist
  mkdir -p ~/Documents/grymms_grimoires/
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
  local current_version="$VERSION"
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
  cbc_style_box "$CATPPUCCIN_GREEN" "Using Custom Bash Commands (by iop098321qwe)"
  cbc_style_message "$CATPPUCCIN_YELLOW" "Version: $VERSION 🔹🔹 To see the changes in this version, use the 'changes' command."
  cbc_style_message "$CATPPUCCIN_SKY" "Show available commands with 'cbcs [-h]' or by typing 'commands' ('comm' for shortcut)."
  cbc_style_message "$CATPPUCCIN_SUBTEXT" "To stop using CBC, remove '.custom_bash_commands.sh' from your '.bashrc' file using 'editbash'."
  cbc_style_message "$CATPPUCCIN_PINK" "Use the 'wiki' command or visit: https://github.com/iop098321qwe/custom_bash_commands/wiki"
}

################################################################################
# CBCS
################################################################################

cbcs() {
  OPTIND=1
  all_info=false

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

  main_logic() {
    if [ "$all_info" = true ]; then
      # Display a list of all available custom commands and functions in this script with descriptions
      echo " "
      echo "########################################################################################################"
      echo "################################### SEPARATE FUNCTION SECTION ##########################################"
      echo "########################################################################################################"
      echo "NOT CURRENTLY ALPHABETICAL"
      echo " "
      echo "backup"
      echo "          Description: Create a backup file of a file"
      echo "          Usage: backup <file>"
      echo " "
      echo "batchopen"
      echo "          Description: Opens a .txt file of URLs line-by-line in the browser"
      echo "          Usage: batchopen [-h | -f]"
      echo "          Options:"
      echo "              -h    Display this help message"
      echo "              -f    Specify batch file"
      echo " "
      echo "cbcs"
      echo "          Description: Display a list of all available custom commands in this script"
      echo "          Usage: cbcs [-h]"
      echo "          Options:"
      echo "              -h    Display this help message"
      echo " "
      echo "cc"
      echo "          Description: Combine the git add, git commit and git push process interactively"
      echo "          Usage: cc"
      echo " "
      echo "changes"
      echo "          Description: Function to open the CBC changelog in the default browser"
      echo "          Usage: changes [-h | -c]"
      echo "          Options:"
      echo "              -h    Display this help message"
      echo "              -c    Copy the changelog URL to the clipboard"
      echo " "
      echo "cht.sh"
      echo "         Description: Open the Cheat.sh client in the terminal"
      echo "         Usage: cht.sh <query>"
      echo " "
      echo "display_info"
      echo "          Description: Display CBC information"
      echo "          Usage: display_info"
      echo "          Aliases: 'di'"
      echo " "
      echo "display_version"
      echo "          Description: Display the version number from the custom_bash_commands file"
      echo "          Usage: display_version"
      echo "          Aliases: 'dv'"
      echo " "
      echo "doftiles"
      echo "         Description: Open the doftiles repository in the default browser"
      echo "         Usage: doftiles"
      echo " "
      echo "extract"
      echo "         Description: Extract compressed files"
      echo "         Usage: extract [file]"
      echo " "
      echo "mkdirs"
      echo "         Description: Create a directory and switch into it"
      echo "         Usage: mkdirs [directory]"
      echo " "
      echo "makeman"
      echo "         Description: Function to generate a PDF file from a man page"
      echo "         Usage: makeman [-h | -f <file> | -o <output_directory> | -r] <command>"
      echo "         Options:"
      echo "             -h    Display this help message"
      echo "             -f    <file> : Specify the output file name"
      echo "             -o    <output_directory> : Specify the output directory"
      echo "             -r    Remove existing files in the output directory that are not listed in the specified file"
      echo " "
      echo "myip"
      echo "         Description: Display the IP address of the current machine"
      echo "         Usage: myip"
      echo " "
      echo "pronlist"
      echo "          Description: List files downloaded from _batch.txt per URL"
      echo "          Usage: pronlist"
      echo " "
      echo "random"
      echo "         Description: Open a random .mp4 file in the current directory"
      echo "         Usage: random"
      echo " "
      echo "refresh"
      echo "         Description: Refresh the terminal session"
      echo "         Usage: refresh"
      echo " "
      echo "remove_all_cbc_configs"
      echo "          Description: Remove all configuration files associated with CBC"
      echo "          Usage: remove_all_cbc_configs"
      echo "          Aliases: racc"
      echo " "
      echo "sortalpha"
      echo "         Description: Sort files alphabetically into subdirectories by type and first letter"
      echo "         Usage: sortalpha"
      echo "         Aliases: sa"
      echo " "
      echo "seebash"
      echo "          Description: Display the contents of the .bashrc file"
      echo "          Usage: seebash"
      echo " "
      echo "up"
      echo "          Description: Move up one directory level"
      echo "          Usage: up [number of levels>=0 | -a | -h | -r | -q | -c | -p | -l]"
      echo "          Options:"
      echo "             -a    Move up all levels"
      echo "             -h    Display this help message"
      echo "             -r    Move up to the root directory"
      echo "             -q    Move up quietly"
      echo "             -c    Clear the screen after moving up"
      echo "             -p    Print the current directory after moving up"
      echo "             -l    List the contents of the current directory after moving up"
      echo "rmconf"
      echo "         Description: Remove the configuration file for CBC"
      echo "         Usage: rmconf"
      echo " "
      echo "sopen"
      echo "          Description: Open .mp4 files in the current directory that match patterns generated from lines in a selected .txt file"
      echo "          Usage: sopen"
      echo " "
      echo "sopenexact"
      echo "          Description: Open .mp4 files in the current directory that match patterns generated from lines in a selected .txt file using exact mode"
      echo "          Usage: sopenexact"
      echo " "
      echo "update"
      echo "          Description: "
      echo "          Usage: update [-h | -r | -s | -l ]"
      echo "          Options:"
      echo "              -h : Display this help message"
      echo "              -r : Restart the computer after updating"
      echo "              -s : Shutdown the computer after updating"
      echo "              -l : Display the path to the log file after updating"
      echo " "
      echo "wiki"
      echo "         Description: Open the CBC wiki in the default browser"
      echo "         Usage: wiki"
      echo " "
      echo "x"
      echo "         Description: Make a file executable"
      echo "         Usage: x [file]"
      echo " "
      echo "########################################################################################################"
      echo "################################### SEPARATE ALIAS SECTION #############################################"
      echo "########################################################################################################"
      echo " "
      echo "back"
      echo "          Description: Change to the parent directory and list its contents"
      echo "          Usage: back"
      echo "          Alias For: 'cd .. && ls'"
      echo " "
      echo "bat"
      echo "          Description: Alias shortcut for 'batcat'"
      echo "          Usage: bat [options]"
      echo "          Alias For: 'batcat'"
      echo " "
      echo "cbcc"
      echo "          Description: Change to the custom_bash_commands directory, list its contents, and commit interactively"
      echo "          Usage: cbcc"
      echo "          Alias For: 'cdgh && cd custom_bash_commands && ls && cc'"
      echo " "
      echo "cbc"
      echo "          Description: Change to the custom_bash_commands directory and list its contents"
      echo "          Usage: cbc"
      echo "          Alias For: 'cdgh && cd custom_bash_commands && ls'"
      echo " "
      echo "c"
      echo "          Description: Clear the terminal screen and call display_info command"
      echo "          Usage: c"
      echo "          Alias For: 'clear && di"
      echo " "
      echo "ch"
      echo "          Description: Alias shortcut for 'chezmoi'"
      echo "          Usage: ch [options]"
      echo "          Alias For: 'chezmoi'"
      echo " "
      echo "chup"
      echo "          Description: Alias shortcut to pull updates from chezmoi"
      echo "          Usage: chup"
      echo "          Alias For: 'chezmoi update'"
      echo " "
      echo "cla"
      echo "          Description: Clear the terminal screen and print the contents of the current directory including hidden"
      echo "          Usage: cla"
      echo "          Alias For: 'clear && di && la"
      echo " "
      echo "cls"
      echo "          Description: Clear the terminal screen and print the contents of the current directory"
      echo "          Usage: cls"
      echo "          Alias For: 'clear && di && ls'"
      echo " "
      echo "commands"
      echo "          Description: Display a list of all available custom commands in CBC using batcat"
      echo "          Usage: commands"
      echo "          Alias For: 'cbcs | batcat'"
      echo " "
      echo "commandsmore"
      echo "          Description: Display a list of all available custom commands in CBC and additional information using batcat"
      echo "          Usage: commandsmore"
      echo "          Alias For: 'cbcs -h | batcat'"
      echo " "
      echo "comm"
      echo "          Description: Shortcut for 'commands'"
      echo "          Usage: comm"
      echo "          Alias For: 'commands'"
      echo " "
      echo "commm"
      echo "          Description: Shortcut for 'commandsmore'"
      echo "          Usage: commm"
      echo "          Alias For: 'commandsmore'"
      echo " "
      echo "cp"
      echo "          Description: Alias for 'cp' with the '-i' option"
      echo "          Usage: cp [source] [destination]"
      echo "          Alias For: 'cp -i'"
      echo " "
      echo "di"
      echo "          Description: Shortcut for 'display_info'"
      echo "          Usage: di"
      echo "          Alias For: 'display_info'"
      echo " "
      echo "dl"
      echo "          Description: Shortcut for 'downloads'"
      echo "          Usage: dl"
      echo "          Alias For: 'downloads'"
      echo " "
      echo "docs"
      echo "          Description: Change to the Documents directory and list its contents"
      echo "          Usage: docs"
      echo "          Alias For: 'cd ~/Documents && ls'"
      echo " "
      echo "downloads"
      echo "          Description: Change to the Downloads directory and list its contents"
      echo "          Usage: downloads"
      echo "          Alias For: 'cd ~/Downloads && ls'"
      echo " "
      echo "dv"
      echo "          Description: Shortcut for 'display_version'"
      echo "          Usage: dv"
      echo "          Alias For: 'display_version'"
      echo " "
      echo "editbash"
      echo "          Description: Open the .bashrc file in the default terminal text editor"
      echo "          Usage: editbash"
      echo "          Alias For: '\$EDITOR ~/.bashrc'"
      echo " "
      echo "home"
      echo "         Description: Change to the home directory and list its contents"
      echo "         Usage: home"
      echo "         Alias: cd ~ && ls"
      echo " "
      echo "iopen"
      echo "          Description: Alias for 'fopen' to open image files"
      echo "          Usage: iopen"
      echo "          Aliases: 'io'"
      echo " "
      echo "iopenexact"
      echo "          Description: Alias for 'fopenexact' to open image files"
      echo "          Usage: iopenexact"
      echo "          Aliases: 'ioe'"
      echo " "
      echo "io"
      echo "          Description: Shortcut for 'iopen'"
      echo "          Usage: io"
      echo " "
      echo "ioe"
      echo "          Description: Shortcut for 'iopenexact'"
      echo "          Usage: ioe"
      echo " "
      echo "rma"
      echo "          Description: Remove the directory and all files it contains"
      echo "          Usage: rma <directory>"
      echo "          Alias For: 'rm -rfI'"
      echo " "
      echo "odt"
      echo "          Description: Create a .odt file in the current directory and open it"
      echo "          Usage: odt [filename]"
      echo " "
      echo "ods"
      echo "          Description: Create a .ods file in the current directory and open it"
      echo "          Usage: ods [filename]"
      echo " "
      echo "cdgh, (alias: cd ~/Documents/github_repositories && ls)"
      echo "          Description: Change to the github_repositories directory and list its contents"
      echo "          Usage: cdgh,   (alias: cd ~/Documents/github_repositories && ls)"
      echo " "
      echo "temp, (alias: cd ~/Documents/Temporary && ls)"
      echo "          Description: Change to the Temporary directory and list its contents"
      echo "          Usage: temp,   (alias: cd ~/Documents/Temporary && ls)"
      echo " "
      echo "test, (alias: source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh"
      echo "          Description: Source the custom_bash_commands script for testing"
      echo "          Usage: test,   (alias: source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh"
      echo " "
      echo "gs"
      echo "          Description: Display the git status of the current directory"
      echo "          Usage: gs"
      echo "          Alias For: 'git status'"
      echo " "
      echo "ga, (alias: git add)"
      echo "          Description: Add a file to the git repository"
      echo "          Usage: ga [file]"
      echo " "
      echo "gaa, (alias: git add .)"
      echo "          Description: Add all files to the git repository"
      echo "          Usage: gaa"
      echo " "
      echo "gb, (alias: git branch)"
      echo "          Description: Display the git branches of the current repository"
      echo "          Usage: gb"
      echo " "
      echo "gco, (alias: git checkout)"
      echo "          Description: Switch to a different branch in the git repository"
      echo "          Usage: gco [branch]"
      echo " "
      echo "gcom, (alias: git checkout main)"
      echo "          Description: Quickly switch to the main branch of a git repository"
      echo "          Usage: gcom"
      echo " "
      echo "gcomm"
      echo "          Description: Commit the changes to the local repository and open commit message in default editor"
      echo "          Usage: gcomm]"
      echo "          Alias For: git commit"
      echo " "
      echo "gpsh, (alias: git push)"
      echo "          Description: Push the changes to the remote repository"
      echo "          Usage: gpsh"
      echo " "
      echo "gpll, (alias: git pull)"
      echo "          Description: Pull the changes from the remote repository"
      echo "          Usage: gpll"
      echo " "
      echo "gpfom, (alias: git push -f origin main)"
      echo "          Description: Force push the changes to the main branch of the remote repository with tags"
      echo "          Usage: gpfom"
      echo " "
      echo "gsw"
      echo "          Description: Alias for 'git switch'"
      echo "          Usage: gsw [branch]"
      echo " "
      echo "gswm"
      echo "         Description: Quickly switch to the main branch of a git repository"
      echo "         Usage: gswm"
      echo " "
      echo "gswt"
      echo "         Description: Quickly switch to the test branch of a git repository"
      echo "         Usage: gswt"
      echo " "
      echo "filehash, (alias: fh)"
      echo "         Description: Display the hash of a file"
      echo "         Usage: filehash [file] [hash_type]"
      echo " "
      echo "python"
      echo "         Description: Alias for 'python3'"
      echo "         Usage: python [file]"
      echo " "
      echo "py"
      echo "         Description: Alias for 'python3'"
      echo "         Usage: py [file]"
      echo " "
      echo "pron"
      echo "         Description: Activate yt-dlp using preset settings"
      echo "         Usage: pron"
      echo "          Alias For: 'yt-dlp --config-locations _configs.txt --batch-file _batch.txt'"
      echo " "
      echo "pronfile"
      echo "         Description: Navigate to specific folder in T7 Shield"
      echo "         Usage: pronfile"
      echo " "
      echo "pronupdate"
      echo "         Description: Alias for 'pronfile && pron'"
      echo "         Usage: pronupdate"
      echo " "
      echo "pu"
      echo "         Description: Alias for 'pronupdate'"
      echo "         Usage: pu"
      echo " "
      echo "regex_help"
      echo "         Description: Display regex cheat-sheets with flavor selection"
      echo "         Default: PCRE output with -i/-f to explore other engines"
      echo "         Usage: regex_help [-f <flavor>] [-i] [-l] [-h]"
      echo " "
      echo "updatecbc, (alias: ucbc)"
      echo "         Description: Update the custom bash commands script"
      echo "         Usage: updatecbc"
      echo " "
      echo "fman"
      echo "         Description: Fuzzy find a command and open the man page"
      echo "         Usage: fman"
      echo " "
      echo "fcom"
      echo "         Description: Fuzzy find a command and run it"
      echo "         Usage: fcom"
      echo " "
      echo "fcomexact"
      echo "         Description: Fuzzy find a command and run it using exact mode"
      echo "         Usage: fcomexact"
      echo " "
      echo "fcome"
      echo "         Description: Alias for 'fcomexact'"
      echo "         Usage: fcome"
      echo " "
      echo "fhelp"
      echo "         Description: Fuzzy find a command and display its help information"
      echo "         Usage: fhelp"
      echo " "
      echo "fhelpexact"
      echo "         Description: Fuzzy find a command and display its help information using exact mode"
      echo "         Usage: fhelpexact"
      echo " "
      echo "fhelpe"
      echo "         Description: Alias for 'fhelpexact'"
      echo "         Usage: fhelpe"
      echo " "
      echo "historysearch"
      echo "         Description: Search using fuzzy finder in the command history"
      echo "         Usage: historysearch"
      echo " "
      echo "historysearchexact"
      echo "         Description: Search using fuzzy finder in the command history using exact mode"
      echo "         Usage: historysearchexact"
      echo " "
      echo "  hs"
      echo "         Description: Alias for 'historysearch'"
      echo "         Usage: hs"
      echo " "
      echo "  hse"
      echo "         Description: Alias for 'historysearch' using exact mode"
      echo "         Usage: hse"
      echo " "
      echo "  hsearch"
      echo "         Description: Alias for 'historysearch'"
      echo "         Usage: hsearch"
      echo " "
      echo "  i"
      echo "         Description: Alias for 'sudo apt install'"
      echo "         Usage: i [package]"
      echo " "
      echo "  ext"
      echo "         Description: Alias for extract function"
      echo "         Usage: ext [file]"
      echo " "
      echo "  vim"
      echo "         Description: Alias for 'nvim'"
      echo "         Usage: vim [file]"
      echo " "
      echo "  v"
      echo "         Description: Alias for 'nvim'"
      echo "         Usage: v [file]"
      echo " "
      echo "vopen"
      echo "          Description: Alias for 'fopen' to open video files"
      echo "          Usage: vopen"
      echo "          Aliases: 'vo'"
      echo " "
      echo "vopenexact"
      echo "          Description: Alias for 'fopenexact' to open video files"
      echo "          Usage: vopenexact"
      echo "          Aliases: 'voe'"
      echo " "
      echo "vo"
      echo "          Description: Shortcut for 'vopen'"
      echo "          Usage: vo"
      echo " "
      echo "voe"
      echo "          Description: Shortcut for 'vopenexact'"
      echo "          Usage: voe"
      echo " "
      echo "mopen"
      echo "          Description: Alias for 'fopen' for media files."
      echo "          Usage: mopen"
      echo " "
      echo "mopenexact"
      echo "          Description: Alias for 'fopenexact' for media files."
      echo "          Usage: mopenexact"
      echo " "
      echo "mo"
      echo "          Description: Alias for 'mopen'"
      echo "          Usage: mo"
      echo " "
      echo "moe"
      echo "          Description: Alias for 'mopenexact'"
      echo "          Usage: moe"
      echo " "
      echo "mv"
      echo "          Description: Alias for 'mv' with the '-i' option"
      echo "          Usage: mv [source] [destination]"
      echo " "
      echo "rm"
      echo "         Description: Alias for 'rm' with the '-i' option"
      echo "         Usage: rm [file]"
      echo " "
      echo "ln"
      echo "         Description: Alias for 'ln' with the '-i' option"
      echo "         Usage: ln [source] [destination]"
      echo " "
      echo "fobsidian"
      echo "         Description: Open a file from the Obsidian vault in Obsidian"
      echo "         Usage: fobsidian [file]"
      echo " "
      echo "fobs"
      echo "         Description: Alias for 'fobsidian'"
      echo "         Usage: fobs [file]"
      echo " "
      echo "la"
      echo "         Description: List all files including hidden files using eza"
      echo "         Usage: la"
      echo " "
      echo "lar"
      echo "         Description: List all files including hidden files in reverse order using eza"
      echo "         Usage: lar"
      echo " "
      echo "le"
      echo "         Description: List all files including hidden files sorting by extension using eza"
      echo "         Usage: le"
      echo " "
      echo "ll"
      echo "         Description: List all files including hidden files with long format using eza"
      echo "         Usage: ll"
      echo " "
      echo "llt"
      echo "         Description: List all files including hidden files with long format and tree view using eza"
      echo "         Usage: llt"
      echo " "
      echo "ls"
      echo "         Description: List files using eza"
      echo "         Usage: ls"
      echo " "
      echo "  lsd"
      echo "         Description: List directories using eza"
      echo "         Usage: lsd"
      echo " "
      echo "  lsf"
      echo "         Description: List only files using eza"
      echo "         Usage: lsf"
      echo " "
      echo "  lsr"
      echo "         Description: List files using eza in reverse order"
      echo "         Usage: lsr"
      echo " "
      echo "  lt"
      echo "         Description: List files with tree view using eza"
      echo "         Usage: lt"
      echo " "
      echo "  z"
      echo "         Description: Alias for 'zellij'"
      echo "         Usage: z [options]"
      echo " "
      echo "  commands"
      echo "         Description: Display a list of all available custom commands in this script"
      echo "         Usage: commands"
      echo " "
      echo "  fopen"
      echo "         Description: Fuzzy find a file and open it"
      echo "         Usage: fopen"
      echo "  fopenexact"
      echo "         Description: Fuzzy find a file and open it using exact mode"
      echo "         Usage: fopenexact"
      echo " "
      echo "  fo"
      echo "         Description: Alias for 'fopen'"
      echo "         Usage: fo"
      echo " "
      echo "  foe"
      echo "         Description: Alias for 'fopenexact'"
      echo "         Usage: foe"
      echo " "
      echo "lg"
      echo "          Description: Alias for 'lazygit'"
      echo "          Usage: lg"
      echo " "
      echo "sa"
      echo "          Description: Alias for 'sortalpha'"
      echo "          Usage: sa"
      echo " "
      echo "s"
      echo "          Description: Alias for 'sudo'"
      echo "          Usage : s <command>"
      echo " "
      echo "so"
      echo "          Description: Alias for 'sopen'"
      echo "          Usage: so"
      echo " "
      echo "soe"
      echo "          Description: Alias for 'sopenexact'"
      echo "          Usage: soe"
      echo " "
      echo "ver"
      echo "          Description: Shortcut for 'npx commit-and-tag-version'"
      echo "          Usage: ver"
      echo "          Alias For: 'npx commit-and-tag-version'"
      echo " "
      echo "verg"
      echo "          Description: Combine 'ver' and 'gpfom' commands"
      echo "          Usage: verg"
      echo "          Alias For: 'ver && gpfom && echo \"Run 'gh cr' to create a new release\"'"
      echo " "
      echo ":q"
      echo "          Description: Alias to exit terminal"
      echo "          Usage: :q"
      echo "          Alias For: 'exit'"
      echo " "
      echo ":wq"
      echo "          Description: Alias to exit terminal"
      echo "          Usage: :wq"
      echo "          Alias For: 'exit'"
      echo " "
    else
      # Display a list of all available custom commands and functions in this script
      echo " "
      echo "########################################################################################################"
      echo "################################### SEPARATE FUNCTION SECTION ##########################################"
      echo "########################################################################################################"
      echo " "
      echo "Use cbcs [-h] with help flag to display descriptions and usage. (NOT CURRENTLY ALPHABETICAL)"
      echo " "
      echo "backup"
      echo "cbcs"
      echo "cc"
      echo "changes"
      echo "cht.sh"
      echo "display_info"
      echo "display_version,"
      echo "doftiles"
      echo "extract"
      echo "makeman"
      echo "mkdirs"
      echo "myip"
      echo "pronlist"
      echo "random"
      echo "refresh"
      echo "rmconf"
      echo "sortalpha"
      echo "seebash"
      echo "sopen"
      echo "sopenexact"
      echo "up"
      echo "wiki"
      echo "x"
      echo " "
      echo "########################################################################################################"
      echo "################################### SEPARATE ALIAS SECTION #############################################"
      echo "########################################################################################################"
      echo " "
      echo "back"
      echo "bat"
      echo "cbcc"
      echo "cbc"
      echo "c"
      echo "cdgh"
      echo "ch"
      echo "chup"
      echo "cla"
      echo "cls"
      echo "commands"
      echo "commandsmore"
      echo "comm"
      echo "commm"
      echo "cp"
      echo "di"
      echo "dl"
      echo "docs"
      echo "downloads"
      echo "dv"
      echo "editbash"
      echo "ext"
      echo "fcom"
      echo "fcome"
      echo "fcomexact"
      echo "fhelp"
      echo "fhelpe"
      echo "fhelpexact"
      echo "filehash"
      echo "fman"
      echo "fo"
      echo "fobs"
      echo "fobsidian"
      echo "foe"
      echo "fopen"
      echo "fopenexact"
      echo "ga"
      echo "gaa"
      echo "gb"
      echo "gco"
      echo "gcom"
      echo "gcomm"
      echo "gp"
      echo "gpfom"
      echo "gs"
      echo "gsw"
      echo "gswm"
      echo "gswt"
      echo "historysearch"
      echo "historysearchexact"
      echo "home"
      echo "hs"
      echo "hse"
      echo "hsearch"
      echo "i"
      echo "iopen"
      echo "iopenexact"
      echo "io"
      echo "ioe"
      echo "la"
      echo "lar"
      echo "le"
      echo "lg"
      echo "ll"
      #   echo "llt"
      #   echo "ln"
      #   echo "ls"
      #   echo "lsd"
      #   echo "lsf"
      echo "lsr"
      echo "lt"
      echo "mopen"
      echo "mopenexact"
      echo "mo"
      echo "moe"
      echo "mv"
      echo "ods"
      echo "odt"
      echo "py"
      echo "python"
      echo "pron"
      echo "pronfile"
      echo "pronupdate"
      echo "pu"
      echo "regex_help"
      echo "rm"
      echo "rma"
      echo "s"
      echo "sa"
      echo "so"
      echo "soe"
      echo "temp"
      echo "test"
      echo "update"
      echo "updatecbc"
      echo "ver"
      echo "verg"
      echo "vim"
      echo "v"
      echo "vopen"
      echo "vopenexact"
      echo "vo"
      echo "voe"
      echo "z"
      echo ":q"
      echo ":wq"
    fi
  }

  # Call the main logic function
  main_logic

  # if [[ $1 == "-h" ]]; then
}

################################################################################
# BACKUP
################################################################################

backup() {
  OPTIND=1

  local filename=$(basename "$1")                             # Get the base name of the file
  local timestamp=$(date +%Y.%m.%d.%H.%M.%S)                  # Get the current timestamp
  local backup_filename="${filename}_backup_${timestamp}.bak" # Create the backup file name

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Create a timestamped backup of a specified file."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  backup [file] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  backup test.txt"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG. Use -h for help."
      return
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Function to check if no arguments are provided
  check_no_arguments() {
    if [ $# -eq 0 ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: No arguments provided. Use -h for help."
      return 1
    fi
  }

  # Function to check if the file exists
  check_file_exists() {
    if [ ! -f "$1" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "Error: File not found."
      return 1
    fi
  }

  # Function to create a backup file
  make_backup() {
    if cp "$1" "$backup_filename"; then
      cbc_style_message "$CATPPUCCIN_GREEN" "Backup created: $backup_filename"
    else
      cbc_style_message "$CATPPUCCIN_RED" "Failed to create backup."
      return 1
    fi
  }

  # Main logic
  main() {
    check_no_arguments "$@" || return
    check_file_exists "$1" || return
    make_backup "$1"
  }

  # Call the main function with arguments
  main "$@"
}

################################################################################
# MAKEMAN
################################################################################

makeman() {
  local file=""
  local output_dir="$HOME/Documents/grymms_grimoires/command_manuals"
  local command=""
  local remove_unlisted=false

  # Reset OPTIND to 1 to ensure option parsing starts correctly
  OPTIND=1

  # Parse options
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Generate PDF manuals from man pages, optionally from a list."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  makeman [-h] [-f <file>] [-o <dir>] [-r] <command>"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h           Display this help message" \
      "  -f <file>    Specify a file with a list of commands" \
      "  -o <dir>     Specify an output directory" \
      "  -r           Remove unlisted files from the output directory"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  makeman ls" \
      "  makeman -f commands.txt -r"
  }

  while getopts ":hf:o:r" opt; do
    case ${opt} in
    h)
      usage
      return 0
      ;;
    f)
      file=$OPTARG
      ;;
    o)
      output_dir=$OPTARG
      ;;
    r)
      remove_unlisted=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
      usage
      return 1
      ;;
    :)
      cbc_style_message "$CATPPUCCIN_RED" "Option -$OPTARG requires an argument."
      usage
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Process remaining arguments as the command
  if [ -z "$file" ]; then
    if [ $# -eq 0 ]; then
      usage
      return 1
    fi
    command=$1
  fi

  # Function to process a single command
  process_command() {
    local cmd=$1
    local output_file="${output_dir}/${cmd}.pdf"
    mkdir -p "$output_dir"
    if ! man -w "$cmd" &>/dev/null; then
      echo "Error: No manual entry for command '$cmd'"
      return 1
    fi
    if ! man -t "$cmd" | ps2pdf - "$output_file"; then
      echo "Error: Failed to convert man page to PDF for command '$cmd'"
      return 1
    fi
    echo "PDF file created at: $output_file"
  }

  # Process commands from file or single command
  if [ -n "$file" ]; then
    if [ ! -f "$file" ]; then
      echo "Error: File '$file' not found"
      return 1
    fi

    local cmd_list=()
    while IFS= read -r cmd; do
      [ -z "$cmd" ] && continue # Skip empty lines
      cmd_list+=("$cmd")
      process_command "$cmd"
    done <"$file"

    if $remove_unlisted; then
      for existing_file in "$output_dir"/*.pdf; do
        local basename=$(basename "$existing_file" .pdf)
        if [[ ! " ${cmd_list[@]} " =~ " ${basename} " ]]; then
          echo "Removing unlisted file: $existing_file"
          rm "$existing_file"
        fi
      done
    fi
  else
    process_command "$command"
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
# UPDATE
################################################################################

update() {
  OPTIND=1
  local reboot=false
  local shutdown=false
  local display_log=false
  local log_file=~/Documents/update_logs/$(date +"%Y-%m-%d_%H-%M-%S").log
  local sudo_required=false

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Update the system with optional reboot, shutdown, or log display."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  update [-h|-r|-s|-l]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -r    Reboot the system after updating" \
      "  -s    Shutdown the system after updating" \
      "  -l    Display the log file path"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  update -r"
  }

  while getopts ":hrsl" opt; do
    case $opt in
    h)
      usage
      return
      ;;
    r)
      # Reboot the system after updating
      reboot=true
      ;;
    s)
      # Shutdown the system after updating
      shutdown=true
      ;;
    l)
      # Display the log path after updating
      display_log=true
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG. Use -h for help."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Function to check if sudo password is required
  check_sudo_requirement() {
    if sudo -n true 2>/dev/null; then
      sudo_required=false
    else
      sudo_required=true
      if [ "$sudo_required" = true ]; then
        sudo_password=$(gum input --password --placeholder "Enter your sudo password: ")
        if [[ -z "$sudo_password" ]]; then
          gum style --foreground "$CATPPUCCIN_RED" --bold "No password provided!"
          return 1
        fi
        # Validate password before proceeding
        echo "$sudo_password" | sudo -S true 2>/dev/null
        if [[ $? -ne 0 ]]; then
          # echo "Incorrect password."
          gum style --foreground "$CATPPUCCIN_RED" --bold "Incorrect password!"
          return 1
        fi
      fi
    fi
  }

  # Create the log directory if it doesn't exist
  create_log_directory() {
    mkdir -p ~/Documents/update_logs
  }

  # Call the create_log_directory function
  create_log_directory

  # Function to check if ttf-mscorefonts-installer is installed
  check_install_mscorefonts() {
    # Check if the package is installed
    if dpkg-query -W -f='${Status}' ttf-mscorefonts-installer 2>/dev/null | grep -q "install ok installed"; then
      echo "ttf-mscorefonts-installer is already installed."
    else
      echo "ttf-mscorefonts-installer is not installed. Please run 'i ttf-mscorefonts-installer' to install it."
    fi
  }

  # Run update commands with sudo, tee to output to terminal and append to log file
  # Define an array of commands to run
  commands=(
    "sudo apt update"
    "sudo apt autoremove -y"
    "sudo apt upgrade -y"
    "atuin update"
    ""
    "sudo flatpak update -y"
    "sudo snap refresh"
    "pip install --upgrade yt-dlp --break-system-packages"
    "check_install_mscorefonts"
    "sudo apt clean"
  )

  # Function to print completion message using gum
  print_completion_message() {
    echo " "
    gum style --foreground "#a6e3a1" --bold "Updates completed!"
  }

  # Function to run a command and log the output
  run_command() {
    local command="$1"
    echo " "
    gum style --foreground "#f9e2af" --bold "================================================================================"
    gum style --foreground "#f9e2af" --bold "Running command: $command" | tee -a "$log_file"
    gum style --foreground "#f9e2af" --bold "================================================================================"
    eval "$command" | tee -a "$log_file"
  }

  # Iterate through the list of commands and run them
  iterate_commands() {
    for command in "${commands[@]}"; do
      run_command "$command"
    done
  }

  main() {
    # check the sudo password requirement
    check_sudo_requirement
    if [[ $? -ne 0 ]]; then
      gum style --foreground "#f9e2af" "Exiting due to authentication failure."
      return 1 # Stop execution of `main`
    fi
    if gum confirm "Are you sure you want to update the system? (y/N):" --default=no; then
      if [ $reboot = true ]; then
        iterate_commands | tee -a "$log_file"
        # prompt the user to confirm reboot
        if gum confirm "Are you sure you want to reboot the system? (y/N):" --default=no; then
          reboot
        else
          gum style --foreground "$CATPPUCCIN_RED" --bold "Reboot canceled..."
        fi
      elif [ $shutdown = true ]; then
        iterate_commands | tee -a "$log_file"
        # promt the user to confirm shutdown
        if gum confirm "Are you sure you want to shutdown the system? (y/N):" --default=no; then
          shutdown now
        else
          gum style --foreground "$CATPPUCCIN_RED" --bold "Shutdown canceled..."
        fi
      elif [ $display_log = true ]; then
        iterate_commands | tee -a "$log_file"
        gum style --foreground "#89dceb" --bold "Update logs saved to: $log_file"
      else
        iterate_commands | tee -a "$log_file"
      fi
    else
      gum style --foreground "$CATPPUCCIN_RED" --bold "Update canceled."
      return
    fi
    ###########################################################################
    echo " "
    gum style --foreground "#a6e3a1" --bold "Please run 'cargo install-update -a' to update Cargo packages."
    print_completion_message
  }

  # Main logic
  main
}

################################################################################
# EXTRACT
################################################################################

extract() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Extract a variety of compressed archive formats."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  extract [file] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  extract file.tar.gz"
  }

  while getopts ":h" opt; do
    case ${opt} in
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

  if [ -z "$1" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: No file specified"
    return 1
  fi

  if [ ! -f "$1" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: File not found"
    return 1
  fi

  case "$1" in
  *.tar.bz2) tar xjf "$1" ;;
  *.tar.gz) tar xzf "$1" ;;
  *.bz2) bunzip2 "$1" ;;
  *.rar) unrar x "$1" ;;
  *.gz) gunzip "$1" ;;
  *.tar) tar xf "$1" ;;
  *.tbz2) tar xjf "$1" ;;
  *.tgz) tar xzf "$1" ;;
  *.zip) unzip "$1" ;;
  *.Z) uncompress "$1" ;;
  *.7z) 7z x "$1" ;;
  *.deb) ar x "$1" ;;
  *.tar.xz) tar xf "$1" ;;
  *.tar.zst) unzstd "$1" ;;
  *) cbc_style_message "$CATPPUCCIN_RED" "'$1' cannot be extracted using extract()" ;;
  esac
}

################################################################################
# ODT
################################################################################

odt() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Create an .odt document in the current directory and open it with LibreOffice."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  odt [filename] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  odt meeting-notes"
  }

  while getopts ":h" opt; do
    case $opt in
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

  touch "$1.odt"
  libreoffice "$1.odt"
}

################################################################################
# ODS
################################################################################

ods() {
  # Use getopts to handle Options
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Create an .ods spreadsheet in the current directory and open it with LibreOffice."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  ods [filename] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  ods budget"
  }

  while getopts ":h" opt; do
    case $opt in
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

  touch "$1.ods"
  libreoffice "$1.ods"
}

################################################################################
# FILEHASH
################################################################################

filehash() {
  OPTIND=1
  OPTERR=0

  local default_method="sha256"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Generate hashes for files with various algorithms."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  filehash [options] [file] [method]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h        Display this help message" \
      "  -m        Display available hash methods" \
      "  -a        Run all hash methods on the file" \
      "  -d [meth] Run the method on each file in the current directory" \
      "  -da       Run all methods on every file in the current directory"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  filehash report.pdf" \
      "  filehash report.pdf sha512" \
      "  filehash -d sha1"
  }

  list_methods() {
    cbc_style_box "$CATPPUCCIN_LAVENDER" "Available hash methods" \
      "  md5     – MD5 hash" \
      "  sha1    – SHA-1 hash" \
      "  sha224  – SHA-224 hash" \
      "  sha256  – SHA-256 hash" \
      "  sha384  – SHA-384 hash" \
      "  sha512  – SHA-512 hash" \
      "  blake2b – BLAKE2b hash"
  }

  method_command() {
    case "$1" in
    md5) printf 'md5sum' ;;
    sha1) printf 'sha1sum' ;;
    sha224) printf 'sha224sum' ;;
    sha256) printf 'sha256sum' ;;
    sha384) printf 'sha384sum' ;;
    sha512) printf 'sha512sum' ;;
    blake2b) printf 'b2sum' ;;
    *) return 1 ;;
    esac
  }

  method_title() {
    case "$1" in
    md5) printf 'MD5' ;;
    sha1) printf 'SHA-1' ;;
    sha224) printf 'SHA-224' ;;
    sha256) printf 'SHA-256' ;;
    sha384) printf 'SHA-384' ;;
    sha512) printf 'SHA-512' ;;
    blake2b) printf 'BLAKE2b' ;;
    *) return 1 ;;
    esac
  }

  validate_method() {
    if ! method_command "$1" >/dev/null 2>&1; then
      cbc_style_message "$CATPPUCCIN_RED" "Unsupported method: $1"
      return 1
    fi
  }

  print_hash_result() {
    local method="$1"
    local file="$2"
    local is_default="$3"

    local cmd
    cmd=$(method_command "$method") || return 1

    if [ ! -f "$file" ]; then
      cbc_style_message "$CATPPUCCIN_RED" "File not found: $file"
      return 1
    fi

    local hash_output
    if ! hash_output=$("$cmd" "$file"); then
      cbc_style_message "$CATPPUCCIN_RED" "Failed to calculate hash with $method for $file"
      return 1
    fi

    local hash_value=${hash_output%% *}
    local method_label
    method_label=$(method_title "$method") || return 1

    local method_line="  Method: $method_label"
    if [ "$is_default" = "1" ]; then
      method_line+=" (default)"
    fi

    cbc_style_box "$CATPPUCCIN_GREEN" "$method_label hash" \
      "  File: $file" \
      "$method_line" \
      "  Hash: $hash_value"
  }

  local opt
  local show_methods=0
  while getopts ":hm" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    m)
      show_methods=1
      ;;
    \?)
      case "$OPTARG" in
      a | d)
        if [ "$OPTIND" -gt 1 ]; then
          OPTIND=$((OPTIND - 1))
        fi
        break
        ;;
      *)
        cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG"
        usage
        return 1
        ;;
      esac
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ "$show_methods" -eq 1 ]; then
    list_methods
    [ $# -eq 0 ] && return 0
  fi

  case "$1" in
  -a)
    shift
    if [ $# -eq 0 ]; then
      cbc_style_message "$CATPPUCCIN_RED" "File was not provided."
      usage
      return 1
    fi
    local file="$1"
    shift
    cbc_style_note "All methods" "  Running every hash on: $file"
    local method
    for method in md5 sha1 sha224 sha256 sha384 sha512 blake2b; do
      print_hash_result "$method" "$file" 0
    done
    return 0
    ;;
  -da)
    shift
    cbc_style_note "Directory scan" "  Running every method on regular files in: $(pwd)"
    local found=0
    local file
    for file in *; do
      if [ -f "$file" ]; then
        found=1
        cbc_style_box "$CATPPUCCIN_BLUE" "File: $file" "  All available hash methods"
        local method
        for method in md5 sha1 sha224 sha256 sha384 sha512 blake2b; do
          print_hash_result "$method" "$file" 0
        done
      fi
    done
    if [ "$found" -eq 0 ]; then
      cbc_style_message "$CATPPUCCIN_YELLOW" "No regular files found in $(pwd)."
    fi
    return 0
    ;;
  -d)
    shift
    local provided_method="$1"
    local used_default=0
    if [ -z "$provided_method" ]; then
      provided_method="$default_method"
      used_default=1
    else
      shift
    fi
    validate_method "$provided_method" || return 1
    local method_label
    method_label=$(method_title "$provided_method") || return 1
    local note_message="  Running $method_label on regular files in: $(pwd)"
    if [ "$used_default" -eq 1 ]; then
      note_message+=" (default)"
    fi
    cbc_style_note "Directory scan" "$note_message"
    local found=0
    local file
    for file in *; do
      if [ -f "$file" ]; then
        found=1
        print_hash_result "$provided_method" "$file" "$used_default"
      fi
    done
    if [ "$found" -eq 0 ]; then
      cbc_style_message "$CATPPUCCIN_YELLOW" "No regular files found in $(pwd)."
    fi
    return 0
    ;;
  esac

  if [ $# -eq 0 ]; then
    cbc_style_message "$CATPPUCCIN_RED" "File was not provided."
    usage
    return 1
  fi

  local file="$1"
  local method_arg="$2"
  local used_default=0
  if [ -z "$method_arg" ]; then
    method_arg="$default_method"
    used_default=1
  fi

  validate_method "$method_arg" || return 1
  print_hash_result "$method_arg" "$file" "$used_default"
}

################################################################################
# DISPLAY INFO
################################################################################

display_info() {
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Display key information about the Custom Bash Commands setup."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  display_info [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  display_info"
  }

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

  display_version
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

  # Temporary directory for sparse checkout
  SPARSE_DIR=$(mktemp -d)

  # URL of the GitHub repository
  REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

  # List of file paths to download and move
  FILE_PATHS=(
    custom_bash_commands.sh
    cbc_aliases.sh
  )

  # Initialize an empty git repository and configure for sparse checkout
  cd $SPARSE_DIR
  git init -q
  git remote add origin $REPO_URL
  git config core.sparseCheckout true

  # Add each file path to the sparse checkout configuration
  for path in "${FILE_PATHS[@]}"; do
    echo "$path" >>.git/info/sparse-checkout
  done

  # Fetch only the desired files from the main branch
  git pull origin main -q

  # Move the fetched files to the target directory
  for path in "${FILE_PATHS[@]}"; do
    # Determine the new filename with '.' prefix (if not already prefixed)
    new_filename="$(basename "$path")"
    if [[ $new_filename != .* ]]; then
      new_filename=".$new_filename"
    fi

    # Copy the file to the home directory with the new filename
    cp "$SPARSE_DIR"/"$path" ~/"$new_filename"
    echo "Copied $path to $new_filename"
  done

  # Clean up
  rm -rf "$SPARSE_DIR"
  cd ~ || return
  clear

  # Source the updated commands
  source ~/.custom_bash_commands.sh
}

###############################################################################
# Call the function to display information once per interactive session
###############################################################################

if [[ $- == *i* ]]; then
  if [ -z "${CBC_INFO_SHOWN:-}" ]; then
    CBC_INFO_SHOWN=1
    export CBC_INFO_SHOWN
    display_info
  fi
fi

###############################################################################
# Source the aliases file if it exists
###############################################################################

# The following lines allows previously defined aliases and functions to be
# used in the terminal after the custom_bash_commands.sh script is run. This
# allows the script to not overwrite previously defined aliases and functions
# by the user. This command must remain at the end of the
# custom_bash_commands.sh script.

# If the .bash_aliases file exists, source it
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi
