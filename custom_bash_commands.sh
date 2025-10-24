#!/usr/bin/env bash
VERSION="v304.2.0"

# -------------------------------------------------------------------------------------------------
# Charmbracelet Gum helpers (Catppuccin Mocha palette)
# -------------------------------------------------------------------------------------------------

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

  # Create the Temporary directory if it does not exist
  mkdir -p ~/Documents/Temporary/screenshots/

  # Create the GitHub Repositories directory if it does not exist
  mkdir -p ~/Documents/github_repositories

  # Create the Grymm's Grimoires directory if it does not exist
  mkdir -p ~/Documents/grymms_grimoires/
}

# Call the setup_directories function
setup_directories

################################################################################################################################
###################################
# CHECK FOR CBC UPDATES
################################################################################################################################
###################################

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
      echo "          Description: Display the version number from the .version file"
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
      echo "         Description: Display help for regular expressions"
      echo "         Usage: regex_help [-f|--flavor <flavor>] [-h|--help]"
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
      echo "remove_all_cbc_configs"
      echo "remove_session_id_config"
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
# UP
################################################################################

# TODO: create usage function and adjust the getopts section and fix the main logic

up() {
  # Initialize flags with default values
  local clear_terminal=false
  local print_directory=false
  local quiet_mode=false
  local detailed_listing=false
  local times=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Move up directories or jump to key locations with optional post-move actions."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  up [-h|-a|-r|-c|-p|-q|-l] [levels]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -a    Return to the home directory" \
      "  -r    Go to the root directory" \
      "  -c    Clear the terminal after moving" \
      "  -p    Print the current directory after moving" \
      "  -q    Suppress ls output" \
      "  -l    Use ls -l for a detailed listing"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  up 2" \
      "  up -a"
  }

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h)
      # Display help message and return
      usage
      return
      ;;
    -a)
      # Change to home directory
      cd ~ || {
        cbc_style_message "$CATPPUCCIN_RED" "Error: Failed to return to home directory."
        return 1
      }
      # List contents if quiet mode is not enabled
      if [ "$quiet_mode" = false ]; then
        if [ "$detailed_listing" = true ]; then
          ls -l
        else
          ls
        fi
      fi
      return
      ;;
    -r)
      # Change to root directory
      cd / || {
        cbc_style_message "$CATPPUCCIN_RED" "Error: Failed to change to root directory."
        return 1
      }
      # List contents if quiet mode is not enabled
      if [ "$quiet_mode" = false ]; then
        if [ "$detailed_listing" = true ]; then
          ls -l
        else
          ls
        fi
      fi
      return
      ;;
    -c)
      # Set flag to clear terminal after moving
      clear_terminal=true
      ;;
    -p)
      # Set flag to print the current directory after moving
      print_directory=true
      ;;
    -q)
      # Set flag to suppress ls output
      quiet_mode=true
      ;;
    -l)
      # Set flag to use detailed listing (ls -l)
      detailed_listing=true
      ;;
    [1-9][0-9]*)
      # Set the number of levels to move up
      times=$1
      ;;
    *)
      # Handle invalid arguments
      cbc_style_message "$CATPPUCCIN_RED" "Error: Invalid argument. Use -h for help."
      return 1
      ;;
    esac
    shift
  done

  # Construct the path to move up the specified number of levels
  local up=()
  while [ "$times" -gt 0 ]; do
    up+=("..")
    times=$((times - 1))
  done

  # Function to join array elements with a delimiter
  join_by() {
    local IFS="$1"
    shift
    echo "$*"
  }

  # Join the array to create the path
  local path="$(join_by / "${up[@]}")"

  # Change directory to the constructed path
  if ! cd "$path"; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Failed to change directory."
    return 1
  fi

  # Clear terminal if the flag is set
  if [ "$clear_terminal" = true ]; then
    clear
  fi

  # Print the current directory if the flag is set
  if [ "$print_directory" = true ]; then
    pwd
  fi

  # List directory contents unless quiet mode is enabled
  if [ "$quiet_mode" = false ]; then
    if [ "$detailed_listing" = true ]; then
      ls -l
    else
      ls
    fi
  fi
}

################################################################################
# REMOVE ALL CBC CONFIGS - BOOKMARK
################################################################################

remove_all_cbc_configs() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Remove CBC-related configuration files from the system."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  remove_all_cbc_configs [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  remove_all_cbc_configs"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG. Use -h for help."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Alias for the remove_all_cbc_configs function
  # Alias: remove_all_cbc_configs="racc"
  # Call the rnc, rsc, and rdvc functions
  remove_session_id_config
}

################################################################################
# MKDIRS
################################################################################

mkdirs() {
  OPTIND=1

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Create a directory (if needed) and switch into it."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  mkdirs [directory] [-h]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  mkdirs test"
  }

  while getopts ":h" opt; do
    case $opt in
    h)
      usage
      return 0
      ;;
    \?)
      cbc_style_message "$CATPPUCCIN_RED" "Invalid option: -$OPTARG. Use -h for help."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Check if the directory name is provided
  if [ -z "$1" ]; then
    cbc_style_message "$CATPPUCCIN_RED" "Error: Directory name is not provided."
    return 1
  else
    # Create the directory and switch into it
    if mkdir -p "$1" && cd "$1"; then
      cbc_style_message "$CATPPUCCIN_GREEN" "Created and moved into directory: $1"
    else
      cbc_style_message "$CATPPUCCIN_RED" "Failed to create or enter directory: $1"
      return 1
    fi
  fi
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
# REGEX HELP (REWRITE)
################################################################################

regex_help() {
  # Default flavor
  local flavor="POSIX-extended"

  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Display regex cheat-sheets for different flavors."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  regex_help [-f|--flavor <flavor>] [-h|--help]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -f|--flavor <flavor>    Specify the regex flavor (POSIX-extended, POSIX-basic, PCRE)" \
      "  -h|--help               Display this help message"

    cbc_style_box "$CATPPUCCIN_PEACH" "Example:" \
      "  regex_help -f PCRE"
  }

  # Check for arguments
  while (("$#")); do
    case "$1" in
    -f | --flavor) # Option for specifying the regex flavor
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        flavor=$2
        shift 2
      else
        cbc_style_message "$CATPPUCCIN_RED" "Error: Argument for $1 is missing"
        return 1
      fi
      ;;
    -h | --help) # Help flag
      usage
      return 0
      ;;
    *) # Handle unexpected options
      cbc_style_message "$CATPPUCCIN_RED" "Error: Unsupported flag $1"
      return 1
      ;;
    esac
  done

  # Displaying regex information based on the chosen flavor
  case "$flavor" in
  # POSIX-extended regex
  "POSIX-extended")
    echo "POSIX-extended regex selected."
    echo "Syntax and common patterns:"
    echo "  - .: Matches any single character"
    echo "  - ^: Matches the start of a line"
    echo "  - $: Matches the end of a line"
    echo "  - *: Matches zero or more occurrences"
    echo "  - +: Matches one or more occurrences"
    echo "  - ?: Matches zero or one occurrence"
    echo "  - [abc]: Matches any one of the characters a, b, or c"
    echo "  - [^abc]: Matches any character not in the set a, b, or c"
    echo "  - (ab|cd): Matches either the sequence 'ab' or 'cd'"
    ;;
  # POSIX-basic regex
  "POSIX-basic")
    echo "POSIX-basic regex selected."
    echo "Syntax and common patterns:"
    echo "  - .: Matches any single character except newline"
    echo "  - ^: Matches the start of a line"
    echo "  - $: Matches the end of a line"
    echo "  - *: Matches zero or more occurrences of the preceding element"
    echo "  - [abc]: Matches any one of the characters a, b, or c"
    echo "  - [^abc]: Matches any character not in the set a, b, or c"
    echo "  - \\(ab\\|cd\\): Backslashes are used to escape special characters"
    ;;
  # PCRE regex
  "PCRE")
    echo "Perl-compatible regex (PCRE) selected."
    echo "Syntax and common patterns:"
    echo "  - .: Matches any character except newline"
    echo "  - ^: Matches the start of the string"
    echo "  - $: Matches the end of the string"
    echo "  - *: Matches 0 or more of the preceding element"
    echo "  - +: Matches 1 or more of the preceding element"
    echo "  - ?: Makes the preceding quantifier lazy"
    echo "  - \\d: Matches any digit character"
    echo "  - \\D: Matches any non-digit character"
    echo "  - \\w: Matches any word character (alphanumeric plus '_')"
    echo "  - \\W: Matches any non-word character"
    echo "  - (abc|def): Matches either 'abc' or 'def'"
    ;;
  *)
    # Handle unexpected flavors
    echo "Error: Unsupported flavor $flavor" >&2
    return 1
    ;;
  esac
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

# Describe the filehash function and its options and usage

# filehash
# Description: A function to generate a hash of a file
# Usage: filehash [file] [method]
# Options:
#   -h    Display this help message
#   -d    Iterate through the current directory and run the specified hash method on each file
#   -a    Run all hash methods on the file
#   -da   Run all hash methods on all files in the current directory

# Example: filehash test.txt sha256  ---Generates a sha256 hash of test.txt.
# Example: filehash -d sha256  ---Generates a sha256 hash of each file in the current directory.
# Example: filehash -a test.txt  ---Runs all hash methods on test.txt.
# Example: filehash -da  ---Runs all hash methods on all files in the current directory.

# Define the filehash function to generate a hash of a file

# TODO: add usage function, fix getopts section, and fix the main logic
# Additionally, rework the whole function and make it more user-friendly

filehash() {
  usage() {
    cbc_style_box "$CATPPUCCIN_MAUVE" "Description:" \
      "  Generate hashes for files with various algorithms."

    cbc_style_box "$CATPPUCCIN_BLUE" "Usage:" \
      "  filehash [options] [file] [method]"

    cbc_style_box "$CATPPUCCIN_TEAL" "Options:" \
      "  -h    Display this help message" \
      "  -m    Display available hash methods" \
      "  -a    Run all hash methods on the file" \
      "  -d    Run the specified method on each file in the current directory" \
      "  -da   Run all methods on every file in the current directory"

    cbc_style_box "$CATPPUCCIN_PEACH" "Examples:" \
      "  filehash test.txt sha256" \
      "  filehash -d sha256"
  }

  if [ "$1" = "-h" ]; then
    # Display help message if -h option is provided
    usage
    return 0
  fi
  # Alias for the filehash function
  # alias fh="filehash"

  # Check if the first argument is a tag for displaying available methods
  if [ "$1" = "-m" ]; then
    echo " "
    echo "#############################"
    echo "## Available hash methods: ##"
    echo "#############################"
    echo " "
    echo "  md5     - MD5 hash"
    echo "  sha1    - SHA-1 hash"
    echo "  sha224  - SHA-224 hash"
    echo "  sha256  - SHA-256 hash"
    echo "  sha384  - SHA-384 hash"
    echo "  sha512  - SHA-512 hash"
    echo "  blake2b - BLAKE2b hash"
    # Add additional methods and descriptions here
    return
  fi

  # Check if the -a tag is provided to run each hash method
  if [ "$1" = "-a" ]; then
    shift
    if [ $# -eq 0 ]; then
      echo " "
      echo "#########################################"
      echo "## File was not provided... Try again. ##"
      echo "#########################################"
      return
    fi
    local file=$1
    shift
    echo " "
    echo "#############################################"
    echo "## Running all hash methods on file: $file ##"
    echo "#############################################"
    echo " "
    echo "MD5:     $(md5sum $file)"
    echo "SHA-1:   $(sha1sum $file)"
    echo "SHA-224: $(sha224sum $file)"
    echo "SHA-256: $(sha256sum $file)"
    echo "SHA-384: $(sha384sum $file)"
    echo "SHA-512: $(sha512sum $file)"
    echo "BLAKE2b: $(b2sum $file)"
    # Add additional hash methods here
    return
  fi

  # Check if the -d tag is provided to iterate through the current directory
  if [ "$1" = "-d" ]; then
    shift
    local method=${1:-sha256}
    echo " "
    echo "#########################################################"
    echo "## Ran $method hash on files in the current directory.  ##"
    echo "#########################################################"
    echo " "
    for file in *; do
      if [ -f "$file" ]; then
        echo "$(sha256sum $file)"
      fi
    done
    return
  fi

  # Check if the -da tag is provided to run all hash methods on all files in the current directory
  if [ "$1" = "-da" ]; then
    shift
    echo " "
    echo "#############################################"
    echo "## Running all hash methods on all files.  ##"
    echo "#############################################"
    echo " "
    for file in *; do
      if [ -f "$file" ]; then
        echo " "
        echo "##########################################################################################"
        echo "Running all hash methods on file: $file "
        echo "##########################################################################################"
        echo " "
        echo "MD5:     $(md5sum $file)"
        echo "SHA-1:   $(sha1sum $file)"
        echo "SHA-224: $(sha224sum $file)"
        echo "SHA-256: $(sha256sum $file)"
        echo "SHA-384: $(sha384sum $file)"
        echo "SHA-512: $(sha512sum $file)"
        echo "BLAKE2b: $(b2sum $file)"
        # Add additional hash methods here
      fi
    done
    echo "##########################################################################################"
    return
  fi

  # Check if a file was provided
  if [ $# -eq 0 ]; then
    echo " "
    echo "#########################################"
    echo "## File was not provided... Try again. ##"
    echo "#########################################"
    echo " "
    return 1
  fi

  # Set the default hash method to sha256 if not provided
  local method=${2:-sha256}

  # Generate hash based on the specified method
  case "$method" in
  md5) md5sum $1 ;;
  sha1) sha1sum $1 ;;
  sha224) sha224sum $1 ;;
  sha256) sha256sum $1 ;;
  sha384) sha384sum $1 ;;
  sha512) sha512sum $1 ;;
  blake2b) b2sum $1 ;;
  # Additional cases for other hash methods
  *) echo "Unsupported method: $method" ;;
  esac
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

# TODO: add usage function, fix getopts section, and fix the main logic

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
    .version
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

###################################################################################################################################################################

# Call the function to display information
display_info

###################################################################################################################################################################
###################################################################################################################################################################

# The following lines allows previously defined aliases and functions to be used in the terminal after the custom_bash_commands.sh script is run
# This allows the script to not overwrite previously defined aliases and functions by the user
# This command must remain at the end of the custom_bash_commands.sh script

# If the .bash_aliases file exists, source it
if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi

###################################################################################################################################################################
# Ensure zoxide is installed, and if not install it.
###################################################################################################################################################################

# Function to check if zoxide is installed and install it if necessary
# check_install_zoxide() {
#   # Check if zoxide is installed, and if it is, source the zoxide init script
#   if command -v zoxide &>/dev/null; then
#     # eval "$(zoxide init --cmd cd bash)"
#   # If zoxide is not installed, install it
#   else
#     echo "zoxide not found. Install with chezmoi"
#   fi
# }

###################################################################################################################################################################
# Ensure obsidian is installed, and if not install it.
###################################################################################################################################################################

# Function to check if obsidian is installed and install it if necessary
check_install_obsidian() {
  if ! command -v obsidian &>/dev/null; then
    echo "obsidian not found. Install with chezmoi."
  fi
}

# Change so that each piece of software is installed using a function to modularize the code.
# If zoxide is installed, source the zoxide init script
# If not installed, do nothing.
# Create a command to install zoxide if it is not installed.
# Create a command to install fzf if it is not installed.
# Echo a message to inform the user that they need to refresh the terminal after installing zoxide and fzf.
# Create a function to check for additional software, and if it is not installed, create options for the user to select if they would like to install any.
# This allows full customization of the additional software.
# This can be part of a separate set up script that can be run for an initial installation.
# The set up script should set up the .bashrc file, install additional software, and set up the custom bash commands in the correct directories.

###################################################################################################################################################################
# Check if bat is installed, and if not, install it.
###################################################################################################################################################################

# Function to check and install bat if not already installed
check_install_bat() {
  if ! command -v batcat &>/dev/null; then
    echo "bat not found. Install with chezmoi."
  fi
}

###################################################################################################################################################################
# Check if hstr is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if hstr is installed and install it if not
check_install_hstr() {
  if ! command -v hstr &>/dev/null; then
    echo "Hstr not found. Installing..."
    sudo apt install hstr
    echo "hstr has been installed."
  fi
}

# If hstr is installed, set configs for hstr
if command -v hstr &>/dev/null; then
  # Set alias for hstr
  alias hh=hstr
  # Configure hstr with colors and prompt at the bottom
  export HSTR_CONFIG=hicolor,prompt-bottom,blacklist
  # Append new history items to .bash_history
  shopt -s histappend
  # Ignore commands starting with a space in history
  export HISTCONTROL=ignorespace
  # Increase history file size
  export HISTFILESIZE=10000
  # Increase history size
  export HISTSIZE=${HISTFILESIZE}
  # ensure synchronization between bash memory and history file
  export PROMPT_COMMAND="history -a; history -n; ${PROMPT_COMMAND}"
  # if this is interactive shell, then bind hstr to Ctrl-r (for Vi mode check doc)
  if [[ $- =~ .*i.* ]]; then bind '"\C-r": "\C-a hstr -- \C-j"'; fi
  # if this is interactive shell, then bind 'kill last command' to Ctrl-x k
  if [[ $- =~ .*i.* ]]; then bind '"\C-xk": "\C-a hstr -k \C-j"'; fi
  # Bind Vim keys
  bind '"\C-r": "\e^ihstr -- \n"'
fi

###############################################################################
# Additional Software Installation
###############################################################################

# Read the configuration file and check if BAT=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${BAT:=false}" == "true" ]]; then
    # Call the function to check bat installation and install bat
    check_install_bat
  fi
fi

# Read the configuration file and check if ZOXIDE=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${ZOXIDE:=false}" == "true" ]]; then
    # Call the function to check zoxide installation and install zoxide
    check_install_zoxide
  fi
fi

# Check if zoxide is installed, and if it is, source the zoxide init script
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi

###############################################################################
###############################################################################
# EXPORTS
###############################################################################
###############################################################################

###############################################################################
# Remove history duplications
###############################################################################

export HISTCONTROL=ignoredups:erasedups

###############################################################################
# Set the default editor to neovim if and only if neovim is installed and set manpager as neovim
###############################################################################

if command -v nvim &>/dev/null; then
  export EDITOR=nvim
  export MANPAGER="nvim +Man!"
fi
###############################################################################
###############################################################################
# Set terminal behavior to mimic vim
###############################################################################
###############################################################################

set -o vi

###############################################################################
###############################################################################
# ZELLIJ COMPLETION (Turn into a module maybe?)
###############################################################################
###############################################################################

_zellij() {
  local i cur prev opts cmds
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  cmd=""
  opts=""

  for i in ${COMP_WORDS[@]}; do
    case "${i}" in
    "$1")
      cmd="zellij"
      ;;
    action)
      cmd+="__action"
      ;;
    attach)
      cmd+="__attach"
      ;;
    clear)
      cmd+="__clear"
      ;;
    close-pane)
      cmd+="__close__pane"
      ;;
    close-tab)
      cmd+="__close__tab"
      ;;
    convert-config)
      cmd+="__convert__config"
      ;;
    convert-layout)
      cmd+="__convert__layout"
      ;;
    convert-theme)
      cmd+="__convert__theme"
      ;;
    delete-all-sessions)
      cmd+="__delete__all__sessions"
      ;;
    delete-session)
      cmd+="__delete__session"
      ;;
    dump-layout)
      cmd+="__dump__layout"
      ;;
    dump-screen)
      cmd+="__dump__screen"
      ;;
    edit)
      cmd+="__edit"
      ;;
    edit-scrollback)
      cmd+="__edit__scrollback"
      ;;
    focus-next-pane)
      cmd+="__focus__next__pane"
      ;;
    focus-previous-pane)
      cmd+="__focus__previous__pane"
      ;;
    go-to-next-tab)
      cmd+="__go__to__next__tab"
      ;;
    go-to-previous-tab)
      cmd+="__go__to__previous__tab"
      ;;
    go-to-tab)
      cmd+="__go__to__tab"
      ;;
    go-to-tab-name)
      cmd+="__go__to__tab__name"
      ;;
    half-page-scroll-down)
      cmd+="__half__page__scroll__down"
      ;;
    half-page-scroll-up)
      cmd+="__half__page__scroll__up"
      ;;
    help)
      cmd+="__help"
      ;;
    kill-all-sessions)
      cmd+="__kill__all__sessions"
      ;;
    kill-session)
      cmd+="__kill__session"
      ;;
    launch-or-focus-plugin)
      cmd+="__launch__or__focus__plugin"
      ;;
    launch-plugin)
      cmd+="__launch__plugin"
      ;;
    list-aliases)
      cmd+="__list__aliases"
      ;;
    list-clients)
      cmd+="__list__clients"
      ;;
    list-sessions)
      cmd+="__list__sessions"
      ;;
    move-focus)
      cmd+="__move__focus"
      ;;
    move-focus-or-tab)
      cmd+="__move__focus__or__tab"
      ;;
    move-pane)
      cmd+="__move__pane"
      ;;
    move-pane-backwards)
      cmd+="__move__pane__backwards"
      ;;
    move-tab)
      cmd+="__move__tab"
      ;;
    new-pane)
      cmd+="__new__pane"
      ;;
    new-tab)
      cmd+="__new__tab"
      ;;
    next-swap-layout)
      cmd+="__next__swap__layout"
      ;;
    options)
      cmd+="__options"
      ;;
    page-scroll-down)
      cmd+="__page__scroll__down"
      ;;
    page-scroll-up)
      cmd+="__page__scroll__up"
      ;;
    pipe)
      cmd+="__pipe"
      ;;
    plugin)
      cmd+="__plugin"
      ;;
    previous-swap-layout)
      cmd+="__previous__swap__layout"
      ;;
    query-tab-names)
      cmd+="__query__tab__names"
      ;;
    rename-pane)
      cmd+="__rename__pane"
      ;;
    rename-session)
      cmd+="__rename__session"
      ;;
    rename-tab)
      cmd+="__rename__tab"
      ;;
    resize)
      cmd+="__resize"
      ;;
    run)
      cmd+="__run"
      ;;
    scroll-down)
      cmd+="__scroll__down"
      ;;
    scroll-to-bottom)
      cmd+="__scroll__to__bottom"
      ;;
    scroll-to-top)
      cmd+="__scroll__to__top"
      ;;
    scroll-up)
      cmd+="__scroll__up"
      ;;
    setup)
      cmd+="__setup"
      ;;
    start-or-reload-plugin)
      cmd+="__start__or__reload__plugin"
      ;;
    switch-mode)
      cmd+="__switch__mode"
      ;;
    toggle-active-sync-tab)
      cmd+="__toggle__active__sync__tab"
      ;;
    toggle-floating-panes)
      cmd+="__toggle__floating__panes"
      ;;
    toggle-fullscreen)
      cmd+="__toggle__fullscreen"
      ;;
    toggle-pane-embed-or-floating)
      cmd+="__toggle__pane__embed__or__floating"
      ;;
    toggle-pane-frames)
      cmd+="__toggle__pane__frames"
      ;;
    undo-rename-pane)
      cmd+="__undo__rename__pane"
      ;;
    undo-rename-tab)
      cmd+="__undo__rename__tab"
      ;;
    write)
      cmd+="__write"
      ;;
    write-chars)
      cmd+="__write__chars"
      ;;
    *) ;;
    esac
  done

  case "${cmd}" in
  zellij)
    opts="-h -V -s -l -c -d --help --version --max-panes --data-dir --server --session --layout --config --config-dir --debug options setup list-sessions list-aliases attach kill-session delete-session kill-all-sessions delete-all-sessions action run plugin edit convert-config convert-layout convert-theme pipe help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --max-panes)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --data-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --server)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --session)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -s)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -l)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --config)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --config-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action)
    opts="-h --help write write-chars resize focus-next-pane focus-previous-pane move-focus move-focus-or-tab move-pane move-pane-backwards clear dump-screen dump-layout edit-scrollback scroll-up scroll-down scroll-to-bottom scroll-to-top page-scroll-up page-scroll-down half-page-scroll-up half-page-scroll-down toggle-fullscreen toggle-pane-frames toggle-active-sync-tab new-pane edit switch-mode toggle-pane-embed-or-floating toggle-floating-panes close-pane rename-pane undo-rename-pane go-to-next-tab go-to-previous-tab close-tab go-to-tab go-to-tab-name rename-tab undo-rename-tab new-tab move-tab previous-swap-layout next-swap-layout query-tab-names start-or-reload-plugin launch-or-focus-plugin launch-plugin rename-session pipe list-clients help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__clear)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__close__pane)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__close__tab)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__dump__layout)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__dump__screen)
    opts="-f -h --full --help <PATH>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__edit)
    opts="-d -l -f -i -x -y -h --direction --line-number --floating --in-place --cwd --x --y --width --height --help <FILE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --direction)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --line-number)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -l)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --width)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__edit__scrollback)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__focus__next__pane)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__focus__previous__pane)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__go__to__next__tab)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__go__to__previous__tab)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__go__to__tab)
    opts="-h --help <INDEX>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__go__to__tab__name)
    opts="-c -h --create --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__half__page__scroll__down)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__half__page__scroll__up)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__help)
    opts="<SUBCOMMAND>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__launch__or__focus__plugin)
    opts="-f -i -m -c -s -h --floating --in-place --move-to-focused-tab --configuration --skip-plugin-cache --help <URL>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__launch__plugin)
    opts="-f -i -c -s -h --floating --in-place --configuration --skip-plugin-cache --help <URL>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__list__clients)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__move__focus)
    opts="-h --help <DIRECTION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__move__focus__or__tab)
    opts="-h --help <DIRECTION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__move__pane)
    opts="-h --help <DIRECTION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__move__pane__backwards)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__move__tab)
    opts="-h --help <DIRECTION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__new__pane)
    opts="-d -p -f -i -n -c -s -x -y -h --direction --plugin --cwd --floating --in-place --name --close-on-exit --start-suspended --configuration --skip-plugin-cache --x --y --width --height --help <COMMAND>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --direction)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --width)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__new__tab)
    opts="-l -n -c -h --layout --layout-dir --name --cwd --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -l)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --layout-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__next__swap__layout)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__page__scroll__down)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__page__scroll__up)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__pipe)
    opts="-n -a -p -c -l -s -f -i -w -t -h --name --args --plugin --plugin-configuration --force-launch-plugin --skip-plugin-cache --floating-plugin --in-place-plugin --plugin-cwd --plugin-title --help <PAYLOAD>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --args)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -a)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin-configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --floating-plugin)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    -f)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --in-place-plugin)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    -i)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --plugin-cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -w)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin-title)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__previous__swap__layout)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__query__tab__names)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__rename__pane)
    opts="-h --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__rename__session)
    opts="-h --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__rename__tab)
    opts="-h --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__resize)
    opts="-h --help <RESIZE> <DIRECTION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__scroll__down)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__scroll__to__bottom)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__scroll__to__top)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__scroll__up)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__start__or__reload__plugin)
    opts="-c -h --configuration --help <URL>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__switch__mode)
    opts="-h --help <INPUT_MODE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__toggle__active__sync__tab)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__toggle__floating__panes)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__toggle__fullscreen)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__toggle__pane__embed__or__floating)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__toggle__pane__frames)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__undo__rename__pane)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__undo__rename__tab)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__write)
    opts="-h --help <BYTES>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__action__write__chars)
    opts="-h --help <CHARS>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__attach)
    opts="-c -b -f -h --create --create-background --index --force-run-commands --help <SESSION_NAME> options help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --index)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__attach__help)
    opts="<SUBCOMMAND>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__attach__options)
    opts="-h --disable-mouse-mode --no-pane-frames --simplified-ui --theme --default-mode --default-shell --default-cwd --default-layout --layout-dir --theme-dir --mouse-mode --pane-frames --mirror-session --on-force-close --scroll-buffer-size --copy-command --copy-clipboard --copy-on-select --scrollback-editor --session-name --attach-to-session --auto-layout --session-serialization --serialize-pane-viewport --scrollback-lines-to-serialize --styled-underlines --serialization-interval --disable-session-metadata --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --simplified-ui)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --theme)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-mode)
      COMPREPLY=($(compgen -W "normal locked resize pane tab scroll enter-search search rename-tab rename-pane session move prompt tmux" -- "${cur}"))
      return 0
      ;;
    --default-shell)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --layout-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --theme-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --mouse-mode)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --pane-frames)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --mirror-session)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --on-force-close)
      COMPREPLY=($(compgen -W "quit detach" -- "${cur}"))
      return 0
      ;;
    --scroll-buffer-size)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --copy-command)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --copy-clipboard)
      COMPREPLY=($(compgen -W "system primary" -- "${cur}"))
      return 0
      ;;
    --copy-on-select)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --scrollback-editor)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --session-name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --attach-to-session)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --auto-layout)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --session-serialization)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --serialize-pane-viewport)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --scrollback-lines-to-serialize)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --styled-underlines)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --serialization-interval)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --disable-session-metadata)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__convert__config)
    opts="-h --help <OLD_CONFIG_FILE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__convert__layout)
    opts="-h --help <OLD_LAYOUT_FILE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__convert__theme)
    opts="-h --help <OLD_THEME_FILE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__delete__all__sessions)
    opts="-y -f -h --yes --force --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__delete__session)
    opts="-f -h --force --help <TARGET_SESSION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__edit)
    opts="-l -d -i -f -x -y -h --line-number --direction --in-place --floating --cwd --x --y --width --height --help <FILE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --line-number)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -l)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --direction)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --width)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__help)
    opts="<SUBCOMMAND>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__kill__all__sessions)
    opts="-y -h --yes --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__kill__session)
    opts="-h --help <TARGET_SESSION>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__list__aliases)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__list__sessions)
    opts="-n -s -r -h --no-formatting --short --reverse --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__options)
    opts="-h --disable-mouse-mode --no-pane-frames --simplified-ui --theme --default-mode --default-shell --default-cwd --default-layout --layout-dir --theme-dir --mouse-mode --pane-frames --mirror-session --on-force-close --scroll-buffer-size --copy-command --copy-clipboard --copy-on-select --scrollback-editor --session-name --attach-to-session --auto-layout --session-serialization --serialize-pane-viewport --scrollback-lines-to-serialize --styled-underlines --serialization-interval --disable-session-metadata --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --simplified-ui)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --theme)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-mode)
      COMPREPLY=($(compgen -W "normal locked resize pane tab scroll enter-search search rename-tab rename-pane session move prompt tmux" -- "${cur}"))
      return 0
      ;;
    --default-shell)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --default-layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --layout-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --theme-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --mouse-mode)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --pane-frames)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --mirror-session)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --on-force-close)
      COMPREPLY=($(compgen -W "quit detach" -- "${cur}"))
      return 0
      ;;
    --scroll-buffer-size)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --copy-command)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --copy-clipboard)
      COMPREPLY=($(compgen -W "system primary" -- "${cur}"))
      return 0
      ;;
    --copy-on-select)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --scrollback-editor)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --session-name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --attach-to-session)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --auto-layout)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --session-serialization)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --serialize-pane-viewport)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --scrollback-lines-to-serialize)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --styled-underlines)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --serialization-interval)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --disable-session-metadata)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__pipe)
    opts="-n -a -p -c -h --name --args --plugin --plugin-configuration --help <PAYLOAD>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --args)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -a)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --plugin-configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__plugin)
    opts="-c -f -i -s -x -y -h --configuration --floating --in-place --skip-plugin-cache --x --y --width --height --help <URL>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --configuration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --width)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__run)
    opts="-d -f -i -n -c -s -x -y -h --direction --cwd --floating --in-place --name --close-on-exit --start-suspended --x --y --width --height --help <COMMAND>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --direction)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --name)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -x)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -y)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --width)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  zellij__setup)
    opts="-h --dump-config --clean --check --dump-layout --dump-swap-layout --dump-plugins --generate-completion --generate-auto-start --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --dump-layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --dump-swap-layout)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --dump-plugins)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --generate-completion)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --generate-auto-start)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  esac
}

complete -F _zellij -o bashdefault -o default zellij
function zr() { zellij run --name "$*" -- bash -ic "$*"; }
function zrf() { zellij run --name "$*" --floating -- bash -ic "$*"; }
function zri() { zellij run --name "$*" --in-place -- bash -ic "$*"; }
function ze() { zellij edit "$*"; }
function zef() { zellij edit --floating "$*"; }
function zei() { zellij edit --in-place "$*"; }
function zpipe() {
  if [ -z "$1" ]; then
    zellij pipe
  else
    zellij pipe -p $1
  fi
}

###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################

###################################################################################################################################################################
# GH LICENSE AUTOCOMPLETION
###################################################################################################################################################################

# bash completion V2 for gh-license                           -*- shell-script -*-

__gh-license_debug() {
  if [[ -n ${BASH_COMP_DEBUG_FILE:-} ]]; then
    echo "$*" >>"${BASH_COMP_DEBUG_FILE}"
  fi
}

# Macs have bash3 for which the bash-completion package doesn't include
# _init_completion. This is a minimal version of that function.
__gh-license_init_completion() {
  COMPREPLY=()
  _get_comp_words_by_ref "$@" cur prev words cword
}

# This function calls the gh-license program to obtain the completion
# results and the directive.  It fills the 'out' and 'directive' vars.
__gh-license_get_completion_results() {
  local requestComp lastParam lastChar args

  # Prepare the command to request completions for the program.
  # Calling ${words[0]} instead of directly gh-license allows to handle aliases
  args=("${words[@]:1}")
  requestComp="${words[0]} __complete ${args[*]}"

  lastParam=${words[$((${#words[@]} - 1))]}
  lastChar=${lastParam:$((${#lastParam} - 1)):1}
  __gh-license_debug "lastParam ${lastParam}, lastChar ${lastChar}"

  if [ -z "${cur}" ] && [ "${lastChar}" != "=" ]; then
    # If the last parameter is complete (there is a space following it)
    # We add an extra empty parameter so we can indicate this to the go method.
    __gh-license_debug "Adding extra empty parameter"
    requestComp="${requestComp} ''"
  fi

  # When completing a flag with an = (e.g., gh-license -n=<TAB>)
  # bash focuses on the part after the =, so we need to remove
  # the flag part from $cur
  if [[ "${cur}" == -*=* ]]; then
    cur="${cur#*=}"
  fi

  __gh-license_debug "Calling ${requestComp}"
  # Use eval to handle any environment variables and such
  out=$(eval "${requestComp}" 2>/dev/null)

  # Extract the directive integer at the very end of the output following a colon (:)
  directive=${out##*:}
  # Remove the directive
  out=${out%:*}
  if [ "${directive}" = "${out}" ]; then
    # There is not directive specified
    directive=0
  fi
  __gh-license_debug "The completion directive is: ${directive}"
  __gh-license_debug "The completions are: ${out}"
}

__gh-license_process_completion_results() {
  local shellCompDirectiveError=1
  local shellCompDirectiveNoSpace=2
  local shellCompDirectiveNoFileComp=4
  local shellCompDirectiveFilterFileExt=8
  local shellCompDirectiveFilterDirs=16

  if [ $((directive & shellCompDirectiveError)) -ne 0 ]; then
    # Error code.  No completion.
    __gh-license_debug "Received error from custom completion go code"
    return
  else
    if [ $((directive & shellCompDirectiveNoSpace)) -ne 0 ]; then
      if [[ $(type -t compopt) = "builtin" ]]; then
        __gh-license_debug "Activating no space"
        compopt -o nospace
      else
        __gh-license_debug "No space directive not supported in this version of bash"
      fi
    fi
    if [ $((directive & shellCompDirectiveNoFileComp)) -ne 0 ]; then
      if [[ $(type -t compopt) = "builtin" ]]; then
        __gh-license_debug "Activating no file completion"
        compopt +o default
      else
        __gh-license_debug "No file completion directive not supported in this version of bash"
      fi
    fi
  fi

  # Separate activeHelp from normal completions
  local completions=()
  local activeHelp=()
  __gh-license_extract_activeHelp

  if [ $((directive & shellCompDirectiveFilterFileExt)) -ne 0 ]; then
    # File extension filtering
    local fullFilter filter filteringCmd

    # Do not use quotes around the $completions variable or else newline
    # characters will be kept.
    for filter in ${completions[*]}; do
      fullFilter+="$filter|"
    done

    filteringCmd="_filedir $fullFilter"
    __gh-license_debug "File filtering command: $filteringCmd"
    $filteringCmd
  elif [ $((directive & shellCompDirectiveFilterDirs)) -ne 0 ]; then
    # File completion for directories only

    # Use printf to strip any trailing newline
    local subdir
    subdir=$(printf "%s" "${completions[0]}")
    if [ -n "$subdir" ]; then
      __gh-license_debug "Listing directories in $subdir"
      pushd "$subdir" >/dev/null 2>&1 && _filedir -d && popd >/dev/null 2>&1 || return
    else
      __gh-license_debug "Listing directories in ."
      _filedir -d
    fi
  else
    __gh-license_handle_completion_types
  fi

  __gh-license_handle_special_char "$cur" :
  __gh-license_handle_special_char "$cur" =

  # Print the activeHelp statements before we finish
  if [ ${#activeHelp[*]} -ne 0 ]; then
    printf "\n"
    printf "%s\n" "${activeHelp[@]}"
    printf "\n"

    # The prompt format is only available from bash 4.4.
    # We test if it is available before using it.
    if (x=${PS1@P}) 2>/dev/null; then
      printf "%s" "${PS1@P}${COMP_LINE[@]}"
    else
      # Can't print the prompt.  Just print the
      # text the user had typed, it is workable enough.
      printf "%s" "${COMP_LINE[@]}"
    fi
  fi
}

# Separate activeHelp lines from real completions.
# Fills the $activeHelp and $completions arrays.
__gh-license_extract_activeHelp() {
  local activeHelpMarker="_activeHelp_ "
  local endIndex=${#activeHelpMarker}

  while IFS='' read -r comp; do
    if [ "${comp:0:endIndex}" = "$activeHelpMarker" ]; then
      comp=${comp:endIndex}
      __gh-license_debug "ActiveHelp found: $comp"
      if [ -n "$comp" ]; then
        activeHelp+=("$comp")
      fi
    else
      # Not an activeHelp line but a normal completion
      completions+=("$comp")
    fi
  done < <(printf "%s\n" "${out}")
}

__gh-license_handle_completion_types() {
  __gh-license_debug "__gh-license_handle_completion_types: COMP_TYPE is $COMP_TYPE"

  case $COMP_TYPE in
  37 | 42)
    # Type: menu-complete/menu-complete-backward and insert-completions
    # If the user requested inserting one completion at a time, or all
    # completions at once on the command-line we must remove the descriptions.
    # https://github.com/spf13/cobra/issues/1508
    local tab=$'\t' comp
    while IFS='' read -r comp; do
      [[ -z $comp ]] && continue
      # Strip any description
      comp=${comp%%$tab*}
      # Only consider the completions that match
      if [[ $comp == "$cur"* ]]; then
        COMPREPLY+=("$comp")
      fi
    done < <(printf "%s\n" "${completions[@]}")
    ;;

  *)
    # Type: complete (normal completion)
    __gh-license_handle_standard_completion_case
    ;;
  esac
}

__gh-license_handle_standard_completion_case() {
  local tab=$'\t' comp

  # Short circuit to optimize if we don't have descriptions
  if [[ "${completions[*]}" != *$tab* ]]; then
    IFS=$'\n' read -ra COMPREPLY -d '' < <(compgen -W "${completions[*]}" -- "$cur")
    return 0
  fi

  local longest=0
  local compline
  # Look for the longest completion so that we can format things nicely
  while IFS='' read -r compline; do
    [[ -z $compline ]] && continue
    # Strip any description before checking the length
    comp=${compline%%$tab*}
    # Only consider the completions that match
    [[ $comp == "$cur"* ]] || continue
    COMPREPLY+=("$compline")
    if ((${#comp} > longest)); then
      longest=${#comp}
    fi
  done < <(printf "%s\n" "${completions[@]}")

  # If there is a single completion left, remove the description text
  if [ ${#COMPREPLY[*]} -eq 1 ]; then
    __gh-license_debug "COMPREPLY[0]: ${COMPREPLY[0]}"
    comp="${COMPREPLY[0]%%$tab*}"
    __gh-license_debug "Removed description from single completion, which is now: ${comp}"
    COMPREPLY[0]=$comp
  else # Format the descriptions
    __gh-license_format_comp_descriptions $longest
  fi
}

__gh-license_handle_special_char() {
  local comp="$1"
  local char=$2
  if [[ "$comp" == *${char}* && "$COMP_WORDBREAKS" == *${char}* ]]; then
    local word=${comp%"${comp##*${char}}"}
    local idx=${#COMPREPLY[*]}
    while [[ $((--idx)) -ge 0 ]]; do
      COMPREPLY[$idx]=${COMPREPLY[$idx]#"$word"}
    done
  fi
}

__gh-license_format_comp_descriptions() {
  local tab=$'\t'
  local comp desc maxdesclength
  local longest=$1

  local i ci
  for ci in ${!COMPREPLY[*]}; do
    comp=${COMPREPLY[ci]}
    # Properly format the description string which follows a tab character if there is one
    if [[ "$comp" == *$tab* ]]; then
      __gh-license_debug "Original comp: $comp"
      desc=${comp#*$tab}
      comp=${comp%%$tab*}

      # $COLUMNS stores the current shell width.
      # Remove an extra 4 because we add 2 spaces and 2 parentheses.
      maxdesclength=$((COLUMNS - longest - 4))

      # Make sure we can fit a description of at least 8 characters
      # if we are to align the descriptions.
      if [[ $maxdesclength -gt 8 ]]; then
        # Add the proper number of spaces to align the descriptions
        for ((i = ${#comp}; i < longest; i++)); do
          comp+=" "
        done
      else
        # Don't pad the descriptions so we can fit more text after the completion
        maxdesclength=$((COLUMNS - ${#comp} - 4))
      fi

      # If there is enough space for any description text,
      # truncate the descriptions that are too long for the shell width
      if [ $maxdesclength -gt 0 ]; then
        if [ ${#desc} -gt $maxdesclength ]; then
          desc=${desc:0:$((maxdesclength - 1))}
          desc+="…"
        fi
        comp+="  ($desc)"
      fi
      COMPREPLY[ci]=$comp
      __gh-license_debug "Final comp: $comp"
    fi
  done
}

__start_gh-license() {
  local cur prev words cword split

  COMPREPLY=()

  # Call _init_completion from the bash-completion package
  # to prepare the arguments properly
  if declare -F _init_completion >/dev/null 2>&1; then
    _init_completion -n "=:" || return
  else
    __gh-license_init_completion -n "=:" || return
  fi

  __gh-license_debug
  __gh-license_debug "========= starting completion logic =========="
  __gh-license_debug "cur is ${cur}, words[*] is ${words[*]}, #words[@] is ${#words[@]}, cword is $cword"

  # The user could have moved the cursor backwards on the command-line.
  # We need to trigger completion from the $cword location, so we need
  # to truncate the command-line ($words) up to the $cword location.
  words=("${words[@]:0:$cword+1}")
  __gh-license_debug "Truncated words[*]: ${words[*]},"

  local out directive
  __gh-license_get_completion_results
  __gh-license_process_completion_results
}

if [[ $(type -t compopt) = "builtin" ]]; then
  complete -o default -F __start_gh-license gh-license
else
  complete -o default -o nospace -F __start_gh-license gh-license
fi

# ex: ts=4 sw=4 et filetype=sh

###################################################################################################################################################################
# ATUIN AUTOCOMPLETION
###################################################################################################################################################################

. "$HOME/.atuin/bin/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"
_atuin() {
  local i cur prev opts cmd
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  cmd=""
  opts=""

  for i in ${COMP_WORDS[@]}; do
    case "${cmd},${i}" in
    ",$1")
      cmd="atuin"
      ;;
    atuin,account)
      cmd="atuin__account"
      ;;
    atuin,contributors)
      cmd="atuin__contributors"
      ;;
    atuin,daemon)
      cmd="atuin__daemon"
      ;;
    atuin,default-config)
      cmd="atuin__default__config"
      ;;
    atuin,doctor)
      cmd="atuin__doctor"
      ;;
    atuin,dotfiles)
      cmd="atuin__dotfiles"
      ;;
    atuin,gen-completions)
      cmd="atuin__gen__completions"
      ;;
    atuin,help)
      cmd="atuin__help"
      ;;
    atuin,history)
      cmd="atuin__history"
      ;;
    atuin,import)
      cmd="atuin__import"
      ;;
    atuin,info)
      cmd="atuin__info"
      ;;
    atuin,init)
      cmd="atuin__init"
      ;;
    atuin,key)
      cmd="atuin__key"
      ;;
    atuin,kv)
      cmd="atuin__kv"
      ;;
    atuin,login)
      cmd="atuin__login"
      ;;
    atuin,logout)
      cmd="atuin__logout"
      ;;
    atuin,register)
      cmd="atuin__register"
      ;;
    atuin,scripts)
      cmd="atuin__scripts"
      ;;
    atuin,search)
      cmd="atuin__search"
      ;;
    atuin,server)
      cmd="atuin__server"
      ;;
    atuin,stats)
      cmd="atuin__stats"
      ;;
    atuin,status)
      cmd="atuin__status"
      ;;
    atuin,store)
      cmd="atuin__store"
      ;;
    atuin,sync)
      cmd="atuin__sync"
      ;;
    atuin,uuid)
      cmd="atuin__uuid"
      ;;
    atuin,wrapped)
      cmd="atuin__wrapped"
      ;;
    atuin__account,change-password)
      cmd="atuin__account__change__password"
      ;;
    atuin__account,delete)
      cmd="atuin__account__delete"
      ;;
    atuin__account,help)
      cmd="atuin__account__help"
      ;;
    atuin__account,login)
      cmd="atuin__account__login"
      ;;
    atuin__account,logout)
      cmd="atuin__account__logout"
      ;;
    atuin__account,register)
      cmd="atuin__account__register"
      ;;
    atuin__account,verify)
      cmd="atuin__account__verify"
      ;;
    atuin__account__help,change-password)
      cmd="atuin__account__help__change__password"
      ;;
    atuin__account__help,delete)
      cmd="atuin__account__help__delete"
      ;;
    atuin__account__help,help)
      cmd="atuin__account__help__help"
      ;;
    atuin__account__help,login)
      cmd="atuin__account__help__login"
      ;;
    atuin__account__help,logout)
      cmd="atuin__account__help__logout"
      ;;
    atuin__account__help,register)
      cmd="atuin__account__help__register"
      ;;
    atuin__account__help,verify)
      cmd="atuin__account__help__verify"
      ;;
    atuin__dotfiles,alias)
      cmd="atuin__dotfiles__alias"
      ;;
    atuin__dotfiles,help)
      cmd="atuin__dotfiles__help"
      ;;
    atuin__dotfiles,var)
      cmd="atuin__dotfiles__var"
      ;;
    atuin__dotfiles__alias,clear)
      cmd="atuin__dotfiles__alias__clear"
      ;;
    atuin__dotfiles__alias,delete)
      cmd="atuin__dotfiles__alias__delete"
      ;;
    atuin__dotfiles__alias,help)
      cmd="atuin__dotfiles__alias__help"
      ;;
    atuin__dotfiles__alias,list)
      cmd="atuin__dotfiles__alias__list"
      ;;
    atuin__dotfiles__alias,set)
      cmd="atuin__dotfiles__alias__set"
      ;;
    atuin__dotfiles__alias__help,clear)
      cmd="atuin__dotfiles__alias__help__clear"
      ;;
    atuin__dotfiles__alias__help,delete)
      cmd="atuin__dotfiles__alias__help__delete"
      ;;
    atuin__dotfiles__alias__help,help)
      cmd="atuin__dotfiles__alias__help__help"
      ;;
    atuin__dotfiles__alias__help,list)
      cmd="atuin__dotfiles__alias__help__list"
      ;;
    atuin__dotfiles__alias__help,set)
      cmd="atuin__dotfiles__alias__help__set"
      ;;
    atuin__dotfiles__help,alias)
      cmd="atuin__dotfiles__help__alias"
      ;;
    atuin__dotfiles__help,help)
      cmd="atuin__dotfiles__help__help"
      ;;
    atuin__dotfiles__help,var)
      cmd="atuin__dotfiles__help__var"
      ;;
    atuin__dotfiles__help__alias,clear)
      cmd="atuin__dotfiles__help__alias__clear"
      ;;
    atuin__dotfiles__help__alias,delete)
      cmd="atuin__dotfiles__help__alias__delete"
      ;;
    atuin__dotfiles__help__alias,list)
      cmd="atuin__dotfiles__help__alias__list"
      ;;
    atuin__dotfiles__help__alias,set)
      cmd="atuin__dotfiles__help__alias__set"
      ;;
    atuin__dotfiles__help__var,delete)
      cmd="atuin__dotfiles__help__var__delete"
      ;;
    atuin__dotfiles__help__var,list)
      cmd="atuin__dotfiles__help__var__list"
      ;;
    atuin__dotfiles__help__var,set)
      cmd="atuin__dotfiles__help__var__set"
      ;;
    atuin__dotfiles__var,delete)
      cmd="atuin__dotfiles__var__delete"
      ;;
    atuin__dotfiles__var,help)
      cmd="atuin__dotfiles__var__help"
      ;;
    atuin__dotfiles__var,list)
      cmd="atuin__dotfiles__var__list"
      ;;
    atuin__dotfiles__var,set)
      cmd="atuin__dotfiles__var__set"
      ;;
    atuin__dotfiles__var__help,delete)
      cmd="atuin__dotfiles__var__help__delete"
      ;;
    atuin__dotfiles__var__help,help)
      cmd="atuin__dotfiles__var__help__help"
      ;;
    atuin__dotfiles__var__help,list)
      cmd="atuin__dotfiles__var__help__list"
      ;;
    atuin__dotfiles__var__help,set)
      cmd="atuin__dotfiles__var__help__set"
      ;;
    atuin__help,account)
      cmd="atuin__help__account"
      ;;
    atuin__help,contributors)
      cmd="atuin__help__contributors"
      ;;
    atuin__help,daemon)
      cmd="atuin__help__daemon"
      ;;
    atuin__help,default-config)
      cmd="atuin__help__default__config"
      ;;
    atuin__help,doctor)
      cmd="atuin__help__doctor"
      ;;
    atuin__help,dotfiles)
      cmd="atuin__help__dotfiles"
      ;;
    atuin__help,gen-completions)
      cmd="atuin__help__gen__completions"
      ;;
    atuin__help,help)
      cmd="atuin__help__help"
      ;;
    atuin__help,history)
      cmd="atuin__help__history"
      ;;
    atuin__help,import)
      cmd="atuin__help__import"
      ;;
    atuin__help,info)
      cmd="atuin__help__info"
      ;;
    atuin__help,init)
      cmd="atuin__help__init"
      ;;
    atuin__help,key)
      cmd="atuin__help__key"
      ;;
    atuin__help,kv)
      cmd="atuin__help__kv"
      ;;
    atuin__help,login)
      cmd="atuin__help__login"
      ;;
    atuin__help,logout)
      cmd="atuin__help__logout"
      ;;
    atuin__help,register)
      cmd="atuin__help__register"
      ;;
    atuin__help,scripts)
      cmd="atuin__help__scripts"
      ;;
    atuin__help,search)
      cmd="atuin__help__search"
      ;;
    atuin__help,server)
      cmd="atuin__help__server"
      ;;
    atuin__help,stats)
      cmd="atuin__help__stats"
      ;;
    atuin__help,status)
      cmd="atuin__help__status"
      ;;
    atuin__help,store)
      cmd="atuin__help__store"
      ;;
    atuin__help,sync)
      cmd="atuin__help__sync"
      ;;
    atuin__help,uuid)
      cmd="atuin__help__uuid"
      ;;
    atuin__help,wrapped)
      cmd="atuin__help__wrapped"
      ;;
    atuin__help__account,change-password)
      cmd="atuin__help__account__change__password"
      ;;
    atuin__help__account,delete)
      cmd="atuin__help__account__delete"
      ;;
    atuin__help__account,login)
      cmd="atuin__help__account__login"
      ;;
    atuin__help__account,logout)
      cmd="atuin__help__account__logout"
      ;;
    atuin__help__account,register)
      cmd="atuin__help__account__register"
      ;;
    atuin__help__account,verify)
      cmd="atuin__help__account__verify"
      ;;
    atuin__help__dotfiles,alias)
      cmd="atuin__help__dotfiles__alias"
      ;;
    atuin__help__dotfiles,var)
      cmd="atuin__help__dotfiles__var"
      ;;
    atuin__help__dotfiles__alias,clear)
      cmd="atuin__help__dotfiles__alias__clear"
      ;;
    atuin__help__dotfiles__alias,delete)
      cmd="atuin__help__dotfiles__alias__delete"
      ;;
    atuin__help__dotfiles__alias,list)
      cmd="atuin__help__dotfiles__alias__list"
      ;;
    atuin__help__dotfiles__alias,set)
      cmd="atuin__help__dotfiles__alias__set"
      ;;
    atuin__help__dotfiles__var,delete)
      cmd="atuin__help__dotfiles__var__delete"
      ;;
    atuin__help__dotfiles__var,list)
      cmd="atuin__help__dotfiles__var__list"
      ;;
    atuin__help__dotfiles__var,set)
      cmd="atuin__help__dotfiles__var__set"
      ;;
    atuin__help__history,dedup)
      cmd="atuin__help__history__dedup"
      ;;
    atuin__help__history,end)
      cmd="atuin__help__history__end"
      ;;
    atuin__help__history,init-store)
      cmd="atuin__help__history__init__store"
      ;;
    atuin__help__history,last)
      cmd="atuin__help__history__last"
      ;;
    atuin__help__history,list)
      cmd="atuin__help__history__list"
      ;;
    atuin__help__history,prune)
      cmd="atuin__help__history__prune"
      ;;
    atuin__help__history,start)
      cmd="atuin__help__history__start"
      ;;
    atuin__help__import,auto)
      cmd="atuin__help__import__auto"
      ;;
    atuin__help__import,bash)
      cmd="atuin__help__import__bash"
      ;;
    atuin__help__import,fish)
      cmd="atuin__help__import__fish"
      ;;
    atuin__help__import,nu)
      cmd="atuin__help__import__nu"
      ;;
    atuin__help__import,nu-hist-db)
      cmd="atuin__help__import__nu__hist__db"
      ;;
    atuin__help__import,replxx)
      cmd="atuin__help__import__replxx"
      ;;
    atuin__help__import,resh)
      cmd="atuin__help__import__resh"
      ;;
    atuin__help__import,xonsh)
      cmd="atuin__help__import__xonsh"
      ;;
    atuin__help__import,xonsh-sqlite)
      cmd="atuin__help__import__xonsh__sqlite"
      ;;
    atuin__help__import,zsh)
      cmd="atuin__help__import__zsh"
      ;;
    atuin__help__import,zsh-hist-db)
      cmd="atuin__help__import__zsh__hist__db"
      ;;
    atuin__help__kv,delete)
      cmd="atuin__help__kv__delete"
      ;;
    atuin__help__kv,get)
      cmd="atuin__help__kv__get"
      ;;
    atuin__help__kv,list)
      cmd="atuin__help__kv__list"
      ;;
    atuin__help__kv,rebuild)
      cmd="atuin__help__kv__rebuild"
      ;;
    atuin__help__kv,set)
      cmd="atuin__help__kv__set"
      ;;
    atuin__help__scripts,delete)
      cmd="atuin__help__scripts__delete"
      ;;
    atuin__help__scripts,edit)
      cmd="atuin__help__scripts__edit"
      ;;
    atuin__help__scripts,get)
      cmd="atuin__help__scripts__get"
      ;;
    atuin__help__scripts,list)
      cmd="atuin__help__scripts__list"
      ;;
    atuin__help__scripts,new)
      cmd="atuin__help__scripts__new"
      ;;
    atuin__help__scripts,run)
      cmd="atuin__help__scripts__run"
      ;;
    atuin__help__server,default-config)
      cmd="atuin__help__server__default__config"
      ;;
    atuin__help__server,start)
      cmd="atuin__help__server__start"
      ;;
    atuin__help__store,pull)
      cmd="atuin__help__store__pull"
      ;;
    atuin__help__store,purge)
      cmd="atuin__help__store__purge"
      ;;
    atuin__help__store,push)
      cmd="atuin__help__store__push"
      ;;
    atuin__help__store,rebuild)
      cmd="atuin__help__store__rebuild"
      ;;
    atuin__help__store,rekey)
      cmd="atuin__help__store__rekey"
      ;;
    atuin__help__store,status)
      cmd="atuin__help__store__status"
      ;;
    atuin__help__store,verify)
      cmd="atuin__help__store__verify"
      ;;
    atuin__history,dedup)
      cmd="atuin__history__dedup"
      ;;
    atuin__history,end)
      cmd="atuin__history__end"
      ;;
    atuin__history,help)
      cmd="atuin__history__help"
      ;;
    atuin__history,init-store)
      cmd="atuin__history__init__store"
      ;;
    atuin__history,last)
      cmd="atuin__history__last"
      ;;
    atuin__history,list)
      cmd="atuin__history__list"
      ;;
    atuin__history,prune)
      cmd="atuin__history__prune"
      ;;
    atuin__history,start)
      cmd="atuin__history__start"
      ;;
    atuin__history__help,dedup)
      cmd="atuin__history__help__dedup"
      ;;
    atuin__history__help,end)
      cmd="atuin__history__help__end"
      ;;
    atuin__history__help,help)
      cmd="atuin__history__help__help"
      ;;
    atuin__history__help,init-store)
      cmd="atuin__history__help__init__store"
      ;;
    atuin__history__help,last)
      cmd="atuin__history__help__last"
      ;;
    atuin__history__help,list)
      cmd="atuin__history__help__list"
      ;;
    atuin__history__help,prune)
      cmd="atuin__history__help__prune"
      ;;
    atuin__history__help,start)
      cmd="atuin__history__help__start"
      ;;
    atuin__import,auto)
      cmd="atuin__import__auto"
      ;;
    atuin__import,bash)
      cmd="atuin__import__bash"
      ;;
    atuin__import,fish)
      cmd="atuin__import__fish"
      ;;
    atuin__import,help)
      cmd="atuin__import__help"
      ;;
    atuin__import,nu)
      cmd="atuin__import__nu"
      ;;
    atuin__import,nu-hist-db)
      cmd="atuin__import__nu__hist__db"
      ;;
    atuin__import,replxx)
      cmd="atuin__import__replxx"
      ;;
    atuin__import,resh)
      cmd="atuin__import__resh"
      ;;
    atuin__import,xonsh)
      cmd="atuin__import__xonsh"
      ;;
    atuin__import,xonsh-sqlite)
      cmd="atuin__import__xonsh__sqlite"
      ;;
    atuin__import,zsh)
      cmd="atuin__import__zsh"
      ;;
    atuin__import,zsh-hist-db)
      cmd="atuin__import__zsh__hist__db"
      ;;
    atuin__import__help,auto)
      cmd="atuin__import__help__auto"
      ;;
    atuin__import__help,bash)
      cmd="atuin__import__help__bash"
      ;;
    atuin__import__help,fish)
      cmd="atuin__import__help__fish"
      ;;
    atuin__import__help,help)
      cmd="atuin__import__help__help"
      ;;
    atuin__import__help,nu)
      cmd="atuin__import__help__nu"
      ;;
    atuin__import__help,nu-hist-db)
      cmd="atuin__import__help__nu__hist__db"
      ;;
    atuin__import__help,replxx)
      cmd="atuin__import__help__replxx"
      ;;
    atuin__import__help,resh)
      cmd="atuin__import__help__resh"
      ;;
    atuin__import__help,xonsh)
      cmd="atuin__import__help__xonsh"
      ;;
    atuin__import__help,xonsh-sqlite)
      cmd="atuin__import__help__xonsh__sqlite"
      ;;
    atuin__import__help,zsh)
      cmd="atuin__import__help__zsh"
      ;;
    atuin__import__help,zsh-hist-db)
      cmd="atuin__import__help__zsh__hist__db"
      ;;
    atuin__kv,delete)
      cmd="atuin__kv__delete"
      ;;
    atuin__kv,get)
      cmd="atuin__kv__get"
      ;;
    atuin__kv,help)
      cmd="atuin__kv__help"
      ;;
    atuin__kv,list)
      cmd="atuin__kv__list"
      ;;
    atuin__kv,rebuild)
      cmd="atuin__kv__rebuild"
      ;;
    atuin__kv,set)
      cmd="atuin__kv__set"
      ;;
    atuin__kv__help,delete)
      cmd="atuin__kv__help__delete"
      ;;
    atuin__kv__help,get)
      cmd="atuin__kv__help__get"
      ;;
    atuin__kv__help,help)
      cmd="atuin__kv__help__help"
      ;;
    atuin__kv__help,list)
      cmd="atuin__kv__help__list"
      ;;
    atuin__kv__help,rebuild)
      cmd="atuin__kv__help__rebuild"
      ;;
    atuin__kv__help,set)
      cmd="atuin__kv__help__set"
      ;;
    atuin__scripts,delete)
      cmd="atuin__scripts__delete"
      ;;
    atuin__scripts,edit)
      cmd="atuin__scripts__edit"
      ;;
    atuin__scripts,get)
      cmd="atuin__scripts__get"
      ;;
    atuin__scripts,help)
      cmd="atuin__scripts__help"
      ;;
    atuin__scripts,list)
      cmd="atuin__scripts__list"
      ;;
    atuin__scripts,new)
      cmd="atuin__scripts__new"
      ;;
    atuin__scripts,run)
      cmd="atuin__scripts__run"
      ;;
    atuin__scripts__help,delete)
      cmd="atuin__scripts__help__delete"
      ;;
    atuin__scripts__help,edit)
      cmd="atuin__scripts__help__edit"
      ;;
    atuin__scripts__help,get)
      cmd="atuin__scripts__help__get"
      ;;
    atuin__scripts__help,help)
      cmd="atuin__scripts__help__help"
      ;;
    atuin__scripts__help,list)
      cmd="atuin__scripts__help__list"
      ;;
    atuin__scripts__help,new)
      cmd="atuin__scripts__help__new"
      ;;
    atuin__scripts__help,run)
      cmd="atuin__scripts__help__run"
      ;;
    atuin__server,default-config)
      cmd="atuin__server__default__config"
      ;;
    atuin__server,help)
      cmd="atuin__server__help"
      ;;
    atuin__server,start)
      cmd="atuin__server__start"
      ;;
    atuin__server__help,default-config)
      cmd="atuin__server__help__default__config"
      ;;
    atuin__server__help,help)
      cmd="atuin__server__help__help"
      ;;
    atuin__server__help,start)
      cmd="atuin__server__help__start"
      ;;
    atuin__store,help)
      cmd="atuin__store__help"
      ;;
    atuin__store,pull)
      cmd="atuin__store__pull"
      ;;
    atuin__store,purge)
      cmd="atuin__store__purge"
      ;;
    atuin__store,push)
      cmd="atuin__store__push"
      ;;
    atuin__store,rebuild)
      cmd="atuin__store__rebuild"
      ;;
    atuin__store,rekey)
      cmd="atuin__store__rekey"
      ;;
    atuin__store,status)
      cmd="atuin__store__status"
      ;;
    atuin__store,verify)
      cmd="atuin__store__verify"
      ;;
    atuin__store__help,help)
      cmd="atuin__store__help__help"
      ;;
    atuin__store__help,pull)
      cmd="atuin__store__help__pull"
      ;;
    atuin__store__help,purge)
      cmd="atuin__store__help__purge"
      ;;
    atuin__store__help,push)
      cmd="atuin__store__help__push"
      ;;
    atuin__store__help,rebuild)
      cmd="atuin__store__help__rebuild"
      ;;
    atuin__store__help,rekey)
      cmd="atuin__store__help__rekey"
      ;;
    atuin__store__help,status)
      cmd="atuin__store__help__status"
      ;;
    atuin__store__help,verify)
      cmd="atuin__store__help__verify"
      ;;
    *) ;;
    esac
  done

  case "${cmd}" in
  atuin)
    opts="-h -V --help --version history import stats search sync login logout register key status account kv store dotfiles scripts init info doctor wrapped daemon default-config server uuid contributors gen-completions help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account)
    opts="-h --help login register logout delete change-password verify help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__change__password)
    opts="-c -n -h --current-password --new-password --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --current-password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --new-password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__delete)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help)
    opts="login register logout delete change-password verify help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__change__password)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__login)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__logout)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__register)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__help__verify)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__login)
    opts="-u -p -k -h --username --password --key --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --username)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -u)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --key)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -k)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__logout)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__register)
    opts="-u -p -e -h --username --password --email --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --username)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -u)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --email)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -e)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__account__verify)
    opts="-t -h --token --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --token)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__contributors)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__daemon)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__default__config)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__doctor)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles)
    opts="-h --help alias var help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias)
    opts="-h --help set delete list clear help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__clear)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__delete)
    opts="-h --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help)
    opts="set delete list clear help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help__clear)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__help__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__list)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__alias__set)
    opts="-h --help <NAME> <VALUE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help)
    opts="alias var help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__alias)
    opts="set delete list clear"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__alias__clear)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__alias__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__alias__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__alias__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__var)
    opts="set delete list"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__var__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__var__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__help__var__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var)
    opts="-h --help set delete list help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__delete)
    opts="-h --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__help)
    opts="set delete list help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__help__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__help__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__help__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__list)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__dotfiles__var__set)
    opts="-n -h --no-export --help <NAME> <VALUE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__gen__completions)
    opts="-s -o -h --shell --out-dir --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --shell)
      COMPREPLY=($(compgen -W "bash elvish fish nushell powershell zsh" -- "${cur}"))
      return 0
      ;;
    -s)
      COMPREPLY=($(compgen -W "bash elvish fish nushell powershell zsh" -- "${cur}"))
      return 0
      ;;
    --out-dir)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -o)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help)
    opts="history import stats search sync login logout register key status account kv store dotfiles scripts init info doctor wrapped daemon default-config server uuid contributors gen-completions help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account)
    opts="login register logout delete change-password verify"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__change__password)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__login)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__logout)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__register)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__account__verify)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__contributors)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__daemon)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__default__config)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__doctor)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles)
    opts="alias var"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__alias)
    opts="set delete list clear"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__alias__clear)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__alias__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__alias__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__alias__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__var)
    opts="set delete list"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__var__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__var__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__dotfiles__var__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 5 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__gen__completions)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history)
    opts="start end list last init-store prune dedup"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__dedup)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__end)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__init__store)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__last)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__prune)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__history__start)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import)
    opts="auto zsh zsh-hist-db bash replxx resh fish nu nu-hist-db xonsh xonsh-sqlite"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__auto)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__bash)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__fish)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__nu)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__nu__hist__db)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__replxx)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__resh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__xonsh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__xonsh__sqlite)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__zsh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__import__zsh__hist__db)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__info)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__init)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__key)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv)
    opts="set delete get list rebuild"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv__get)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv__rebuild)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__kv__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__login)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__logout)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__register)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts)
    opts="new run list get edit delete"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__edit)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__get)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__new)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__scripts__run)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__search)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__server)
    opts="start default-config"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__server__default__config)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__server__start)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__stats)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__status)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store)
    opts="status rebuild rekey purge verify push pull"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__pull)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__purge)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__push)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__rebuild)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__rekey)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__status)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__store__verify)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__sync)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__uuid)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__help__wrapped)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history)
    opts="-h --help start end list last init-store prune dedup help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__dedup)
    opts="-n -b -h --dry-run --before --dupkeep --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --before)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -b)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --dupkeep)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__end)
    opts="-e -d -h --exit --duration --help <ID>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --exit)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -e)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --duration)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help)
    opts="start end list last init-store prune dedup help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__dedup)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__end)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__init__store)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__last)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__prune)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__help__start)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__init__store)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__last)
    opts="-f -h --human --cmd-only --tz --timezone --format --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --timezone)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --tz)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --format)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -f)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__list)
    opts="-c -s -r -f -h --cwd --session --human --cmd-only --print0 --reverse --tz --timezone --format --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --reverse)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    -r)
      COMPREPLY=($(compgen -W "true false" -- "${cur}"))
      return 0
      ;;
    --timezone)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --tz)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --format)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -f)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__prune)
    opts="-n -h --dry-run --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__history__start)
    opts="-h --help [COMMAND]..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import)
    opts="-h --help auto zsh zsh-hist-db bash replxx resh fish nu nu-hist-db xonsh xonsh-sqlite help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__auto)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__bash)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__fish)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help)
    opts="auto zsh zsh-hist-db bash replxx resh fish nu nu-hist-db xonsh xonsh-sqlite help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__auto)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__bash)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__fish)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__nu)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__nu__hist__db)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__replxx)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__resh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__xonsh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__xonsh__sqlite)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__zsh)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__help__zsh__hist__db)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__nu)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__nu__hist__db)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__replxx)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__resh)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__xonsh)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__xonsh__sqlite)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__zsh)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__import__zsh__hist__db)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__info)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__init)
    opts="-h --disable-ctrl-r --disable-up-arrow --help zsh bash fish nu xonsh"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__key)
    opts="-h --base64 --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv)
    opts="-h --help set delete get list rebuild help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__delete)
    opts="-n -h --namespace --help <KEYS>..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --namespace)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__get)
    opts="-n -h --namespace --help <KEY>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --namespace)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help)
    opts="set delete get list rebuild help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__get)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__rebuild)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__help__set)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__list)
    opts="-n -a -h --namespace --all-namespaces --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --namespace)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__rebuild)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__kv__set)
    opts="-k -n -h --key --namespace --help <VALUE>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --key)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -k)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --namespace)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__login)
    opts="-u -p -k -h --username --password --key --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --username)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -u)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --key)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -k)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__logout)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__register)
    opts="-u -p -e -h --username --password --email --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --username)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -u)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --password)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --email)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -e)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts)
    opts="-h --help new run list get edit delete help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__delete)
    opts="-f -h --force --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__edit)
    opts="-d -t -s -h --description --tags --no-tags --rename --shebang --script --no-edit --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --description)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --tags)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --rename)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --shebang)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -s)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --script)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__get)
    opts="-s -h --script --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help)
    opts="new run list get edit delete help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__delete)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__edit)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__get)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__list)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__new)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__help__run)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__list)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__new)
    opts="-d -t -s -h --description --tags --shebang --script --last --no-edit --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --description)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -d)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --tags)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --shebang)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -s)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --script)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --last)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__scripts__run)
    opts="-v -h --var --help <NAME>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --var)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -v)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__search)
    opts="-c -e -b -i -r -f -h --cwd --exclude-cwd --exit --exclude-exit --before --after --limit --offset --interactive --filter-mode --search-mode --shell-up-key-binding --keymap-mode --human --cmd-only --print0 --delete --delete-it-all --reverse --tz --timezone --format --inline-height --include-duplicates --help [QUERY]..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --exclude-cwd)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --exit)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -e)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --exclude-exit)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --before)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -b)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --after)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --limit)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --offset)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --filter-mode)
      COMPREPLY=($(compgen -W "global host session directory workspace" -- "${cur}"))
      return 0
      ;;
    --search-mode)
      COMPREPLY=($(compgen -W "prefix full-text fuzzy skim" -- "${cur}"))
      return 0
      ;;
    --keymap-mode)
      COMPREPLY=($(compgen -W "emacs vim-normal vim-insert auto" -- "${cur}"))
      return 0
      ;;
    --timezone)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --tz)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --format)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -f)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --inline-height)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server)
    opts="-h --help start default-config help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__default__config)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__help)
    opts="start default-config help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__help__default__config)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__help__start)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__server__start)
    opts="-p -h --host --port --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --host)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --port)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -p)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__stats)
    opts="-c -n -h --count --ngram-size --help [PERIOD]..."
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --count)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -c)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --ngram-size)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -n)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__status)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store)
    opts="-h --help status rebuild rekey purge verify push pull help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help)
    opts="status rebuild rekey purge verify push pull help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__help)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__pull)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__purge)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__push)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__rebuild)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__rekey)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__status)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__help__verify)
    opts=""
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 4 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__pull)
    opts="-t -h --tag --force --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --tag)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__purge)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__push)
    opts="-t -h --tag --host --force --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    --tag)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    -t)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    --host)
      COMPREPLY=($(compgen -f "${cur}"))
      return 0
      ;;
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__rebuild)
    opts="-h --help <TAG>"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__rekey)
    opts="-h --help [KEY]"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__status)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__store__verify)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__sync)
    opts="-f -h --force --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__uuid)
    opts="-h --help"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  atuin__wrapped)
    opts="-h --help [YEAR]"
    if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]]; then
      COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
      return 0
    fi
    case "${prev}" in
    *)
      COMPREPLY=()
      ;;
    esac
    COMPREPLY=($(compgen -W "${opts}" -- "${cur}"))
    return 0
    ;;
  esac
}

if [[ "${BASH_VERSINFO[0]}" -eq 4 && "${BASH_VERSINFO[1]}" -ge 4 || "${BASH_VERSINFO[0]}" -gt 4 ]]; then
  complete -F _atuin -o nosort -o bashdefault -o default atuin
else
  complete -F _atuin -o bashdefault -o default atuin
fi

###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
