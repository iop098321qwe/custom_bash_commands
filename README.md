# Custom Bash Commands Instructions

## Follow the instructions below to add to path.

* [Best Option (Linux)](https://medium.com/devnetwork/how-to-create-your-own-custom-terminal-commands-c5008782a78e)
* [More Info](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom)
* [Even More Info](https://betterprogramming.pub/create-custom-terminal-commands-or-shortcuts-alias-8cc8b2c3f45b)

### Current configuration:

* Set up `.bashrc` in the <user> directory (with hidden files) with the `source ~/.custom_bash_commands.sh` appended to the end.
    * To open the `.bashrc` file, use this command in the Terminal: `open .bashrc`
* Ensure the most up-to-date version of the github repository is added to the user file (with hidden files).
* Open a new terminal as this will not work without the `.bashrc` file being reloaded.
* You can also optionally run `source .bashrc` to refresh the `.bashrc` file. (or `source .bash_profile`).
* There is a .update_commands.sh script that will run at the start of every terminal open that will automatically update to the latest version of the custom_bash_commands.sh file and add it to the correct directory
* This is done by creating a temporary directory, then initializing and cloning the github repo in it, then copying the file to the correct location, then delete itself.
* This ensures that every time you run the terminal you have the latest version of the custom commands already installed.

#### Additional Alias options:

* Append `alias docs="cd ~/Documents && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias ...="cd ~ && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias back="cd .. && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias cdgh="cd ~/Documents/github_repositories && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias temp="cd ~/Documents/Temporary && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias cbc="cdgh && cd custom_bash_commands && ls"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias cbcc="cdgh && cd custom_bash_commands && ls && cc"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias myip="curl http://ipecho.net/plain; echo"` to the end of the `.bashrc` file in the <user> directory.
* Append `alias rma='rm -rf'` to the end of the `.bashrc` file in the <user> directory.
* Append `alias x='chmod +x'` to the end of the `.bashrc` file in the <user> directory.
    * This will make whichever file that follows the command executable.
    * Syntax: `x <filename>`
* Append `alias gits='git status'` to the end of the `.bashrc` file in the <user> directory.
    * This will get the status of the git repository you are in quickly.
* Append `alias editbash='code ~/.bashrc && source ~/.bashrc'` to the end of the `.bashrc` file in the <user> directory.
* Append `alias cls='clear && ls'` to the end of the `.bashrc` file in the <user> directory.
* Append `alias refresh='source ~/.bashrc'` to the end of the `.bashrc` file in the <user> directory.
* Append `alias c='clear'` to the end of the `.bashrc` file in the <user> directory.

#### Additional Function options:

##### Add to the end of the `.bashrc` file:
```bash
# Custom function to make directories and switch into it, and move into the deepest directory created.
function mkcd() {
  mkdir -p "$1" && cd "$1"
}
```
This will create a function to make a directory or directories and change into the deepest created directory.
###### Syntax `mkcd <directory1>/<directory2>` (Example: `mkcd project/project_notes`)

---

##### Add to the end of the `.bashrc` file: 
```bash
# Function to create a backup file of a file.
function bkup() {
  cp "$1" "${1}_$(date +%Y%m%d%H%M%S).bak"
}
```
This will create a backup file of the file chosen in the same directory.
###### Syntax: `bkup <filename>` (Example: `bkup testfile.odt`)

---

##### Add to the end of the `.bashrc` file:
```bash
# Function: up
# Description: This function allows you to move up in the directory hierarchy by a specified number of levels.
function up() {
  local times=$1  # The number of levels to move up in the directory structure.
  local up=""     # A string that will accumulate the "../" for each level up.

  while [ "$times" -gt 0 ]; do
    up="../$up"   # Append "../" to the 'up' string for each level.
    times=$((times - 1))  # Decrement the counter.
  done

  cd $up  # Change directory to the final path constructed.
  ls
}
```
This will move up the specified amount of directories.
###### Syntax: `up <number>` (Example: `up 2`)

---

##### Add to the end of the `.bashrc` file with `editbash` command:
```bash
# Function: findfile
# Description: Enhanced file search function with multiple options including case sensitivity,
#              file type, regular expression support, modification time, and interactive mode.
#              Outputs the locations of found files/directories and a command to change to the
#              directory containing the found file.

function findfile() {
  if [[ "$1" == "-h" ]]; then
    echo "Usage: findfile [options] [file_pattern]"
    echo "Options:"
    echo "  -i            Interactive mode. Prompts for parameters."
    echo "  -s            Perform a case-sensitive search."
    echo "  -t [type]     Search for a specific file type (e.g., f for file, d for directory)."
    echo "  -d [dir]      Specify the directory to search in."
    echo "  -m [days]     Search for files modified in the last 'days' days."
    echo "  -r [pattern]  Use regular expression for searching."
    echo "  -h            Display this help message."
    echo ""
    echo "Example: findfile -t f 'pattern'  Search for files matching 'pattern'."
    return 0
  fi

  local case_sensitive="-iname"
  local regex_mode=0
  local interactive_mode=0
  local file_pattern=""
  local file_type=""
  local search_dir="."
  local max_days=""
  local found=0

  # Process options
  while (( "$#" )); do
    case "$1" in
      -s)
        case_sensitive="-name"
        shift
        ;;
      -t)
        file_type="-type $2"
        shift 2
        ;;
      -d)
        search_dir="$2"
        shift 2
        ;;
      -m)
        max_days="-mtime -$2"
        shift 2
        ;;
      -r)
        regex_mode=1
        file_pattern="$2"
        shift 2
        ;;
      -i)
        interactive_mode=1
        shift
        ;;
      *)
        # If no flags, assume it's the file pattern in non-regex mode
        if [[ -z "$file_pattern" && $regex_mode -eq 0 ]]; then
          file_pattern="$1"
          shift
        else
          echo "Unknown option: $1"
          return 1
        fi
        ;;
    esac
  done

  # Interactive mode overrides other options
  if [ "$interactive_mode" -eq 1 ]; then
    read -p "Enter filename or pattern: " file_pattern
    read -p "Enter directory to search [.]: " search_dir
    search_dir=${search_dir:-.}
    read -p "Case sensitive? (y/n) [n]: " case_choice
    case_sensitive=$([ "$case_choice" = "y" ] && echo "-name" || echo "-iname")
    read -p "Enter file type (f for file, d for directory, etc.) [any]: " file_type
    file_type=$([ -n "$file_type" ] && echo "-type $file_type" || echo "")
    read -p "Enter max days since modification [any]: " max_days
    max_days=$([ -n "$max_days" ] && echo "-mtime -$max_days" || echo "")
  fi

  # Regular expression mode
  if [ "$regex_mode" -eq 1 ]; then
    while IFS= read -r line; do
      echo "$line"
      echo "cd $(dirname "$line") && ls"
      found=1
    done < <(find "$search_dir" -regextype posix-extended -regex "$file_pattern" $file_type $max_days 2>/dev/null)
  else
    if [[ -n "$file_pattern" ]]; then
      while IFS= read -r line; do
        echo "$line"
        echo "cd $(dirname "$line") && ls"
        found=1
      done < <(find "$search_dir" $case_sensitive "$file_pattern" $file_type $max_days 2>/dev/null)
    fi
  fi

  # Check if any file was found
  if [ $found -eq 0 ]; then
    echo "${file_pattern:-File} not found!!!"
  fi
}
```

---

##### Add to the end of the `.bashrc` file with `editbash` command:

```bash
# Define the custom command
update() {
  # Create the log directory if it doesn't exist
  mkdir -p ~/Documents/update_logs

  # Define the log file path
  log_file=~/Documents/update_logs/$(date +"%Y-%m-%d_%H-%M-%S").log

  # Run update commands with sudo, tee to output to terminal and append to log file
  command="sudo apt update"
  echo -e "\n================================================================================"
  echo "Running command: $command" | tee -a "$log_file"
  echo "================================================================================"
  eval "$command" | tee -a "$log_file"

  command="sudo apt upgrade -y"
  echo -e "\n================================================================================"
  echo "Running command: $command" | tee -a "$log_file"
  echo "================================================================================"
  eval "$command" | tee -a "$log_file"

  command="sudo apt autoremove -y"
  echo -e "\n================================================================================"
  echo "Running command: $command" | tee -a "$log_file"
  echo "================================================================================"
  eval "$command" | tee -a "$log_file"

  # Display the log file path
  echo -e "\nUpdate logs saved to: $log_file"

  # Display the command to navigate to the log file directory
  echo -e "\nTo navigate to the log file directory, use the following command:"
  echo -e "cd ~/Documents/update_logs"
}
```
* Function to automatically run multiple update commands with logging functionality.

---

##### Add `figlet -f future Welcome Back -F border` to the end of the `.bashrc` file with `editbash` command:

## Additional Plans:

* Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.
* ~~Add a command to automatically update/copy the most recent version of the file into the <user> directory.~~
* Add a smart function to automatically check if there were any updates before performing the automatic update of the .custom_bash_commands.sh script in the ~/ directory.
* Add descriptions for alias' and custom functions in the README.md file.
* Move all functions and alias' to the `custom_bash_commands.sh` script for easy transferral and one file to manage them all.
* Create a test workflow for testing the custom commands.
* Change the figlet command to prompt the user for a username on first run, then run the command when the custom_bash_commands.sh script is loaded.
* Create a function to change the figlet configuration.
* Consolidate the config files for optional items.
* Create `odt` command to create a .odt file and open it in the directory specified and prompt to name it
* Create `ods` command to create a .ods file and open it in the directory specified and prompt to name it
* Ensure that all custom commands have the "-h" help flag functionality.
* Create a command to toggle between the `master` and `test` branches for easy testing.

# To Test

* Change the `.bashrc` file to read `source ~/.test_update_commands.sh`
* Run the terminal and verify the testing works by opening the .custom_bash_commands.sh in the user directory.
* Change the `.bashrc` file to read `source ~/.update_commands.sh` if it is not working.

# Useful Commands to Remember:

* `neofetch`: graphically shows system information with a beautiful output and ASCII Art of the Desktop Environment installed on Linux.