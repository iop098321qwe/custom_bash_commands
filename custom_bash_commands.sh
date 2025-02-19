#!/usr/bin/env bash
VERSION="201.0.0"

###################################################################################################################################################################
# CUSTOM BASH COMMANDS
###################################################################################################################################################################

################################################################################################################################################################
# PRON MODULE
################################################################################################################################################################

# TODO: Find a way to make pron module work with the cbcs command to show help information.

################################################################################
# PHOPEN
################################################################################

phopen() {
  URL_PREFIX="https://www.pornhub.com/view_video.php?viewkey="
  OPTIND=1

  while getopts "h" opt; do
    case "$opt" in
    h)
      echo "Description: This function opens special .mp4 files in the browser using fzf and"
      echo "             a predefined URL prefix."
      echo "Usage: phopen [-h]"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: phopen"
      return 0
      ;;
    *)
      echo "Invalid option: -$OPTARG" >&2
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
        echo "No recognized browser open command found. Please open this URL manually:"
        echo "$url"
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
    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#dddddd" \
      "Description:
        Prompts the user for a search term, constructs a search URL, and opens it in the default browser."

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#aa55dd" \
      "Usage:
        phsearch [-h]"

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#ffcc00" \
      "Options:
          -h    Display this help message"

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#ff9900" \
      "Example:
        phsearch"
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
  search_term=$(gum input --placeholder "Enter search term...")

  # Exit if no input is given
  if [[ -z "$search_term" ]]; then
    gum style --foreground "#ff0000" "No search term entered. Exiting..."
    return 1
  fi

  # Replace spaces in the search term with '+' using parameter expansion
  formatted_term=${search_term// /+}

  # Construct the search URL
  search_url="https://www.pornhub.com/video/search?search=${formatted_term}"

  # Show the search URL before opening it
  gum style --foreground 10 "🔍 Searching for: $search_term"
  gum style --border normal --padding "1" --border-foreground 4 "URL: $search_url"

  # Ask for confirmation before opening
  if gum confirm "Open this search in your browser?"; then
    gum spin --spinner dot --title "Opening browser..." -- nohup xdg-open "$search_url" >/dev/null 2>&1 &
    gum style --foreground 2 "✅ Search opened successfully!"
  else
    gum style --foreground 9 "❌ Search canceled."
  fi
}

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
    cat <<EOF
Usage: pronlist [-h] [-l]

Options:
  -h    Show this help message and exit
  -l    Select and process a specific line from the selected .txt file

Description:
  Processes each URL in the selected .txt file and uses yt-dlp with the _configs.txt
  configuration file to generate a sanitized output file listing the downloaded titles.
EOF
  }

  # Function to check the presence of the configuration file
  check_config_file() {
    if [ ! -f "_configs.txt" ]; then
      echo "Error: _configs.txt not found in the current directory."
      return 1
    fi
  }

  # Function to display a selection menu for batch files using fzf
  select_batch_file() {
    local selected_file
    selected_file=$(find . -maxdepth 1 -name "*.txt" 2>/dev/null | fzf --prompt="Select a batch file: ")

    if [ -z "$selected_file" ]; then
      echo "Error: No file selected."
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
    read -p "File '$file' already exists. Overwrite? (y/N): " choice
    case "$choice" in
    [Yy]*)
      return 0 # User chose to overwrite
      ;;
    *)
      echo "Skipping existing file: $file"
      return 1 # User declined overwrite
      ;;
    esac
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
      echo "Error: No URL selected."
      return 1
    fi

    # Generate a sanitized filename based on the URL
    output_file="$(echo "$line" | sed -E 's|.*\.com||; s|[^a-zA-Z0-9]|_|g').txt"

    # Check if the output file exists and prompt for overwrite
    if [ -f "$output_file" ]; then
      prompt_overwrite "$output_file" || return 0
    fi

    echo " "
    echo "################################################################################"
    echo "Processing selected URL: $line"
    echo "################################################################################"
    echo " "

    # Execute yt-dlp and save the output to the file
    yt-dlp --cookies-from-browser brave -f b "$line" --print "%(title)s" | tee "$output_file"

    echo " "
    echo "Processing complete."
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

    echo " "
    echo "################################################################################"
    echo "Processing URL: $line"
    echo "################################################################################"
    echo " "

    # Execute yt-dlp and save the output to the file
    yt-dlp --cookies-from-browser brave -f b "$line" --print "%(title)s" | tee "$output_file"
  done <"$batch_file"

  echo " "
  echo "Processing complete."
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
  [[ -z "$file" ]] && echo "No file selected. Exiting..." && return 1

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
      echo "No .mp4 files found matching: '$line'"
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
  [[ -z "$file" ]] && echo "No file selected. Exiting..." && return 1

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
      echo "No .mp4 files found matching: '$line'"
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

# repeat
# Description: Function to repeat any given command a set number of times
# Usage: repeat <number>
# Options:
#   -h    Display this help message

# Example: repeat 4 echo "hello"

# Function to repeat a command any given number of times
repeat() {
  OPTIND=1        # Reset getopts index to handle multiple runs
  local delay=0   # Default delay is 0 seconds
  local verbose=0 # Default verbose mode is off
  local count     # Declare count as a local variable to limit its scope

  # Function to display help
  usage() {
    cat <<EOF
Usage: repeat [-h] count [-d delay] [-v] command [arguments...]

Options:
  -h            Display this help message and return
  -d delay      Delay in seconds between each repetition
  -v            Enable verbose mode for debugging and tracking runs

Arguments:
  count         The number of times to repeat the command
  command       The command(s) to be executed (use ';' to separate multiple commands)
  [arguments]   Optional arguments passed to the command(s)
EOF
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
        echo " "
        echo "Error: DELAY must be a non-negative integer."
        echo " "
        return 1
      fi
      ;;
    v)
      verbose=1
      ;;
    *)
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
    echo " "
    echo "Error: Missing count and command arguments."
    echo " "
    usage
    return 1
  fi

  count=$1 # Assign count within local scope
  shift

  # Ensure count is a valid positive integer
  if ! echo "$count" | grep -Eq '^[0-9]+$'; then
    echo " "
    echo "Error: COUNT must be a positive integer."
    echo " "
    usage
    return 1
  fi

  # Ensure a command is provided
  if [ "$#" -lt 1 ]; then
    echo " "
    echo "Error: No command provided."
    echo " "
    usage
    return 1
  fi

  # Combine remaining arguments as a single command string
  local cmd="$*"

  # Repeat the command COUNT times with optional delay
  for i in $(seq 1 "$count"); do
    if [ "$verbose" -eq 1 ]; then
      echo " "
      echo "Running iteration $i of $count: $cmd"
      echo " "
    fi
    eval "$cmd"
    if [ "$delay" -gt 0 ] && [ "$i" -lt "$count" ]; then
      if [ "$verbose" -eq 1 ]; then
        echo " "
        echo "Sleeping for $delay seconds..."
        echo " "
      fi
      sleep "$delay"
    fi
  done
}

################################################################################
# SMART_SORT
################################################################################

# smart_sort: A multifunctional interactive file sorting tool for the current directory.

# Description:
#   This function sorts files in the current directory based on different criteria.
#   Available sorting modes are:
#     - ext   : Sort by file extension.
#     - alpha : Sort by the first letter of the filename.
#     - time  : Sort by modification time (grouped by YYYY-MM).
#     - size  : Sort by file size into categories (small, medium, large).

# Usage:
#   smart_sort [-h] [-i] [-m mode]

# Options:
#   -h        Display this help message.
#   -i        Enable interactive mode for selection of sorting options.
#             When used alone, interactive mode will prompt for all options via fzf.
#             When combined with other flags, interactive mode is disabled.
#   -m mode   Specify sorting mode directly. Available modes:
#               ext   - Sort by file extension.
#               alpha - Sort by the first letter of the filename.
#               time  - Sort by modification time (YYYY-MM).
#               size  - Sort by file size (small, medium, large).

# Examples:
#   smart_sort -i             # Launch interactive mode to choose sorting method.
#   smart_sort -m ext         # Sort files by extension non-interactively.
#   smart_sort -i -m size     # Note: Interactive mode is disabled when combined with -m flag; runs non-interactively.

smart_sort() {
  # Local variables initialization
  local mode=""            # Sorting mode (ext, alpha, time, size)
  local interactive_mode=0 # Flag for interactive mode (0: off, 1: on)
  local extension=""       # Holds a specific extension if selected
  local first_letter=""    # Holds the first letter of filenames during sorting
  local file=""            # Temporary variable for file iteration

  # Reset getopts index for multiple calls
  OPTIND=1

  # Parse command-line options using getopts
  while getopts ":hm:i" opt; do
    case $opt in
    h)
      # Display help message
      cat <<'EOF'
Description: Multifunctional interactive file sorting tool for the current directory.
Usage: smart_sort [-h] [-i] [-m mode]
Options:
  -h        Display this help message.
  -i        Enable interactive mode for selection of sorting options.
            When used alone, interactive mode will prompt for all options via fzf.
            When combined with other flags, interactive mode is disabled.
  -m mode   Specify sorting mode directly. Available modes:
              ext   - Sort by file extension.
              alpha - Sort by the first letter of the filename.
              time  - Sort by modification time (YYYY-MM).
              size  - Sort by file size (small, medium, large).
Examples:
  smart_sort -i             # Launch interactive mode to choose sorting method.
  smart_sort -m ext         # Sort files by extension non-interactively.
  smart_sort -i -m size     # NOTE: Interactive mode is disabled when combined with -m flag; runs non-interactively.
EOF
      return 0
      ;;
    i)
      interactive_mode=1 # Set interactive mode flag
      ;;
    m)
      mode="$OPTARG" # Set the sorting mode
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      return 1
      ;;
    :)
      echo -e "Option -$OPTARG requires an argument you" "\033[031mSTUPID FUCK!\033[0m" >&2
      return 1
      ;;
    esac
  done

  # Remove processed options from the positional parameters
  shift $((OPTIND - 1))

  #####################################
  # Default Behavior: Sort by Extension
  #####################################
  if [ -z "$mode" ] && [ "$interactive_mode" -eq 0 ]; then
    mode="ext"
  fi

  #####################################
  # Process Interactive Mode Logic
  #####################################
  if [ "$interactive_mode" -eq 1 ]; then
    if [ -z "$mode" ]; then
      # If only -i flag is provided, enforce interactive selection.
      # Check if fzf is installed.
      if ! command -v fzf >/dev/null 2>&1; then
        echo "fzf is not installed. Please install fzf to use interactive mode."
        return 1
      fi
      # Interactive selection for sorting mode via fzf.
      mode=$(printf "ext\nalpha\ntime\nsize" | fzf --prompt="Select sorting mode: ")
      # If fzf returns an empty result, exit.
      if [ -z "$mode" ]; then
        echo "No sorting mode selected. Exiting..."
        return 1
      fi
    else
      # If -i flag is used along with -m flag, interactive mode is disabled.
      echo "Note: Interactive mode (-i) is ignored when combined with other flags. Running non-interactively with mode: $mode"
      interactive_mode=0
    fi
  fi

  # If mode is still empty in non-interactive mode, display error and exit.
  if [ -z "$mode" ]; then
    echo "No sorting mode provided. Use -m flag or -i for interactive selection."
    return 1
  fi

  #####################################
  # Confirmation prompt before executing sorting
  #####################################
  echo "You have selected the following options:"
  echo "  Sorting Mode    : $mode"
  if [ "$interactive_mode" -eq 1 ]; then
    echo "  Interactive Mode: Enabled"
  else
    echo "  Interactive Mode: Disabled"
  fi

  # Prompt for confirmation with a default of 'n' (cancel)
  read -r -p "Proceed with sorting? (y/N): " confirm
  confirm=${confirm:-n}
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo "Sorting operation canceled."
    return 0
  fi

  #####################################
  # Sorting Mode Functions
  #####################################

  # Function to sort by file extension.
  sort_by_extension() {
    # Interactive selection: choose to sort a specific extension or all extensions.
    local choice
    choice=$(printf "Select specific extension\nSort all by extension" | fzf --prompt="Choose option for extension sorting: ")
    if [[ "$choice" == "Select specific extension" ]]; then
      # List available file extensions interactively.
      # TODO: Set up multi select for extensions to allow selective sorting
      extension=$(find . -maxdepth 1 -type f | sed -n 's/.*\.\([^.]\+\)$/\1/p' | sort -u | fzf --no-multi --prompt="Select an extension: ")
      if [ -z "$extension" ]; then
        echo "No extension selected. Exiting..."
        return 1
      fi
      echo -e "\nSorting files with extension: .$extension"
      mkdir -p "$extension"
      for file in *."$extension"; do
        [ -f "$file" ] && mv "$file" "$extension"/ # Move each matching file
      done
      echo "Files with extension .$extension have been moved to directory: $extension"
    elif [[ "$choice" == "Sort all by extension" ]]; then
      local ext
      for ext in $(find . -maxdepth 1 -type f | sed -n 's/.*\.\([^.]\+\)$/\1/p' | sort -u); do
        mkdir -p "$ext"
        for file in *."$ext"; do
          [ -f "$file" ] && mv "$file" "$ext"/
        done
        echo "Files with extension .$ext have been moved to directory: $ext"
      done
    else
      echo "Invalid selection."
      return 1
    fi
  }

  # Function to sort files alphabetically by the first letter of the filename.
  sort_by_alpha() {
    echo "Sorting files alphabetically by the first letter..."
    for file in *; do
      if [ -f "$file" ]; then
        # Extract the first letter and convert it to lowercase.
        first_letter=$(echo "$file" | cut -c1 | tr '[:upper:]' '[:lower:]')
        mkdir -p "$first_letter"
        mv "$file" "$first_letter"/
      fi
    done
    echo "Files have been sorted into directories based on the first letter."
  }

  # TODO: Implement selecting the time format/grouping interactively, and default to the current implementation. (Using fzf)
  #
  # Function to sort files by modification time (grouped by year-month).
  sort_by_time() {
    echo "Sorting files by modification time (grouped as YYYY-MM)..."
    for file in *; do
      if [ -f "$file" ]; then
        # Retrieve the file's modification date in YYYY-MM format.
        local mod_date
        mod_date=$(date -r "$file" +"%Y-%m")
        mkdir -p "$mod_date"
        mv "$file" "$mod_date"/
      fi
    done
    echo "Files have been sorted into directories based on modification date."
  }

  # TODO: Implement selecting the size categories interactively, and defaulting to the current implementation. (Using fzf)
  #
  # Function to sort files by file size into categories:
  #   - small:  < 1MB
  #   - medium: 1MB to 10MB
  #   - large:  > 10MB
  sort_by_size() {
    echo "Sorting files by size into categories: small (<1MB), medium (1MB-10MB), large (>10MB)..."
    for file in *; do
      if [ -f "$file" ]; then
        # Get the file size in bytes.
        local size
        size=$(stat -c%s "$file")
        local category=""
        if [ "$size" -lt 1048576 ]; then
          category="small"
        elif [ "$size" -lt 10485760 ]; then
          category="medium"
        else
          category="large"
        fi
        mkdir -p "$category"
        mv "$file" "$category"/
      fi
    done
    echo "Files have been sorted into size categories: small, medium, and large."
  }

  #####################################
  # Main Logic: Execute Selected Sorting Mode
  #####################################
  case "$mode" in
  ext)
    sort_by_extension || return 1
    ;;
  alpha)
    sort_by_alpha || return 1
    ;;
  time)
    sort_by_time || return 1
    ;;
  size)
    sort_by_size || return 1
    ;;
  *)
    echo "Invalid sorting mode: $mode"
    return 1
    ;;
  esac

  echo "Sorting operation completed successfully."
  echo "There is no way to undo what you just did. Stay tuned for possible undo in the future."
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
    cat <<EOF
Description: Function to open a random .mp4 file in the current directory
Usage: random [-h]
Options:
  -h    Display this help message
EOF
  }

  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      show_help
      return 0
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      show_help
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Gather all .mp4 files in the current directory
  mp4_files=(./*.mp4)

  # Check if there are any mp4 files
  if [ ${#mp4_files[@]} -eq 0 ] || [ ! -e "${mp4_files[0]}" ]; then
    echo "No mp4 files found in the current directory."
    return 1
  fi

  # Select a random file from the list
  random_file=$(find . -maxdepth 1 -type f -name "*.mp4" | shuf -n 1)

  # Open the random file using the default application
  nohup xdg-open "$random_file" 2>/dev/null

  # Check if the file was opened successfully
  if [ $? -ne 0 ]; then
    echo "Failed to open the file: $random_file"
    return 1
  fi

  echo "Opened: $random_file"
}

# Place this entire function in your .bashrc or other shell configuration file.
# Then, reload your shell or source .bashrc to use it.

################################################################################
# WIKI
################################################################################

# wiki
# Description: Function to open the CBC wiki in the default browser
# Usage: wiki
# Options:
#   -h    Display this help message
#   -c    Copy the wiki URL to the clipboard
#   -C    Open the wiki to the CBC commands section
#   -A    Open the wiki to the CBC aliases section
#   -F    Open the wiki to the CBC functions section

# Example: wiki  ---Opens the CBC wiki in the default browser.

##########

# Function to open the CBC wiki in the default browser
wiki() {
  if [ "$1" = "-h" ]; then
    echo "Description: Function to open the CBC wiki in the default browser"
    echo "Usage: wiki"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -c    Copy the wiki URL to the clipboard"
    echo "  -C    Open the wiki to the CBC commands section"
    echo "  -A    Open the wiki to the CBC aliases section"
    echo "  -F    Open the wiki to the CBC functions section"
    return
  fi

  # Define the CBC wiki URL
  wiki_url="https://github.com/iop098321qwe/custom_bash_commands/wiki"

  # Check for options
  if [ "$1" = "-c" ]; then
    # Copy the wiki URL to the clipboard
    echo "$wiki_url" | xclip -selection clipboard
    echo "Wiki URL copied to clipboard."
  elif [ "$1" = "-C" ]; then
    # Open the wiki to the CBC commands section
    nohup xdg-open "$wiki_url#cbc-commands"
  elif [ "$1" = "-A" ]; then
    # Open the wiki to the CBC aliases section
    nohup xdg-open "$wiki_url#cbc-aliases"
  elif [ "$1" = "-F" ]; then
    # Open the wiki to the CBC functions section
    nohup xdg-open "$wiki_url#cbc-functions"
  else
    # Open the CBC wiki in the default browser
    hohup xdg-open "$wiki_url"
  fi
}

################################################################################
# CHANGES
################################################################################

# changes
# Description: Function to open the CBC changelog in the default browser
# Usage: changes
# Options:
#   -h    Display this help message
#   -c    Copy the changelog URL to the clipboard

# Example: changes  ---Opens the CBC changelog in the default browser.

##########

# Function to open the CBC wiki in the default browser
changes() {
  if [ "$1" = "-h" ]; then
    echo "Description: Function to open the CBC changelog in the default browser"
    echo "Usage: changes"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -c    Copy the changelog URL to the clipboard"
    return
  fi

  # Define the CBC wiki URL
  changelog_url="https://github.com/iop098321qwe/custom_bash_commands/blob/main/CHANGELOG.md"

  # Check for options
  if [ "$1" = "-c" ]; then
    # Copy the changelog URL to the clipboard
    echo "$changelog_url" | xclip -selection clipboard
    echo "Changelog URL copied to clipboard."
  else
    # Open the CBC wiki in the default browser
    nohup xdg-open "$changelog_url"
  fi
}

################################################################################
# DOTFILES
################################################################################

dotfiles() {
  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: Function to open the dotfiles repository in the default browser"
      echo "Usage: dotfiles"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: dotfiles"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
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

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: Function to set up directories (Temporary, GitHub Repositories, Grymm's Grimoires)"
      echo "Usage: setup_directories"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: setup_directories"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
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

################################################################################
# DISPLAY VERSION
################################################################################

display_version() {
  # Function to display usage
  usage() {
    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#dddddd" \
      "Description:
        This function displays the version number from the .custom_bash_commands file in the local repository."

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#aa55dd" \
      "Alias:
        dv"

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#ffcc00" \
      "Usage:
        display_version"

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#ff9900" \
      "Options:
          -h    Display this help message"

    gum style \
      --border double \
      --margin "1" \
      --padding "1" \
      --border-foreground "#ff6600" \
      "Example:
        display_version"
  }

  OPTIND=1

  while getopts "h" opt; do
    case "$opt" in
    h)
      usage
      return 0
      ;;
    *)
      gum style --foreground "#ff0000" "Invalid option: -$OPTARG"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Display version details in a fancy box
  gum style --border double --foreground "#00ff00" "Using Custom Bash Commands (by iop098321qwe)"
  gum style --foreground "#ffff00" "Version: $VERSION 🔹🔹 To see the changes in this version, use the 'changes' command."
  gum style \
    --foreground "#33ccff" \
    "Show available commands with 'cbcs [-h]' or by typing 'commands' ('comm' for shortcut).
      To stop using CBC, remove '.custom_bash_commands.sh' from your '.bashrc' file using 'editbash'.
      Use the 'wiki' command or visit: https://github.com/iop098321qwe/custom_bash_commands/wiki"
}

################################################################################
# CBCS
################################################################################

# Describe the cbcs function and its options and usage

# cbcs
# Description: This function allows you to display a list of all available custom commands in this script
# Usage: cbcs [-h]
# Options:
#   -h    Display this help message

# Example: cbcs  ---Displays a list of all available custom commands in this script.

##########

# Create a function to display a list of all available custom commands in this script
cbcs() {
  if [[ $1 == "-h" ]]; then
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
    echo "incon"
    echo "         Description: Initialize a local git repo, create/connect it to a GitHub repo, and set up files"
    echo "         Usage: incon [repo_name]"
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
    echo "mvfiles"
    echo "         Description: Move all files in a directory to subdirectories based on file type"
    echo "         Usage: mvfiles"
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
    echo "mvfiles"
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
    echo "incon"
    echo "iopen"
    echo "iopenexact"
    echo "io"
    echo "ioe"
    echo "la"
    echo "lar"
    echo "le"
    echo "lg"
    echo "ll"
    echo "llt"
    echo "ln"
    echo "ls"
    echo "lsd"
    echo "lsf"
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

################################################################################
# BACKUP
################################################################################

# Describe the backup function and its options and usage

# backup
# Description: This function allows you to create a backup file of a file.
# Usage: backup [file]
# Options:
#   -h    Display this help message

# Example: backup test.txt  ---Creates a backup file of test.txt.

##########

# Function to create a backup file of a file.
backup() {
  if [ "$1" = "-h" ]; then
    echo "Description: This function allows you to create a backup file of a file."
    echo "Usage: backup [file]"
    echo "Options:"
    echo "  -h    Display this help message"
    return
  fi
  local filename=$(basename "$1")                             # Get the base name of the file
  local timestamp=$(date +%Y.%m.%d.%H.%M.%S)                  # Get the current timestamp
  local backup_filename="${filename}_backup_${timestamp}.bak" # Create the backup file name

  cp "$1" "$backup_filename"
}

################################################################################
# UP
################################################################################

# Describe the up function and its options and usage

# up
# Description: This function allows you to move up in the directory hierarchy by a specified number of levels.
# Usage: up [number of levels]
# Options:
#   -h    Display this help message

# Example: up 2  ---Moves up 2 levels in the directory hierarchy.

##########

# Function to move up in the directory hierarchy by a specified number of levels.
up() {
  # Initialize flags with default values
  local clear_terminal=false
  local print_directory=false
  local quiet_mode=false
  local detailed_listing=false
  local times=1

  # Parse command-line arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h)
      # Display help message and return
      echo "Description: This function allows you to move up in the directory hierarchy by a specified number of levels."
      echo "Usage: up [options] [number of levels]"
      echo "Options:"
      echo "  -h    Display this help message"
      echo "  -a    Return to the home directory"
      echo "  -r    Go to the root directory"
      echo "  -c    Clear the terminal after moving"
      echo "  -p    Print the current directory after moving"
      echo "  -q    Suppress the ls output"
      echo "  -l    Use ls -l for a detailed listing after changing directories"
      return
      ;;
    -a)
      # Change to home directory
      cd ~ || {
        echo "Error: Failed to return to home directory."
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
        echo "Error: Failed to change to root directory."
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
      echo "Error: Invalid argument. Use -h for help."
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
    echo "Error: Failed to change directory."
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

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: A function to remove all configuration files associated with CBC"
      echo "Usage: remove_all_cbc_configs"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: remove_all_cbc_configs"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Use -h for help."
      return
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
# INCON - BOOKMARK
################################################################################

incon() {
  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: A function to initialize a local git repo, create/connect it to a GitHub repo, and set up files"
      echo "Usage: incon"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: incon"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Use -h for help."
      return
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Ensure the gh tool is installed.
  if ! command -v gh &>/dev/null; then
    echo "gh (GitHub CLI) not found. Please install it to proceed."
    return
  fi

  # Check if the current directory already contains a git repository
  if [ -d ".git" ]; then
    echo "This directory is already initialized as a git repository."
    return
  fi

  # 1. Initialize a new local Git repository
  function init_git() {
    git init
    touch .gitignore
    touch README.md
    repo_name=$(basename $(pwd) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    formatted_name=$(echo $repo_name | tr '_' ' ' | sed -e "s/\b\(.\)/\u\1/g")
    echo "# $formatted_name" >README.md
    echo "* Not started" >>README.md
  }

  # Call the init_git function
  init_git

  # 2. Create a new remote public repository on GitHub using the gh tool
  new_remote_repo() {
    gh repo create "$repo_name" || {
      echo "Repository creation failed. Exiting"
      return
    }
  }

  # Call the new_remote_repo function
  new_remote_repo

  # 3. Connect the local repository to the newly created remote repository on GitHub
  connect_to_remote() {
    git remote add origin "https://github.com/$(gh api user | jq -r '.login')/$repo_name.git"
  }

  # Call the connect_to_remote function
  connect_to_remote

  # 4. Add all files, commit, and push
  add_commit_push() {
    git add .
    git commit -m "Initial commit"
    git push -u origin main || {
      echo "Push to main failed. Exiting."
      return
    }
  }

  # Call the add_commit_push function
  add_commit_push

  echo "Local and remote repositories have successfully initialized."
}

################################################################################
# MKDIRS
################################################################################

mkdirs() {
  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: A function to create a directory then switch into it"
      echo "Usage: mkdirs [directory]"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: mkdirs test"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Use -h for help."
      return
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Check if the directory name is provided
  if [ -z "$1" ]; then
    echo "Error: Directory name is not provided."
    return 1
  else
    # Create the directory and switch into it
    mkdir -p "$1" && cd "$1" || return 1
  fi
}

################################################################################
# UPDATE
################################################################################

update() {
  OPTIND=1
  local reboot=false
  shutdown=false

  while getopts ":hrsl" opt; do
    case $opt in
    h)
      echo "Description: A function to update the system and reboot if desired"
      echo "Usage: update [option]"
      echo "Options:"
      echo "  -r        Reboot the system after updating"
      echo "  -s        Shutdown the system after updating"
      echo "  -h        Display this help message"
      echo "  -l        Display the log file path"
      echo " "
      echo "Example: update -r"
      return
      ;;
    r)
      # Reboot the system after updating
      echo "Rebooting after updates enabled."
      # reboot=true
      return
      ;;
    s)
      # Shutdown the system after updating
      echo "Shutting down the system..."
      # sudo shutdown now
      return
      ;;
    l)
      # Display the log file path
      # echo "Update logs saved to: ~/Documents/update_logs/$(date +"%Y-%m-%d_%H-%M-%S").log"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG. Use -h for help."
      return
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Create the log directory if it doesn't exist
  mkdir -p ~/Documents/update_logs

  # Define the log file path
  log_file=~/Documents/update_logs/$(date +"%Y-%m-%d_%H-%M-%S").log

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
    "sudo flatpak update -y"
    "sudo snap refresh"
    "pip install --upgrade yt-dlp"
    "check_install_mscorefonts"
  )

  # Function to run a command and log the output
  run_command() {
    local command="$1"
    echo -e "\n================================================================================"
    echo "Running command: $command" | tee -a "$log_file"
    echo "================================================================================"
    eval "$command" | tee -a "$log_file"
  }

  # Iterate through the list of commands and run them
  for command in "${commands[@]}"; do
    run_command "$command"
  done

  # Check if the '-r' flag is provided
  if [[ $1 == "-r" ]]; then
    # Prompt the user to confirm the reboot
    read -p "Are you sure you want to reboot the system? (y/n): " confirm
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
      # Reboot the system
      echo -e "\nRebooting the system..."
      sudo reboot
    else
      echo "Reboot canceled."
    fi
  fi

  # Check if the '-s' flag is provided
  if [[ $1 == "-s" ]]; then
    # Prompt the user to confirm the shutdown
    read -p "Are you sure you want to shutdown the system? (y/n): " confirm
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
      # Shutdown the system
      echo -e "\nShutting down the system..."
      sudo shutdown now
    else
      echo "Shutdown canceled."
    fi
  fi

  # Check if the '-l' flag is provided
  if [[ $1 == "-l" ]]; then
    # Display the log file path
    echo -e "\n--------------------------------------------------------------------------------"
    echo -e "\nUpdate logs saved to: $log_file"

    # Display the command to navigate to the log file directory
    echo -e "\nTo navigate to the log file directory, use the following command:"
    echo -e "cd ~/Documents/update_logs"
    echo -e "\n--------------------------------------------------------------------------------\n"

    # Prompt the user if they would like to open the log file
    read -p "Would you like to open the log directory? (y/n): " open_log

    # Check if the user wants to open the log directory
    if [[ $open_log == "y" || $open_log == "Y" ]]; then
      # Open the log file
      cd ~/Documents/update_logs/ && ls
    fi
    return
  fi
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
  while getopts ":hf:o:r" opt; do
    case ${opt} in
    h)
      echo "Description: Function to generate a PDF file from a man page"
      echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
      echo "Options:"
      echo "  -h           Display this help message"
      echo "  -f <file>    Specify a file with a list of commands"
      echo "  -o <dir>     Specify an output directory (default: ~/Documents/grymms_grimoires/command_manuals)"
      echo "  -r           Remove existing files in the output directory that are not listed in the specified file"
      echo " "
      echo "Example: makeman ls"
      echo "Example: makeman -f commands.txt -r"
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
      echo "Invalid option: -$OPTARG" >&2
      echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
      return 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  # Process remaining arguments as the command
  if [ -z "$file" ]; then
    if [ $# -eq 0 ]; then
      echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
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

  # Check for arguments
  while (("$#")); do
    case "$1" in
    -f | --flavor) # Option for specifying the regex flavor
      if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
        flavor=$2
        shift 2
      else
        echo "Error: Argument for $1 is missing" >&2
        return 1
      fi
      ;;
    -h | --help) # Help flag
      echo "Description: A function to display help for regular expressions"
      echo "Usage: regex_help [-f|--flavor <flavor>] [-h|--help]"
      echo "Options:"
      echo "  -f|--flavor <flavor>    Specify the regex flavor (e.g., POSIX-extended, POSIX-basic, PCRE)"
      echo "  -h|--help               Display this help message"
      echo "  --example(?)               Display an example of the regex flavor"
      echo " "
      echo "Example: regex_help -f PCRE"
      return 0
      ;;
    *) # Handle unexpected options
      echo "Error: Unsupported flag $1" >&2
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

  while getopts ":h" opt; do
    case ${opt} in
    h)
      echo "Description: A function to extract compressed files"
      echo "Usage: extract [file]"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: extract file.tar.gz"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [ -z "$1" ]; then
    echo "Error: No file specified"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: File not found"
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
  *) echo "'$1' cannot be extracted using extract()" ;;
  esac
}

################################################################################
# ODT
################################################################################

odt() {
  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: A function to create a .odt file in the current directory and open it"
      echo "Usage: odt [filename]"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: odt test"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
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

# Describe the ods function and its options and usage

# ods
# Description: A function to create a .ods file in the current directory and open it
# Usage: ods [filename]
# Options:
#   -h    Display this help message

# Example: ods test  ---Creates a .ods file called test and opens it in the current directory.

# Create ods command to create a .ods file in the current directory and open it
ods() {
  # Use getopts to handle Options
  OPTIND=1

  while getopts ":h" opt; do
    case $opt in
    h)
      echo "Description: A function to create a .ods file in the current directory and open it"
      echo "Usage: ods [filename]"
      echo "Options:"
      echo "  -h    Display this help message"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
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
filehash() {
  if [ "$1" = "-h" ]; then
    # Display help message if -h option is provided
    echo "Description: A function to generate a hash of a file"
    echo "Usage: filehash [file] [method]"
    echo "Options:"
    echo "  -h    Display this help message"
    echo "  -m    Display available hash methods"
    echo "  -a    Run all hash methods on the file"
    echo "  -d    Iterate through the current directory and run the specified hash method on each file"
    echo "  -da   Run all hash methods on all files in the current directory"
    return
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
  while getopts ":h" opt; do
    case ${opt} in
    h)
      echo "Description: A function to display information"
      echo "Usage: display_info"
      echo "Options:"
      echo "  -h    Display this help message"
      echo " "
      echo "Example: display_info"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      ;;
    esac
  done

  display_version
}

################################################################################
# UPDATECBC
################################################################################

# Create a function to update the custom bash commands script and display the version number

# updatecbc
# Description: A function to update the custom bash commands script and display the version number
# Usage: updatecbc
# Options:
#   -h    Display this help message

# Create a function to update the custom bash commands script and display the version number
updatecbc() {
  # Initialize OPTIND to 1 since it is a global variable within the script
  OPTIND=1

  # Parse options using getopts
  while getopts ":h" opt; do
    case ${opt} in
    h)
      echo "Description: A function to update the custom bash commands"
      echo "Usage: updatecbc"
      echo "Options:"
      echo "  -h    Display this help message"
      return
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
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

################################################################################
# MVFILES
################################################################################

# Create a function to move files to a directory based on file type

# mvfiles
# Description: A function to move all files in a directory to a subdirectory based on file type
# Usage: mvfiles
# Options:
#   -h    Display this help message

# Create a function to move files to a directory based on file type suffix and named with the suffix without a '.' prefix

mvfiles() {
  if [ "$1" = "-h" ]; then
    echo "Description: A function to move all files in a directory to a subdirectory based on file type"
    echo "Usage: mvfiles"
    echo "Options:"
    echo "  -h    Display this help message"
    return
  fi
  # Create an array of unique file extensions in the current directory
  extensions=($(find . -maxdepth 1 -type f | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]' | sort -u))

  # Create a subdirectory for each unique file extension
  for ext in "${extensions[@]}"; do
    # Create the subdirectory if it does not exist
    mkdir -p $ext

    # Move files with the extension to the subdirectory
    mv *.$ext $ext 2>/dev/null

    # Move files with upper case extension to the subdirectory
    mv *.$(echo $ext | tr '[:lower:]' '[:upper:]') $ext 2>/dev/null
  done
}

###################################################################################################################################################################

# Call the function to display information
display_info

###################################################################################################################################################################
# FIRST TIME SET UP
###################################################################################################################################################################

# If FIRST_TIME is set to true in the config file, display the welcome message and run cbcs -h
if [ "$FIRST_TIME" = "true" ]; then
  # Display the welcome message
  echo " "
  echo "Run cbcs [-h] with help flag to display descriptions and usage."
  echo " "
  # Run cbcs -h
  cbcs -h
fi

# Call the first time set up function
first_time_setup

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
# Ensure that ranger is installed, and if not install it.
###################################################################################################################################################################

# Function to check if ranger is installed and install it if necessary
check_install_ranger() {
  if ! command -v ranger &>/dev/null; then
    echo "ranger not found. Install with chezmoi"
  fi
}

###################################################################################################################################################################
# Ensure thefuck is installed, and if not install it.
###################################################################################################################################################################

# Function to check if thefuck is installed and install it if necessary
check_install_thefuck() {
  if ! command -v thefuck &>/dev/null; then
    echo "thefuck not found. Install using thefuck documentation as it is currently not updated"
  fi
}

###################################################################################################################################################################
# Ensure obsidian is installed, and if not install it.
###################################################################################################################################################################

# Function to check if obsidian is installed and install it if necessary
check_install_obsidian() {
  if ! command -v obsidian &>/dev/null; then
    echo "obsidian not found. Install with chezmoi."
  fi
}

###################################################################################################################################################################
# Ensure fzf is installed, and if not install it.
###################################################################################################################################################################

# Function to check if fzf is installed and install it if necessary
check_install_fzf() {
  if ! command -v fzf &>/dev/null; then
    echo "fzf not found. Install with chezmoi."
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
# Check if neovim is installed, and if it is, add it to PATH.
###################################################################################################################################################################

# Function to check if neovim is installed and add it to PATH
check_install_neovim() {
  if command -v nvim &>/dev/null; then
    export PATH="$PATH:/opt/nvim-linux64/bin"
    # If neovim is not installed, install it using "sudo apt install neovim"
  else
    echo "Neovim not found. Please install from https://github.com/neovim/neovim/releases"
    echo "Download the nvim.appimage file, use 'chmod +x nvim.appimage' to make it executable, and run 'sudo mv nvim.appimage /bin/nvim' to install."

    # Download the neovim appimage file
    wget https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage

    # Make the appimage file executable
    chmod +x nvim.appimage

    # Move the appimage file to /bin/nvim
    sudo mv nvim.appimage /bin/nvim
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

###################################################################################################################################################################
# Create a config file for installing additional software that may not already be installed where commented out software is not installed.
###################################################################################################################################################################

# Create a default config file to load information for installing additional software
# Check if the config file exists in the home directory, and if it does not, copy the default config file to the home directory

# Script to install software based on the configuration file

# If .cbcconfig directory does not exist in the home directory, create it
#if [ ! -d "$HOME/.cbcconfig" ]; then
#    mkdir "$HOME/.cbcconfig"
#fi

# set apt_conf to the path of apt_packages.conf in .cbcconfig directory
# apt_conf="$HOME/.cbcconfig/apt_packages.conf"

#Read the config file and install the software
#while IFS= read -r line; do
#    if [[ ! "$line" =~ ^#.*$ ]] && [[ -n "$line" ]]; then
#        echo "Installing $line..."
#        sudo apt install "$line"
#    fi
#done < "$apt_conf"

##################################################################################################################################################################
# Additional Software Installation
###################################################################################################################################################################

# Read the configuration file and check if NEOVIM=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${NEOVIM:=true}" == "true" ]]; then
    # Call the function to check neovim installation and install neovim
    check_install_neovim
  fi
fi

# Read the configuration file and check if OBSIDIAN=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${OBSIDIAN:=false}" == "true" ]]; then
    # Call the function to check obsidian installation and install obsidian
    check_install_obsidian
  fi
fi

# Read the configuration file and check if BAT=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${BAT:=false}" == "true" ]]; then
    # Call the function to check bat installation and install bat
    check_install_bat
  fi
fi

# Read the configuration file and check if RANGER=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${RANGER:=true}" == "true" ]]; then
    # Call the function to check ranger installation and install ranger
    check_install_ranger
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

# Read the configuration file and check if FZF=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${FZF:=false}" == "true" ]]; then
    # Call the function to check fzf installation and install fzf
    check_install_fzf
  fi
fi

# Check if zoxide is installed, and if it is, source the zoxide init script
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init --cmd cd bash)"
fi

# Read the configuration file and check if THEFUCK=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "$THEFUCK" = "true" ]]; then
    # Call the function to check thefuck installation and install thefuck
    check_install_thefuck
  fi
fi

# Read the configuration file and check if HSTR=true
if [[ -f "$CONFIG_FILE" ]]; then
  source "$CONFIG_FILE"
  if [[ "${HSTR:=true}" == "true" ]]; then
    # Call the function to check hstr installation and install hstr
    check_install_hstr
  fi
fi

###################################################################################################################################################################
###################################################################################################################################################################
# EXPORTS
###################################################################################################################################################################
###################################################################################################################################################################

# Remove history duplications
export HISTCONTROL=ignoredups:erasedups

# Set terminal behavior to mimic vim
set -o vi

# Set the default editor to neovim if and only if neovim is installed and set manpager as neovim
if command -v nvim &>/dev/null; then
  export EDITOR=nvim
  export MANPAGER="nvim +Man!"
fi

###################################################################################################################################################################
###################################################################################################################################################################
# ZELLIJ COMPLETION
###################################################################################################################################################################
###################################################################################################################################################################

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

# cht.sh autocomplete
_cht_complete() {
  local cur prev opts
  _get_comp_words_by_ref -n : cur

  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD - 1]}"
  opts="$(curl -s cheat.sh/:list)"

  if [ ${COMP_CWORD} = 1 ]; then
    COMPREPLY=($(compgen -W "${opts}" -- ${cur}))
    __ltrim_colon_completions "$cur"
  fi
  return 0
}
complete -F _cht_complete cht.sh
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
