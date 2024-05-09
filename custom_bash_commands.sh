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

# Example: display_version  ---Displays the version number from the .version file from the local repository

##########

# Function to display the .version file from the local repository.
display_version() {
    if [ "$1" = "-h" ]; then
        echo "Description: This function allows you to display the version number from the .version file from the local repository."
        echo "Alias: dv"
        echo "Usage: display_version"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
    # Create an alias for the display_version function
    # alias dv="display_version"
    # Read the contents of the .version file and display it in the terminal
    version_number=$(cat ~/.version)
    echo -e "Now using \e[32mCustom Bash Commands\e[0m (by \e[35miop098321qwe\e[0m) \e[34mVersion:\e[0m \e[34m$version_number\e[0m"
    echo -e "You can show commands included with cbcs [-h]."
    echo -e "If you wish to stop using \e[32mCBC\e[0m, \e[31mremove\e[0m \e[33m.custom_bash_commands.sh\e[0m from your \e[33m.bashrc\e[0m file using \e[36meditbash\e[0m (\e[32mCBC\e[0m)."
    echo -e "Check out the Wiki for more information: \e[34mhttps://github.com/iop098321qwe/custom_bash_commands/wiki\e[0m"
}

# Create a file to store the display_version configuration
display_version_config_file=~/.display_version_config

# Check if the display_version configuration file exists and create it prompting the user for a username and font if it does not
if [ ! -f $display_version_config_file ]; then

    # Check if the enable_display_version variable does not exist in the display_version configuration file
    if ! grep -q "enable_display_version" $display_version_config_file; then
    
        # Prompt the user if they want to enable the welcome message
        while true; do
            read -p "Would you like to enable the display_version message? HIGHLY RECOMMENDED (y/n): " enable_display_version

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
        figlet -f future -F border Available custom commands:
        echo "NOT CURRENTLY ALPHABETICAL"
        echo " "
        echo "  display_version,   (alias: dv)"
        echo "         Description: Display the version number from the .version file"
        echo "         Usage: display_version   (alias: dv)"
        echo "  cbcs"
        echo "         Description: Display a list of all available custom commands in this script"
        echo "         Usage: cbcs [-h]"
        echo "  rma"
        echo "         Description: Remove the directory and all files it contains"
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
        # SEPARATE ALIAS SECTION ###############################################################################
        #figlet -f future -F border Available custom aliases:
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
        echo "  gsw"
        echo "         Description: Alias for 'git switch'"
        echo "         Usage: gsw [branch]"
        echo "  gswm"
        echo "         Description: Quickly switch to the master branch of a git repository"
        echo "         Usage: gswm"
        echo "  gswt"
        echo "         Description: Quickly switch to the test branch of a git repository"
        echo "         Usage: gswt"
        echo "  filehash,   (alias: fh)"
        echo "         Description: Display the hash of a file"
        echo "         Usage: filehash [file] [hash_type]"
        echo "  display_info,  (alias: di)"
        echo "         Description: Display CBC information"
        echo "         Usage: display_info"
        echo "  py"
        echo "         Description: Alias for 'python3'"
        echo "         Usage: py [file]"
        echo "  python"
        echo "         Description: Alias for 'python3'"
        echo "         Usage: python [file]"
        echo "  regex_help"
        echo "         Description: Display help for regular expressions"
        echo "         Usage: regex_help [-f|--flavor <flavor>] [-h|--help]"
        echo "  dt"
        echo "         Description: Switch to the Deeptree directory and list its contents"
        echo "         Usage: dt"
        echo "  dtr"
        echo "         Description: Switch to the Deeptree Reference Material directory and list its contents"
        echo "         Usage: dtr"
        echo "  dispatch"
        echo "         Description: Change to the Dispatch directory and list its contents"
        echo "         Usage: dispatch"
        echo "  updatecbc,   (alias: ucbc)"
        echo "         Description: Update the custom bash commands script"
        echo "         Usage: updatecbc"
    else
        # Display a list of all available custom commands and functions in this script
        echo " "
        figlet -f future -F border Available custom commands:
        echo "Use cbcs [-h] with help flag to display descriptions and usage. (NOT CURRENTLY ALPHABETICAL)"
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
        # SEPARATE ALIAS SECTION ###############################################################################
        #figlet -f future -F border Available custom aliases:
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
        echo "  gsw"
        echo "  gswm"
        echo "  gswt"
        echo "  filehash,   (alias: fh)"
        echo "  display_info,  (alias: di)"
        echo "  py"
        echo "  python"
        echo "  regex_help"
        echo "  dt"
        echo "  dtr"
        echo "  dispatch"
        echo "  updatecbc,   (alias: ucbc)"
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
    if [ "$1" = "-h" ]; then
        echo "Description: This function allows you to create a directory and switch into it."
        echo "Usage: mkcd [directory]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
    if [ "$1" = "-h" ]; then
        echo "Description: This function allows you to create a backup file of a file."
        echo "Usage: bkup [file]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
    if [ "$1" = "-h" ]; then
        echo "Description: This function allows you to move up in the directory hierarchy by a specified number of levels."
        echo "Usage: up [number of levels]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi

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

# Describe the remove_all_cbc_configs function and its options and usage

# remove_all_cbc_configs
# Description: A function to remove all configuration files associated with CBC
# Alias: racc
# Usage: remove_all_cbc_configs
# Options:
#   -h    Display this help message

# Example: remove_all_cbc_configs  ---Removes all configuration files associated with CBC.

# Create a function to call rfc, rnc, rsc, and rdvc
function remove_all_cbc_configs() {
    if [ "$1" = "-h" ]; then
        echo "Description: A function to remove all configuration files associated with CBC"
        echo "Alias: racc"
        echo "Usage: remove_all_cbc_configs"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
    # Alias for the remove_all_cbc_configs function
    # Alias: remove_all_cbc_configs="racc"
    # Call the rfc, rnc, rsc, and rdvc functions
    remove_figlet_config; remove_neofetch_config; remove_session_id_config; remove_display_version_config
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
    if [ "$1" = "-h" ]; then
        echo "Description: A function to initialize a local git repo, create/connect it to a GitHub repo, and set up files"
        echo "Usage: incon [repo_name]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
#   -r           Reboot the system after updating
#   -h|--help    Display this help message
#   -l           Display the log file path

# Example: update -r  ---Updates the system and reboots the system after updating.

##########

# Create an update command to update your Linux machine.
update() {
    # Check if the '-h' or '--help' flag is provided
    if [[ $1 == "-h" || $1 == "--help" ]]; then
        # Display the help message
        echo "Usage: update [option]"
        echo "Options:"
        echo "  -r    Reboot the system after updating"
        echo "  -s    Shutdown the system after updating"
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
# REGEX HELP (REWRITE)
################################################################################

# Describe the regex_help function and its options and usage

# regex_help
# Description: A function to display help for regular expressions
# Usage: regex_help [-f|--flavor <flavor>] [-h|--help]
# Options:
#   -f|--flavor <flavor>    Specify the regex flavor (e.g., POSIX-extended, POSIX-basic, PCRE)
#   -h|--help               Display this help message
#   --example               Display an example of the regex flavor

# Example: regex_help -f PCRE  ---Displays help for PCRE regular expressions.

# Create a function to display help for regular expressions
regex_help() {
    # Check if the '-h' flag is provided
    # PLACEHOLDER

    # Check if the '--help' flag is provided and provide a more detailed help message
    # PLACEHOLDER

    # Default flavor
    local flavor="POSIX-extended"

    # Check for arguments
    while (( "$#" )); do
        case "$1" in
            -f|--flavor) # Option for specifying the regex flavor
                if [ -n "$2" ] && [ "${2:0:1}" != "-" ]; then
                    flavor=$2
                    shift 2
                else
                    echo "Error: Argument for $1 is missing" >&2
                    return 1
                fi
                ;;
            -h|--help) # Help flag
                echo "Usage: regex_help [-f|--flavor <flavor>] [-h|--help]"
                echo "Flavors: POSIX-extended, POSIX-basic, PCRE"
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
        # Help flag
        "help")
            echo "Usage: regex_help [-f|--flavor <flavor>] [-h|--help]"
            echo "Flavors: POSIX-extended, POSIX-basic, PCRE"
            return 0
            ;;
        *)
            # Handle unexpected flavors
            echo "Error: Unsupported flavor $flavor" >&2
            return 1
            ;;
    esac
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
    if [ "$1" = "-h" ]; then
        echo "Description: A function to remove the figlet configuration file and refresh the terminal"
        echo "Alias: rfc"
        echo "Usage: remove_figlet_config"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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

# Create a function to remove the configuration file
function remove_session_id_config() {
    if [ "$1" = "-h" ]; then
        echo "Description: A function to remove the session ID configuration file"
        echo "Alias: rsc"
        echo "Usage: remove_session_id_config"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
    if [ "$1" = "-h" ]; then
        echo "Description: A function to remove the neofetch configuration file and refresh the terminal"
        echo "Alias: rnc"
        echo "Usage: remove_neofetch_config"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
    if [ "$1" = "-h" ]; then
        echo "Description: A function to create a .odt file in the current directory and open it"
        echo "Usage: odt [filename]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
    if [ "$1" = "-h" ]; then
        echo "Description: A function to create a .ods file in the current directory and open it"
        echo "Usage: ods [filename]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
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
function filehash() {
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

# Describe the display_info function and its options and usage

# display_info
# Description: A function to display information
# Usage: display_info
# Options:
#   -h    Display this help message

# Example: display_info  ---Displays information.

# Function to display information
function display_info() {
    if [ "$1" = "-h" ]; then
        echo "Description: A function to display CBC information"
        echo "Usage: display_info"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
    # Alias for the display_info function
    # alias di="display_info"

    # Check if the 'enable_display_version' variable in the display version configuration file is equal to 'n'
    if ! grep -q "enable_display_version=n" ~/.display_version_config; then
        # Display the version number using the display_version function
        display_version
    fi

    # Check if the 'enable_session_id' variable in the session ID configuration file is equal to 'n'
    if ! grep -q "enable_session_id=n" ~/.session_id_config; then
        # Display the session ID
        echo -e "Session ID: \e[33m$session_id\e[0m"
    fi

    # Check if the 'enable_neofetch' variable in the neofetch configuration file is equal to 'n'
    if ! grep -q "enable_neofetch=n" ~/.neofetch_config; then
        # Display system information using neofetch
        neofetch
    fi

    # Check if the 'enable_figlet' variable in the figlet configuration file is equal to 'n'
    if ! grep -q "enable_figlet=n" $figlet_config_file; then
        # Get the font from the figlet configuration file
        fig_font=$(grep -oP 'font=\K.*' $figlet_config_file)
        fig_user=$(grep -oP 'username=\K.*' $figlet_config_file)
        # Display a welcome message using figlet and the username from the figlet configuration file and the font with a border
        figlet -f $fig_font "Welcome $fig_user" -F border
    fi
}

################################################################################
# UPDATE CBC COMMANDS COMMAND
################################################################################

# Create a function to update the custom bash commands script and display the version number

# updatecbc
# Description: A function to update the custom bash commands script and display the version number
# Usage: updatecbc
# Options:
#   -h    Display this help message

# Create a function to update the custom bash commands script and display the version number
function updatecbc() {
    if [ "$1" = "-h" ]; then
        echo "Description: A function to update the custom bash commands"
        echo "Usage: updatecbc"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi
    # Temporary directory for sparse checkout
    SPARSE_DIR=$(mktemp -d)

    # URL of the GitHub repository
    REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

    # List of file paths to download and move
    FILE_PATHS=(
        custom_bash_commands.sh
        .version
    )

    # Initialize an empty git repository and configure for sparse checkout
    cd $SPARSE_DIR
    git init -q
    git remote add origin $REPO_URL
    git config core.sparseCheckout true

    # Add each file path to the sparse checkout configuration
    for path in "${FILE_PATHS[@]}"; do
        echo $path >> .git/info/sparse-checkout
    done

    # Fetch only the desired files from the master branch
    git pull origin master -q

    # Move the fetched files to the target directory
    for path in "${FILE_PATHS[@]}"; do
        # Determine the new filename with '.' prefix (if not already prefixed)
        new_filename="$(basename $path)"
        if [[ $new_filename != .* ]]; then
            new_filename=".$new_filename"
        fi

        # Copy the file to the home directory with the new filename
        cp $SPARSE_DIR/$path ~/$new_filename
        echo "Copied $path to $new_filename"
    done

    # Clean up
    rm -rf $SPARSE_DIR
    cd ~
    clear

    # Source the updated commands
    source ~/.custom_bash_commands.sh
}

###################################################################################################################################################################
# ALIASES
###################################################################################################################################################################

# Function to call alias commands from pairs stored in an array
function call_alias_commands() {
    # Array of alias command pairs
    local alias_commands=(
        "docs:cd ~/Documents && ls"
        "home:cd ~ && ls"
        "back:cd .. && ls"
        "cdgh:cd ~/Documents/github_repositories && ls"
        "temp:cd ~/Documents/Temporary && ls"
        "cbc:cdgh && cd custom_bash_commands && ls"
        "cbcc:cdgh && cd custom_bash_commands && ls && dv && cc"
        "rma:rm -rf"
        "editbash:code ~/.bashrc && source ~/.bashrc"
        "cls:clear && di && ls"
        "refresh:source ~/.bashrc && clear && di"
        "c:clear && di"
        "gits:git status"
        "x:chmod +x"
        "myip:curl http://ipecho.net/plain; echo"
        "rfc:remove_figlet_config"
        "rnc:remove_neofetch_config"
        "rsc:remove_session_id_config"
        "ff:findfile"
        "dv:display_version"
        "rdvc:remove_display_version_config"
        "racc:remove_all_cbc_configs"
        #"testcbc:source ~/.test_update_commands.sh; source ~/.test_custom_bash_commands.sh"
        "gsw:git switch"
        "gswm:git switch master"
        "gswt:git switch test"
        "fh:filehash"
        "di:display_info"
        "py:python3"
        "python:python3"
        "rh:regex_help"
        "dt:cd ~/Documents/Deeptree && ls"
        "dtr:cd ~/Documents/Deeptree/reference_material && ls"
        "dispatch:cd ~/Documents/Deeptree/reference_material/dispatch && ls"
        "z:eza"
        "ucbc:updatecbc"
    )

    # Loop through the alias command pairs
    for alias_command in "${alias_commands[@]}"; do
        # Split the alias command pair into alias and command
        IFS=':' read -r alias command <<< "$alias_command"
        # Call the alias command
        alias "$alias"="$command"
    done
}

# Call the function to set up alias commands
call_alias_commands

###################################################################################################################################################################

# Call the function to display information
display_info

###################################################################################################################################################################

# If session ID is 1, display the welcome message and run cbcs -h
if [ $session_id -eq 1 ]; then
    # Display the welcome message
    echo " "
    figlet -f future -F border Welcome to custom bash commands!
    echo " "
    echo "Run cbcs [-h] with help flag to display descriptions and usage."
    echo " "
    # Run cbcs -h
    cbcs -h
fi

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
function check_install_zoxide() {
    # Check if zoxide is installed, and if it is, source the zoxide init script
    if command -v zoxide &> /dev/null; then
        eval "$(zoxide init --cmd cd bash)"
    # If zoxide is not installed, install it
    else
        echo "zoxide not found. Installing..."
        sleep 3
        curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
        sudo apt install zoxide -y
        eval "$(zoxide init --cmd cd bash)"
        echo "Please use 'refresh' to refresh the terminal"
    fi
}

###################################################################################################################################################################
# Ensure fzf is installed, and if not install it.
###################################################################################################################################################################

# Function to check if fzf is installed and install it if necessary
function check_install_fzf() {
    if ! command -v fzf &> /dev/null; then
        echo "fzf not found. Installing..."
        sleep 3
        sudo apt install fzf -y
        echo "Please use 'refresh' to refresh the terminal"
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
function check_install_bat() {
    if ! command -v batcat &> /dev/null; then
        echo "bat not found. Installing..."
        sudo apt install bat -y
        echo "Please use 'refresh' to refresh the terminal"
    fi
}

###################################################################################################################################################################
# Check if neovim is installed, and if it is, add it to PATH.
###################################################################################################################################################################

# Function to check if neovim is installed and add it to PATH
function check_install_neovim() {
    if command -v nvim &> /dev/null; then
        export PATH="$PATH:/opt/nvim-linux64/bin"
        # If neovim is not installed, install it using "sudo apt install neovim -y"
    else
        echo "Neovim not found. Installing..."
        sudo apt install neovim -y
        echo "Neovim has been installed."
    fi

    # Set the default editor to neovim if and only if neovim is installed
    if command -v nvim &> /dev/null; then
        export EDITOR=nvim
    fi
}

###################################################################################################################################################################
# Check if eza is installed, and if not display a message to install it.
###################################################################################################################################################################

# Check if eza is installed, and if not display a message to install it, if installed, set aliases for eza
# Function to check and install eza if not already installed
function check_install_eza() {
    if ! command -v eza &> /dev/null; then
        echo -e "Eza is not installed. Installing now..."
        sudo mkdir -p /etc/apt/keyrings
        wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
        echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
        sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list
        sudo apt update
        sudo apt install eza -y
        echo "Eza has been installed."
    fi

    # Set ls aliases for eza
    alias ls="eza --group-directories-first"
    alias l="eza --group-directories-first -F"
}

###################################################################################################################################################################
# Check if zellij is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if zellij is installed and install it if not
function check_install_zellij() {
    if ! command -v zellij &> /dev/null; then
        echo "Zellij not found. Installing..."
        sudo snap install zellij --classic
        echo "Zellij has been installed."
    fi
}

###################################################################################################################################################################
# Check if btop is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if btop is installed and install it if not
function check_install_btop() {
    if ! command -v btop &> /dev/null; then
        echo "Btop not found. Installing..."
        sudo apt install btop -y
        echo "Btop has been installed."
    fi
}

###################################################################################################################################################################
# Create a config file for installing additional software that may not already be installed where commented out software is not installed.
###################################################################################################################################################################

# Create a default config file to load information for installing additional software
# Check if the config file exists in the home directory, and if it does not, copy the default config file to the home directory

# Script to install software based on the configuration file

# If .cbcconfig directory does not exist in the home directory, create it
 if [ ! -d "$HOME/.cbcconfig" ]; then
    mkdir "$HOME/.cbcconfig"
fi

# set apt_conf to the path of apt_packages.conf in .cbcconfig directory
# apt_conf="$HOME/.cbcconfig/apt_packages.conf"

#Read the config file and install the software
#while IFS= read -r line; do
#    if [[ ! "$line" =~ ^#.*$ ]] && [[ -n "$line" ]]; then
#        echo "Installing $line..."
#        sudo apt install "$line" -y
#    fi
#done < "$apt_conf"

###################################################################################################################################################################
# Additional Software Installation
###################################################################################################################################################################

# Set config file path
CONFIG_FILE="$HOME/.cbc.config"

# If config file does not exist, create it with default values
if [ ! -f "$CONFIG_FILE" ]; then
    echo "NEOVIM=false" >> "$CONFIG_FILE"
    echo "BAT=false" >> "$CONFIG_FILE"
    echo "EZA=false" >> "$CONFIG_FILE"
    echo "BTOP=false" >> "$CONFIG_FILE"
    echo "ZOXIDE=false" >> "$CONFIG_FILE"
    echo "FZF=false" >> "$CONFIG_FILE"
    echo "ZELLIJ=false" >> "$CONFIG_FILE"
fi

# Read the configuration file and check if NEOVIM=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "${NEOVIM:=false}" == "true" ]]; then
        # Call the function to check neovim installation and install neovim
        check_install_neovim
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

# Read the configuration file and check if EZA=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "${EZA:=false}" == "true" ]]; then
        # Call the function to check eza installation and install eza
        check_install_eza
    fi
fi

# Read the configuration file and check if BTOP=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "$BTOP" = "true" ]]; then
        # Call the function to check btop installation and install btop
        check_install_btop
    fi
fi

# Read the configuration file and check if ZOXIDE=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "$ZOXIDE" = "true" ]]; then
        # Call the function to check zoxide installation and install zoxide
        check_install_zoxide
    fi
fi

# Read the configuration file and check if FZF=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "$FZF" = "true" ]]; then
        # Call the function to check fzf installation and install fzf
        check_install_fzf
    fi
fi

# Read the configuration file and check if ZELLIJ=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "$ZELLIJ" = "true" ]]; then
        # Call the function to check zellij installation and install zellij
        check_install_zellij
    fi
fi

###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################

