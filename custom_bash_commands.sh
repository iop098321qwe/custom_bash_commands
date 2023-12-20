#!/bin/bash

###################################################################################################################################################################
# CUSTOM BASH COMMANDS
###################################################################################################################################################################

################################################################################
# DISPLAY VERSION
################################################################################

# Describe the display_version function and its options and usage

# display_version
# Description: This function allows you to display the version.txt file from the local repository
# Alias: dv
# Usage: display_version
# Options:
#   -h    Display this help message

# Example: display_version  ---Displays the version number from the .version file from the local repository.

##########

# Function to display the .version file from the local repository
display_version() {
    # Create an alias for the display_version function
    # alias dv="display_version"
    # Read the contents of the .version file and display it in the terminal
    version_number=$(cat ~/.version)
    echo -e "Now using \e[32mCustom Bash Commands\e[0m (by \e[35miop098321qwe\e[0m) \e[34mVersion:\e[0m \e[34m$version_number\e[0m"
    echo -e "You can show commands included with cbcs [-h]."
    echo -e "If you wish to stop using \e[32mCBC\e[0m, \e[31mremove\e[0m \e[33m.custom_bash_commands.sh\e[0m from your \e[33m.bashrc\e[0m file using \e[36meditbash\e[0m (\e[32mCBC\e[0m)."
}

# Create a file to store the display_version configuration
display_version_config_file=~/.display_version_config

# Check if the display_version configuration file exists and create it prompting the user for a username and font if it does not
if [ ! -f $display_version_config_file ]; then

    # Check if the enable_display_version variable does not exist in the display_version configuration file
    if ! grep -q "enable_display_version" $display_version_config_file; then
    
        # Prompt the user if they want to enable the welcome message
        while true; do
            read -p "Would you like to enable the display_version message? (y/n): " enable_display_version

            # Check if the user wants to enable the display_version message
            if [[ $enable_display_version == "y" || $enable_display_version == "Y" ]]; then
                enable_display_version="y"
                break
            elif [[ $enable_display_version == "n" || $enable_display_version == "N" ]]; then
                enable_display_version="n"
                break
            else
                echo "Invalid input. Please enter 'y' or 'n'."
            fi
        done

        # Store the enable_display_version variable in the display_version configuration file
        echo "enable_display_version=$enable_display_version" >> $display_version_config_file
    fi
fi

# Create a function to remove the configuration file and refresh the terminal
function remove_display_version_config() {
    # Alias for the remove_display_version_config function
    # alias rdvc="remove_display_version_config"
    # Prompt the user to confirm the removal of the display_version configuration file
    read -p "Are you sure you want to remove the display_version configuration file? (y/n): " confirm

    # Check if the user wants to remove the display_version configuration file
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        # Remove the display_version configuration file
        rm $display_version_config_file
        echo "Display version configuration file removed."
        echo "Refresh terminal to apply changes."
    else
        echo "Display version configuration file removal canceled."
    fi
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
        #echo "################################"
        #echo "## Available custom commands: ##"
        #echo "################################"
        figlet -f future -F border Available custom commands:
        echo " "
        echo "  display_version,   (alias: dv)"
        echo "         Description: Display the version number from the .version file"
        echo "         Usage: display_version   (alias: dv)"
        echo "  cbcs"
        echo "         Description: Display a list of all available custom commands in this script"
        echo "         Usage: cbcs [-h]"
        echo "  rma"
        echo "         Description: Remove all files from a directory and the directory"
        echo "         Usage: rma [directory]"
        echo "  editbash"
        echo "         Description: Open the .bashrc file in the default text editor"
        echo "         Usage: editbash"
        echo "  cls"
        echo "         Description: Clear the terminal screen and print the contents of the current directory"
        echo "         Usage: cls"
        echo "  refresh"
        echo "         Description: Refresh the terminal session"
        echo "         Usage: refresh"
        echo "  c"
        echo "         Description: Clear the terminal screen and display the version number from the .version file"
        echo "         Usage: c"
        echo "  gits"
        echo "         Description: Display the git status of the current directory"
        echo "         Usage: gits"
        echo "  x"
        echo "         Description: Make a file executable"
        echo "         Usage: x [file]"
        echo "  myip"
        echo "         Description: Display the IP address of the current machine"
        echo "         Usage: myip"
        echo "  findfile,   (alias: ff)"
        echo "         Description: Find a file in the current directory and its subdirectories"
        echo "         Usage: findfile [options] [file_pattern]"
        echo "             Options:"
        echo "                 -i            Interactive mode. Prompts for parameters."
        echo "                 -s            Perform a case-sensitive search."
        echo "                 -t [type]     Search for a specific file type (e.g., f for file, d for directory)."
        echo "                 -d [dir]      Specify the directory to search in."
        echo "                 -m [days]     Search for files modified in the last 'days' days."
        echo "                 -r [pattern]  Use regular expression for searching."
        echo "                 -h            Display this help message."
        echo "  mkcd"
        echo "         Description: Create a directory and switch into it"
        echo "         Usage: mkcd [directory]"
        echo "  bkup"
        echo "         Description: Create a backup file of a file"
        echo "         Usage: bkup [file]"
        echo "  up"
        echo "         Description: Move up one directory level"
        echo "         Usage: up [number of levels]"
        echo "  cc"
        echo "         Description: Combine the git add/commit and git push process"
        echo "         Usage: cc [message] (Enter the commit message in quotes)" 
        echo "  incon"
        echo "         Description: Initialize a local git repo, create/connect it to a GitHub repo, and set up files"
        echo "         Usage: incon [repo_name]"
        echo "  update"
        echo "         Description: Update the custom bash commands script"
        echo "         Usage: update [option]"
        echo "             Options:"
        echo "                 -r    Reboot the system after updating"
        echo "  remove_figlet_config,   (alias: rfc)"
        echo "         Description: Remove the figlet configuration file and refresh the terminal"
        echo "         Usage: remove_figlet_config,   (alias: rfc)"
        echo "  remove_neofetch_config,   (alias: rnc)"
        echo "         Description: Remove the neofetch configuration file and refresh the terminal"
        echo "         Usage: remove_neofetch_config,   (alias: rnc)"
        echo "  remove_session_id_config,   (alias: rsc)"
        echo "         Description: Remove the session ID configuration file and refresh the terminal"
        echo "         Usage: remove_session_id_config,   (alias: rsc)"
        echo "  remove_display_version_config,   (alias: rdvc)"
        echo "         Description: Remove the display version configuration file and refresh the terminal"
        echo "         Usage: remove_display_version_config,   (alias: rdvc)"
        echo "  remove_all_cbc_configs,   (alias: racc)"
        echo "         Description: Remove all configuration files associated with CBC"
        echo "         Usage: remove_all_cbc_configs,   (alias: racc)"
        echo "  odt"
        echo "         Description: Create a .odt file in the current directory and open it"
        echo "         Usage: odt [filename]"
        echo "  ods"
        echo "         Description: Create a .ods file in the current directory and open it"
        echo "         Usage: ods [filename]"
        echo " docs,   (alias: cd ~/Documents && ls)"
        echo "         Description: Change to the Documents directory and list its contents"
        echo "         Usage: docs,   (alias: cd ~/Documents && ls)"
        echo " home,   (alias: cd ~ && ls)"
        echo "         Description: Change to the home directory and list its contents"
        echo "         Usage: home,   (alias: cd ~ && ls)"
        echo " back,   (alias: cd .. && ls)"
        echo "         Description: Change to the parent directory and list its contents"
        echo "         Usage: back,   (alias: cd .. && ls)"
        echo " cdgh,   (alias: cd ~/Documents/github_repositories && ls)"
        echo "         Description: Change to the github_repositories directory and list its contents"
        echo "         Usage: cdgh,   (alias: cd ~/Documents/github_repositories && ls)"
        echo " temp,   (alias: cd ~/Documents/Temporary && ls)"
        echo "         Description: Change to the Temporary directory and list its contents"
        echo "         Usage: temp,   (alias: cd ~/Documents/Temporary && ls)"
        echo " cbc,   (alias: cdgh && cd custom_bash_commands && ls)"
        echo "         Description: Change to the custom_bash_commands directory and list its contents"
        echo "         Usage: cbc,   (alias: cdgh && cd custom_bash_commands && ls)"
        echo " cbcc,   (alias: cdgh && cd custom_bash_commands && ls && cc)"
        echo "         Description: Change to the custom_bash_commands directory, list its contents, and clear the clipboard contents"
        echo "         Usage: cbcc [message],   (alias: cdgh && cd custom_bash_commands && ls && cc) (Enter the commit message in quotes)"
    else
        # Display a list of all available custom commands and functions in this script
        echo " "
        echo "Available custom commands:"
        echo "##########################"
        echo " "
        echo "  display_version,   (alias: dv)"
        echo "  cbcs"
        echo "  rma"
        echo "  editbash"
        echo "  cls"
        echo "  refresh"
        echo "  c"
        echo "  gits"
        echo "  x"
        echo "  myip"
        echo "  findfile,   (alias: ff)"
        echo "  mkcd"
        echo "  bkup"
        echo "  up"
        echo "  cc"
        echo "  incon"
        echo "  update"
        echo "  remove_figlet_config,   (alias: rfc)"
        echo "  remove_neofetch_config,   (alias: rnc)"
        echo "  remove_session_id_config,   (alias: rsc)"
        echo "  remove_display_version_config,   (alias: rdvc)"
        echo "  remove_all_cbc_configs,   (alias: racc)"
        echo "  odt"
        echo "  ods"
        echo "  docs,   (alias: cd ~/Documents && ls)"
        echo "  home,   (alias: cd ~ && ls)"
        echo "  back,   (alias: cd .. && ls)"
        echo "  cdgh,   (alias: cd ~/Documents/github_repositories && ls)"
        echo "  temp,   (alias: cd ~/Documents/Temporary && ls)"
        echo "  cbc,   (alias: cdgh && cd custom_bash_commands && ls)"
        echo "  cbcc,   (alias: cdgh && cd custom_bash_commands && ls && cc)"
    fi
}

################################################################################
# MKCD
################################################################################

# Describe the mkcd function and its options and usage

# mkcd
# Description: This function allows you to create a directory and switch into it.
# Usage: mkcd [directory]
# Options:
#   -h    Display this help message

# Example: mkcd test  ---Creates a directory called test and switches into it.

##########

# Custom function to make directories and switch into it, and move into the deepest directory created.
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

################################################################################
# BKUP
################################################################################

# Describe the bkup function and its options and usage

# bkup
# Description: This function allows you to create a backup file of a file.
# Usage: bkup [file]
# Options:
#   -h    Display this help message

# Example: bkup test.txt  ---Creates a backup file of test.txt.

##########

# Function to create a backup file of a file.
function bkup() {
    local filename=$(basename "$1")  # Get the base name of the file
    local timestamp=$(date +%Y.%m.%d.%H.%M.%S)  # Get the current timestamp
    local backup_filename="${filename}_backup_${timestamp}.bak"  # Create the backup file name

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

################################################################################
# REMOVE ALL CBC CONFIGS
################################################################################

# Describe the rmac function and its options and usage

# rmac
# Description: This function allows you to remove all configuration files associated with CBC.
# Usage: rmac
# Options:
#   -h    Display this help message

# Example: rmac  ---Removes all configuration files associated with CBC.

# Create a function to call rfc, rnc, rsc, and rdvc
function remove_all_cbc_configs() {
    # Alias for the remove_all_cbc_configs function
    # alias remove_all_cbc_configs="racc"
    # Call the rfc, rnc, rsc, and rdvc functions
    rfc
    rnc
    rsc
    rdvc
}

################################################################################
# CC
################################################################################

# Describe the cc function and its options and usage

# cc
# Description: A function to combine the git add/commit process
# Usage: cc [message]
# Options:
#   -h    Display this help message

# Example: cc "Initial commit"  ---Adds all files, commits with the message "Initial commit", and pushes to the current branch.

##########

# Function to combine the git add/commit process
function cc() {
    # Check if a message was provided
    if [ $# -eq 0 ]; then
        echo "Commit message is not provided"
        return 1
    fi
    
    # Combine all arguments into a single commit message.
    message="$@"
    
    # If a message is provided, proceed with git operations
    currentBranch=$(git symbolic-ref --short -q HEAD)  # Getting the current branch
    
    echo " "
    echo "Current branch: $currentBranch"
    echo "Commit message: $message"
    echo " "
    echo "Current Time: $(date)"
    echo " "
    echo "available branches:"
    git branch
    echo " "
    echo "#####################################################"
    echo "## DID YOU SET THE .VERSION FILE NUMBER CORRECTLY? ##"
    echo "#####################################################"
    echo " "
    read -p "Do you want to continue pushing to the current branch? (y/n): " choice
    
    if [ "$choice" == "y" ]; then
        git add .
        git commit -m "$message"
        git push origin "$currentBranch"
    else
        echo "Push to the current branch canceled."
    fi
}

################################################################################
# INCON
################################################################################

# Describe the incon function and its options and usage

# incon
# Description: A function to initialize a local git repo, create/connect it to a GitHub repo, and set up files
# Usage: incon

# Example: incon test ---Initializes a local git repo, creates/connects it to a GitHub repo, and sets up files.

##########

# A function to initialize a local git repo, create/connect it to a GitHub repo, and set up files
incon() {
    # Ensure the gh tool is installed.
    if ! command -v gh &> /dev/null; then
        echo "gh (GitHub CLI) not found. Please install it to proceed."
        return
    fi

    # Check if the current directory already contains a git repository
    if [ -d ".git" ]; then
        echo "This directory is already initialized as a git repository."
        return
    fi

    # 1. Initialize a new local Git repository
    git init

    # Create a .gitignore and README.md file
    touch .gitignore
    touch README.md
    touch .version
    repo_name=$(basename $(pwd) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    formatted_name=$(echo $repo_name | tr '_' ' ' | sed -e "s/\b\(.\)/\u\1/g")
    echo "# $formatted_name" > README.md
    echo "* Not started" >> README.md
    echo "0.0.0-alpha" > .version

    # 2. Create a new remote public repository on GitHub using the gh tool
    gh repo create $repo_name --private || { echo "Repository creation failed. Exiting."; return; }

    # 3. Connect the local repository to the newly created remote repository on GitHub
    git remote add origin "https://github.com/$(gh api user | jq -r '.login')/$repo_name.git"
    
    # 4. Add all files, commit, and push
    cc "Initial commit"
    git push -u origin master || { echo "Push to master failed. Exiting."; return; }

    # 5. Create a test branch, switch to it, and then switch back to master
    git checkout -b test
    cc "Initial test commit"
    git checkout master
}

################################################################################
# UPDATE
################################################################################

# Describe the update function and its options and usage

# update
# Description: A function to update the system and reboot if desired
# Usage: update [option]
# Options:
#   -r    Reboot the system after updating
#   -h    Display this help message
#   -l    Display the log file path

# Example: update -r  ---Updates the system and reboots the system after updating.

##########

# Create an update command to update your Linux machine.
update() {
    # Check if the '-h' flag is provided
    if [[ $1 == "-h" ]]; then
        echo "Usage: update [option]"
        echo "Options:"
        echo "  -r    Reboot the system after updating"
        echo "  -h    Display this help message"
        echo "  -l    Display the log file path"
        return
    fi

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
# FINDFILE
################################################################################

# Describe the findfile function and its options and usage

# findfile
# Description: A function to search for files matching a pattern
# Alias: ff
# Usage: findfile [options] [file_pattern]
# Options:
#   -i            Interactive mode. Prompts for parameters.
#   -s            Perform a case-sensitive search.
#   -t [type]     Search for a specific file type (e.g., f for file, d for directory).
#   -d [dir]      Specify the directory to search in.
#   -m [days]     Search for files modified in the last 'days' days.
#   -r [pattern]  Use regular expression for searching.
#   -h            Display this help message.

# Example: findfile -t f 'pattern'  ---Search for files matching 'pattern'.

##########

function findfile() {
    # alias ff="findfile"
    if [[ "$1" == "-h" ]]; then
        echo "Usage: findfile [options] [file_pattern]"
        echo "Alias: ff"
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
            echo " "
            echo "$line"
            echo "cd $(dirname "$line") && ls"
            found=1
        done < <(find "$search_dir" -regextype posix-extended -regex "$file_pattern" $file_type $max_days 2>/dev/null)
    else
        if [[ -n "$file_pattern" ]]; then
            while IFS= read -r line; do
                echo " "
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

################################################################################
# FIGLET CONFIGURATION
################################################################################

# Check to see if figlet is installed and install it if it is not
if ! command -v figlet &> /dev/null; then
    echo "figlet not found. Installing..."
    sudo apt install figlet -y
fi

# Create a file to store figlet configuration and message text
figlet_config_file=~/.figlet_config

# Check if the figlet configuration file exists and create it prompting the user for a username and font if it does not
if [ ! -f $figlet_config_file ]; then

    # Check if the enable_figlet variable does not exist in the figlet configuration file
    if ! grep -q "enable_figlet" $figlet_config_file; then
    
        # Prompt the user if they want to enable the welcome message
        while true; do
            read -p "Would you like to enable the welcome message? (y/n): " enable_welcome

            # Check if the user wants to enable the welcome message
            if [[ $enable_welcome == "y" || $enable_welcome == "Y" ]]; then
                enable_figlet="y"
                break
            elif [[ $enable_welcome == "n" || $enable_welcome == "N" ]]; then
                enable_figlet="n"
                break
            else
                echo "Invalid input. Please enter 'y' or 'n'."
            fi
        done

        # Store the enable_figlet variable in the figlet configuration file
        echo "enable_figlet=$enable_figlet" >> $figlet_config_file
    fi

    # Check if the welcome message is enabled
    if [[ $enable_figlet == "y" || $enable_figlet == "Y" ]]; then
        while true; do  

            # Prompt the user to enter a username
            read -p "Enter a username to use with figlet: " username

            # Prompt the user to enter a font
            read -p "Enter a font to use with figlet [future]: " font
            font=${font:-future}

            # Display the entered username and font
            echo "Username: $username"
            echo "Font: $font"

            # Prompt the user to confirm the username and font
            read -p "Is this correct? (y/n): " confirm

            case $confirm in
                [Yy]*)
                    echo "username=$username" >> $figlet_config_file
                    echo "font=$font" >> $figlet_config_file
                    break
                    ;;
                [Nn]*)
                    echo "Username and font not confirmed. Please try again."
                    ;;
                *)
                    echo "Invalid input. Please enter 'y' or 'n'."
                    ;;
            esac
        done
    fi
fi

# Create a function to remove the configuration file and refresh the terminal
function remove_figlet_config() {
    # Alias for the remove_figlet_config function
    # alias rfc="remove_figlet_config"
    # Prompt the user to confirm the removal of the figlet configuration file
    read -p "Are you sure you want to remove the figlet configuration file? (y/n): " confirm

    # Check if the user wants to remove the figlet configuration file
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        # Remove the figlet configuration file
        rm $figlet_config_file
        echo "Figlet configuration file removed."
        echo "Refresh terminal to apply changes."
    else
        echo "Figlet configuration file removal canceled."
    fi
}

################################################################################
# SESSION ID GENERATION
################################################################################

# Create a variable to store a number that will serve as the session ID, and increment it by 1 each time it is loaded
if [ -f ~/.session_id ]; then
    session_id=$(< ~/.session_id)
    session_id=$((session_id+1))
    echo $session_id > ~/.session_id
else
    session_id=1
    echo $session_id > ~/.session_id
fi

# Prompt the user if they would like to display the session ID on terminal run and store the response in a configuration file
if [ ! -f ~/.session_id_config ]; then
    while true; do
        read -p "Would you like to display the session ID on terminal run? (y/n): " enable_session_id

        # Check if the user wants to enable the session ID on terminal run
        if [[ $enable_session_id == "y" || $enable_session_id == "Y" ]]; then
            echo "enable_session_id=y" >> ~/.session_id_config
            break
        elif [[ $enable_session_id == "n" || $enable_session_id == "N" ]]; then
            echo "enable_session_id=n" >> ~/.session_id_config
            break
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
fi

# Create a function to remove the configuration file and refresh the terminal
function remove_session_id_config() {
    # Alias for the remove_session_id_config function
    # alias rsc="remove_session_id_config"
    # Prompt the user to confirm the removal of the session ID configuration file
    read -p "Are you sure you want to remove the session ID configuration file? (y/n): " confirm

    # Check if the user wants to remove the session ID configuration file
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        # Remove the session ID configuration file
        rm ~/.session_id_config
        echo "Session ID configuration file removed."
        echo "Refresh terminal to apply changes."
    else
        echo "Session ID configuration file removal canceled."
    fi
}

################################################################################
# NEOFETCH CONFIGURATION
################################################################################

# Check to see if neofetch is installed and install it if it is not, then call it
if ! command -v neofetch &> /dev/null; then
    echo "neofetch not found. Installing..."
    sudo apt install neofetch -y
fi

# Prompt the user if they would like to enable neofetch on terminal run and store the response in a configuration file
if [ ! -f ~/.neofetch_config ]; then
    while true; do
        read -p "Would you like to enable neofetch on terminal run? (y/n): " enable_neofetch

        # Check if the user wants to enable neofetch on terminal run
        if [[ $enable_neofetch == "y" || $enable_neofetch == "Y" ]]; then
            echo "enable_neofetch=y" >> ~/.neofetch_config
            break
        elif [[ $enable_neofetch == "n" || $enable_neofetch == "N" ]]; then
            echo "enable_neofetch=n" >> ~/.neofetch_config
            break
        else
            echo "Invalid input. Please enter 'y' or 'n'."
        fi
    done
fi

# Create a function to remove the configuration file and refresh the terminal
function remove_neofetch_config() {
    # Alias for the remove_neofetch_config function
    # alias rnc="remove_neofetch_config"
    # Prompt the user to confirm the removal of the neofetch configuration file
    read -p "Are you sure you want to remove the neofetch configuration file? (y/n): " confirm

    # Check if the user wants to remove the neofetch configuration file
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        # Remove the neofetch configuration file
        rm ~/.neofetch_config
        echo "Neofetch configuration file removed."
        echo "Refresh terminal to apply changes."
    else
        echo "Neofetch configuration file removal canceled."
    fi
}

################################################################################
# ODT
################################################################################

# Describe the odt function and its options and usage

# odt
# Description: A function to create a .odt file in the current directory and open it
# Usage: odt [filename]
# Options:
#   -h    Display this help message

# Example: odt test  ---Creates a .odt file called test and opens it in the current directory.

# Create odt command to create a .odt file in the current directory and open it
function odt() {
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
function ods() {
    touch "$1.ods"
    libreoffice "$1.ods"
}

###################################################################################################################################################################
# ALIASES
###################################################################################################################################################################

# Create aliases for common commands
alias docs="cd ~/Documents && ls"
alias home="cd ~ && ls"
alias back="cd .. && ls"
alias cdgh="cd ~/Documents/github_repositories && ls"
alias temp="cd ~/Documents/Temporary && ls"
alias cbc="cdgh && cd custom_bash_commands && ls"
alias cbcc="cdgh && cd custom_bash_commands && ls && dv && cc"
alias rma='rm -rf'
alias editbash='code ~/.bashrc && source ~/.bashrc'
alias cls='clear && ls'
alias refresh='source ~/.bashrc'
alias c='clear && dv'
alias gits='git status'
alias x='chmod +x'
alias myip="curl http://ipecho.net/plain; echo"
alias rfc="remove_figlet_config"
alias rnc="remove_neofetch_config"
alias rsc="remove_session_id_config"
alias ff="findfile"
alias dv="display_version"
alias rdvc="remove_display_version_config"
alias remove_all_cbc_configs="racc"

###################################################################################################################################################################

# Check if the 'enable_display_version' variable in the display version configuration file is equal to 'n'
if ! grep -q "enable_display_version=n" ~/.display_version_config; then
    # Display the version number using the display_version function
    display_version
fi

#display_version

###################################################################################################################################################################

# Check if the 'enable_session_id' variable in the session ID configuration file is equal to 'n'
if ! grep -q "enable_session_id=n" ~/.session_id_config; then
    # Display the session ID
    echo -e "Session ID: \e[33m$session_id\e[0m"
fi

###################################################################################################################################################################

# Check if the 'enable_neofetch' variable in the neofetch configuration file is equal to 'n'
if ! grep -q "enable_neofetch=n" ~/.neofetch_config; then
    # Display system information using neofetch
    neofetch
fi

###################################################################################################################################################################

# Check if the 'enable_figlet' variable in the figlet configuration file is equal to 'n'
if ! grep -q "enable_figlet=n" $figlet_config_file; then
    # Get the font from the figlet configuration file
    fig_font=$(grep -oP 'font=\K.*' $figlet_config_file)
    fig_user=$(grep -oP 'username=\K.*' $figlet_config_file)
    # Display a welcome message using figlet and the username from the figlet configuration file and the font with a border
    figlet -f $fig_font "Welcome $fig_user" -F border
fi
# figlet -f future "Welcome $username" -F border ###### DELETE? ######

###################################################################################################################################################################

# Change to the home directory
cd ~

###################################################################################################################################################################