#!/usr/bin/env bash
VERSION="1.24.4"

###################################################################################################################################################################
# CUSTOM BASH COMMANDS
###################################################################################################################################################################

# Set config file path
CONFIG_FILE="$HOME/.cbc.config"

################################################################################
# Create config file function
################################################################################

# Function to create the config file with default values if it does not exist
function create_config_file() {
    echo "# Configuration file for Custom Bash Commands (CBC) by iop098321qwe" >> "$CONFIG_FILE"
    echo " " >> "$CONFIG_FILE"
    echo "# First-time setup?" >> "$CONFIG_FILE"
    echo "FIRST_TIME=true" >> "$CONFIG_FILE"
    echo " " >> "$CONFIG_FILE"
    echo "# Settings for additional software installation" >> "$CONFIG_FILE"
    echo " " >> "$CONFIG_FILE"
    echo "NEOVIM=true" >> "$CONFIG_FILE"
    echo "BAT=false" >> "$CONFIG_FILE"
    echo "EZA=false" >> "$CONFIG_FILE"
    echo "BTOP=false" >> "$CONFIG_FILE"
    echo "ZOXIDE=false" >> "$CONFIG_FILE"
    echo "FZF=false" >> "$CONFIG_FILE"
    echo "ZELLI=false" >> "$CONFIG_FILE"
    echo "THEFUCK=false" >> "$CONFIG_FILE"
    echo "OBSIDIAN=false" >> "$CONFIG_FILE"
    echo "VSCODE=false" >> "$CONFIG_FILE"
    echo "RANGER=true" >> "$CONFIG_FILE"
    echo "HSTR=true" >> "$CONFIG_FILE"
    echo "Config file created at $CONFIG_FILE"
}

# Check if config file exists, and if not, create it with default values
if [ ! -f "$CONFIG_FILE" ]; then
    create_config_file
fi

################################################################################
# First-time setup function
################################################################################

# Function to run the first-time setup for Custom Bash Commands
function first_time_setup() {

    # Read the FIRST_TIME variable from the config file
    source "$CONFIG_FILE"

    # Check if it is the first time running the setup
    if [ "$FIRST_TIME" = true ]; then
        echo "Welcome to Custom Bash Commands (CBC) by iop098321qwe!"
        echo "This setup will guide you through the initial configuration."
        echo " "
        echo "Let's get started!"
        echo " "

        # Prompt the user to install additional software
        echo "Additional Software Installation:"
        echo " "
        echo "Would you like to install the following software packages?"
        echo " "
        echo "1. Neovim"
        echo "2. Bat"
        echo "3. exa"
        echo "4. btop"
        echo "5. Zoxide"
        echo "6. fzf"
        echo "7. Zellij"
        echo "8. thefuck"
        echo "9. Obsidian"
        echo "10. VSCode"
        echo "11. Ranger"
        echo "12. hstr"
        echo " "
        echo "Enter the corresponding numbers separated by spaces (e.g., '1 2 3'), or enter 'a' to install all: "
        read -p "Your choice: " software_choices

        # Check the user's choices and update the config file
        if [[ $software_choices == *"a"* ]]; then
            sed -i 's/NEOVIM=false/NEOVIM=true/' "$CONFIG_FILE"
            sed -i 's/BAT=false/BAT=true/' "$CONFIG_FILE"
            sed -i 's/EZA=false/EZA=true/' "$CONFIG_FILE"
            sed -i 's/BTOP=false/BTOP=true/' "$CONFIG_FILE"
            sed -i 's/ZOXIDE=false/ZOXIDE=true/' "$CONFIG_FILE"
            sed -i 's/FZF=false/FZF=true/' "$CONFIG_FILE"
            sed -i 's/ZELLI=false/ZELLI=true/' "$CONFIG_FILE"
            sed -i 's/THEFUCK=false/THEFUCK=true/' "$CONFIG_FILE"
            sed -i 's/OBSIDIAN=false/OBSIDIAN=true/' "$CONFIG_FILE"
            sed -i 's/VSCODE=false/VSCODE=true/' "$CONFIG_FILE"
            sed -i 's/RANGER=false/RANGER=true/' "CONFIG_FILE"
        else
            if [[ $software_choices == *"1"* ]]; then
                sed -i 's/NEOVIM=false/NEOVIM=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"2"* ]]; then
                sed -i 's/BAT=false/BAT=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"3"* ]]; then
                sed -i 's/EZA=false/EZA=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"4"* ]]; then
                sed -i 's/BTOP=false/BTOP=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"5"* ]]; then
                sed -i 's/ZOXIDE=false/ZOXIDE=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"6"* ]]; then
                sed -i 's/FZF=false/FZF=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"7"* ]]; then
                sed -i 's/ZELLI=false/ZELLI=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"8"* ]]; then
                sed -i 's/THEFUCK=false/THEFUCK=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"9"* ]]; then
                sed -i 's/OBSIDIAN=false/OBSIDIAN=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"10"* ]]; then
                sed -i 's/VSCODE=false/VSCODE=true/' "$CONFIG_FILE"
            fi
            if [[ $software_choices == *"11"* ]]; then
                sed -i 's/RANGER=false/RANGER=true/' "CONFIG_FILE"
            fi
            if [[ $software_choices == *"12"* ]]; then
                sed -i 's/HSTR=false/HSTR=true/' "CONFIG_FILE"
            fi
        fi

        # Update the FIRST_TIME variable in the config file
        sed -i 's/FIRST_TIME=true/FIRST_TIME=false/' "$CONFIG_FILE"
        echo " "
        echo "Setup complete! Please restart your terminal to apply the changes."
    else
        echo "Configuration can be edited in $CONFIG_FILE or by using 'conf' command."
        alias conf="nvim $CONFIG_FILE"
    fi
}

################################################################################
# Remove cbc configuration file
################################################################################

# Function to remove configuration file for CBC
function rmconf() {
    if [ -f "$CONFIG_FILE" ]; then
        rm "$CONFIG_FILE"
        echo "Config file removed."
    else
        echo "Config file does not exist."
    fi
}

################################################################################
# Append to end of .bashrc function
################################################################################

# Function to append the CBC script to the end of the .bashrc file
function append_to_bashrc() {
    # Check if the CBC script is already sourced in the .bashrc file
    if ! grep -q ".custom_bash_commands.sh" "$HOME/.bashrc"; then
        # Append the CBC script to the end of the .bashrc file
        echo "###################################################################################################################################################################" >> "$HOME/.bashrc"
        echo "# Custom Additions" >> "$HOME/.bashrc"
        echo "###################################################################################################################################################################" >> "$HOME/.bashrc"
        echo " " >> "$HOME/.bashrc"
        echo "#source ~/.update_commands.sh" >> "$HOME/.bashrc"
        echo "source ~/.custom_bash_commands.sh" >> "$HOME/.bashrc"
    fi
}

# Call the append_to_bashrc function
append_to_bashrc

################################################################################
# Create function to open the wiki using the default browser
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
function wiki() {
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
        xdg-open "$wiki_url#cbc-commands"
    elif [ "$1" = "-A" ]; then
        # Open the wiki to the CBC aliases section
        xdg-open "$wiki_url#cbc-aliases"
    elif [ "$1" = "-F" ]; then
        # Open the wiki to the CBC functions section
        xdg-open "$wiki_url#cbc-functions"
    else
        # Open the CBC wiki in the default browser
        xdg-open "$wiki_url"
    fi
}

################################################################################
# Create a function to open the doftiles repository in the default browser
################################################################################

# doftiles
# Description: Function to open the doftiles repository in the default browser
# Usage: doftiles
# Options:
#   -h    Display this help message

# Example: doftiles  ---Opens the doftiles repository in the default browser.

##########

# Function to open the doftiles repository in the default browser
function dotfiles() {
    if [ "$1" = "-h" ]; then
        echo "Description: Function to open the dotfiles repository in the default browser"
        echo "Usage: dotfiles"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi

    # Define the dotfiles repository URL
    dotfiles_url="https://github.com/iop098321qwe/dotfiles"

    # Open the dotfiles repository in the default browser
    xdg-open "$dotfiles_url"
}

################################################################################
# Create a function to set up directories
################################################################################

# Function to set up directories (Temporary, GitHub Repositories)
function setup_directories() {
    # Create the Temporary directory if it does not exist
    mkdir -p ~/Documents/Temporary

    # Create the GitHub Repositories directory if it does not exist
    mkdir -p ~/Documents/github_repositories
}

# Call the setup_directories function
setup_directories

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
    version_number=$VERSION
    echo -e "Now using \e[32mCustom Bash Commands\e[0m (by \e[35miop098321qwe\e[0m) \e[34mVersion:\e[0m \e[34m$version_number\e[0m"
    echo -e "You can show commands included with \e[36mcbcs [-h]\e[0m or typing \e[36mcommands\e[0m (\e[36mcomm\e[0m for shortcut)."
    echo -e "If you wish to stop using \e[32mCBC\e[0m, \e[31mremove\e[0m \e[33m.custom_bash_commands.sh\e[0m from your \e[33m.bashrc\e[0m file using \e[36meditbash\e[0m (\e[32mCBC\e[0m)."
    echo -e "Check out the Wiki for more information (or use \e[36mwiki\e[0m): \e[34mhttps://github.com/iop098321qwe/custom_bash_commands/wiki\e[0m"
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
        figlet -c -f future Custom Commands:
        echo "NOT CURRENTLY ALPHABETICAL"
        echo " "
        echo "  backup"
        echo "         Description: Create a backup file of a file"
        echo "         Usage: backup [file]"
        echo "  cbcs"
        echo "         Description: Display a list of all available custom commands in this script"
        echo "         Usage: cbcs [-h]"
        echo "  cls"
        echo "         Description: Clear the terminal screen and print the contents of the current directory"
        echo "         Usage: cls"
        echo "  cla"
        echo "         Description: Clear the terminal screen and print the contents of the current directory including hidden"
        echo "         Usage: cla"
        echo "  display_version,   (alias: dv)"
        echo "         Description: Display the version number from the .version file"
        echo "         Usage: display_version   (alias: dv)"
        echo "  rma"
        echo "         Description: Remove the directory and all files it contains"
        echo "         Usage: rma [directory]"
        echo "  editbash"
        echo "         Description: Open the .bashrc file in the default terminal text editor"
        echo "         Usage: editbash"
        echo "  seebash"
        echo "         Description: Display the contents of the .bashrc file"
        echo "         Usage: seebash"
        echo "  refresh"
        echo "         Description: Refresh the terminal session"
        echo "         Usage: refresh"
        echo "  gs"
        echo "         Description: Display the git status of the current directory"
        echo "         Usage: gs"
        echo "  x"
        echo "         Description: Make a file executable"
        echo "         Usage: x [file]"
        echo "  myip"
        echo "         Description: Display the IP address of the current machine"
        echo "         Usage: myip"
        echo "  mkcd"
        echo "         Description: Create a directory and switch into it"
        echo "         Usage: mkcd [directory]"
        echo "  mvfiles"
        echo "         Description: Move all files in a directory to subdirectories based on file type"
        echo "         Usage: mvfiles"
        echo "  up"
        echo "         Description: Move up one directory level"
        echo "         Usage: up [number of levels]"
        echo "  wiki"
        echo "         Description: Open the CBC wiki in the default browser"
        echo "         Usage: wiki"
        echo "  doftiles"
        echo "         Description: Open the doftiles repository in the default browser"
        echo "         Usage: doftiles"
        echo "  extract"
        echo "         Description: Extract compressed files"
        echo "         Usage: extract [file]"
        echo "  rmconf"
        echo "         Description: Remove the configuration file for CBC"
        echo "         Usage: rmconf"
        echo "  mkdirs"
        echo "         Description: Create a directory and switch into it"
        echo "         Usage: mkdirs [directory]"
        echo "  makeman"
        echo "         Description: Function to generate a PDF file from a man page"
        echo "         Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>
        echo " "
        echo "########################## SEPARATE ALIAS SECTION ######################################################"
        echo " "
        #figlet -f future -F border Available custom aliases:
        echo "  c"
        echo "         Description: Clear the terminal screen and display the version number from the .version file"
        echo "         Usage: c"
        echo "  cc"
        echo "         Description: Combine the git add/commit and git push process"
        echo "         Usage: cc [message] (Enter the commit message in quotes)" 
        echo "  commands"
        echo "         Description: Display a list of all available custom commands in this script"
        echo "         Usage: commands"
        echo "  comm"
        echo "         Description: Alias for 'commands'"
        echo "         Usage: comm"
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
        echo "  fman"
        echo "         Description: Fuzzy find a command and open the man page"
        echo "         Usage: fman"
        echo "  fcom"
        echo "         Description: Fuzzy find a command and run it"
        echo "         Usage: fcom"
        echo "  fcomexact"
        echo "         Description: Fuzzy find a command and run it using exact mode"
        echo "         Usage: fcomexact"
        echo "  fcome"
        echo "         Description: Alias for 'fcomexact'"
        echo "         Usage: fcome"
        echo "  fhelp"
        echo "         Description: Fuzzy find a command and display its help information"
        echo "         Usage: fhelp"
        echo "  fhelpexact"
        echo "         Description: Fuzzy find a command and display its help information using exact mode"
        echo "         Usage: fhelpexact"
        echo "  fhelpe"
        echo "         Description: Alias for 'fhelpexact'"
        echo "         Usage: fhelpe"
        echo "  historysearch"
        echo "         Description: Search using fuzzy finder in the command history"
        echo "         Usage: historysearch"
        echo "  historysearchexact"
        echo "         Description: Search using fuzzy finder in the command history using exact mode"
        echo "         Usage: historysearchexact"
        echo "  hs"
        echo "         Description: Alias for 'historysearch'"
        echo "         Usage: hs"
        echo "  hse"
        echo "         Description: Alias for 'historysearch' using exact mode"
        echo "         Usage: hse"
        echo "  hsearch"
        echo "         Description: Alias for 'historysearch'"
        echo "         Usage: hsearch"
        echo "  codecbc"
        echo "         Description: Open the custom_bash_commands directory in Visual Studio Code"
        echo "         Usage: codecbc"
        echo "  i"
        echo "         Description: Alias for 'sudo apt install -y'"
        echo "         Usage: i [package]"
        echo "  downloads"
        echo "         Description: Change to the Downloads directory and list its contents"
        echo "         Usage: downloads"
        echo "  dl"
        echo "         Description: Alias for 'downloads'"
        echo "         Usage: dl"
        echo "  ext"
        echo "         Description: Alias for extract function"
        echo "         Usage: ext [file]"
        echo "  vim"
        echo "         Description: Alias for 'nvim'"
        echo "         Usage: vim [file]"
        echo "  mv"
        echo "         Description: Alias for 'mv' with the '-i' option"
        echo "         Usage: mv [source] [destination]"
        echo "  cp"
        echo "         Description: Alias for 'cp' with the '-i' option"
        echo "         Usage: cp [source] [destination]"
        echo "  rm"
        echo "         Description: Alias for 'rm' with the '-i' option"
        echo "         Usage: rm [file]"
        echo "  ln"
        echo "         Description: Alias for 'ln' with the '-i' option"
        echo "         Usage: ln [source] [destination]"
        echo "  fobsidian"
        echo "         Description: Open a file from the Obsidian vault in Obsidian"
        echo "         Usage: fobsidian [file]"
        echo "  fobs"
        echo "         Description: Alias for 'fobsidian'"
        echo "         Usage: fobs [file]"
        echo "  z"
        echo "         Description: Alias for 'zellij'"
        echo "         Usage: z [options]"
        echo "  ch"
        echo "         Description: Alias for 'chezmoi'"
        echo "         Usage: ch [options]"
        echo "  chup"
        echo "         Description: Alias for 'chezmoi update'"
        echo "         Usage: chup"
        echo "  commands"
        echo "         Description: Display a list of all available custom commands in this script"
        echo "         Usage: commands"
        echo "  comm"
        echo "         Description: Alias for 'commands'"
        echo "         Usage: comm"
        echo "  fopen"
        echo "         Description: Fuzzy find a file and open it"
        echo "         Usage: fopen"
        echo "  fopenexact"
        echo "         Description: Fuzzy find a file and open it using exact mode"
        echo "         Usage: fopenexact"
        echo "  fo"
        echo "         Description: Alias for 'fopen'"
        echo "         Usage: fo"
        echo "  foe"
        echo "         Description: Alias for 'fopenexact'"
        echo "         Usage: foe"
    else
        # Display a list of all available custom commands and functions in this script
        echo " "
        figlet -c -f future Custom Commands:
        echo "Use cbcs [-h] with help flag to display descriptions and usage. (NOT CURRENTLY ALPHABETICAL)"
        echo " "
        echo "  display_version,   (alias: dv)"
        echo "  cbcs"
        echo "  rma"
        echo "  editbash"
        echo "  seebash"
        echo "  cls"
        echo "  cla"
        echo "  refresh"
        echo "  c"
        echo "  gs"
        echo "  x"
        echo "  myip"
        echo "  mkcd"
        echo "  mvfiles"
        echo "  backup"
        echo "  up"
        echo "  wiki"
        echo "  doftiles"
        echo "  extract"
        echo "  rmconf"
        echo "  mkdirs"
        echo "  makeman"
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
        echo "  fman"
        echo "  fcom"
        echo "  fcomexact"
        echo "  fcome"
        echo "  fhelp"
        echo "  fhelpexact"
        echo "  fhelpe"
        echo "  historysearch"
        echo "  historysearchexact"
        echo "  hs"
        echo "  hse"
        echo "  hsearch"
        echo "  codecbc"
        echo "  i"
        echo "  downloads"
        echo "  dl"
        echo "  ext"
        echo "  vim"
        echo "  mv"
        echo "  cp"
        echo "  rm"
        echo "  ln"
        echo "  fobsidian"
        echo "  fobs"
        echo "  z"
        echo "  ch"
        echo "  chup"
        echo "  commands"
        echo "  comm"
        echo "  fopen"
        echo "  fopenexact"
        echo "  fo"
        echo "  foe"
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
function backup() {
    if [ "$1" = "-h" ]; then
        echo "Description: This function allows you to create a backup file of a file."
        echo "Usage: backup [file]"
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
# MKDIRS
################################################################################

# Describe the mkdirs function and its options and usage

# mkdirs
# Description: A function to create a directory then switch into it
# Usage: mkdirs [directory]
# Options:
#   -h    Display this help message

# Example: mkdirs test  ---Creates a directory called test and switches into it.

##########

# Function to create a directory and switch into it
mkdirs() {
    # Check for the help flag
    if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
        # Display the help message
        echo "Description: A function to create a directory then switch into it"
        echo "Usage: mkdirs [directory]"
        echo "Options:"
        echo "  -h, --help    Display this help message"
        return
    fi

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
        echo "Description: A function to update the system and reboot if desired"
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
    # Define an array of commands to run
    commands=(
        "sudo apt update -y"
        "sudo apt upgrade -y"
        "sudo apt autoremove -y"
        "sudo apt autoclean"
        "sudo flatpak update -y"
        "sudo snap refresh"
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

# Describe the makeman function and its options and usage

# makeman
# Description: Function to generate a PDF file from a man page
# Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>
# Options:
#   -h           Display this help message
#   -f <file>    Specify a file with a list of commands
#   -o <dir>     Specify an output directory (default: ~/Documents/grymms_grimoires/command_manuals)
#   -r           Remove existing files in the output directory that are not listed in the specified file

# Example: makeman ls  ---Generates a PDF file for the 'ls' command manual.
# Example: makeman -f commands.txt -r  ---Generates PDF files for commands listed in 'commands.txt' and removes unlisted files.

##########

# Function to generate a PDF file from a man page or a list of commands
function makeman() {
    local file=""
    local output_dir="$HOME/Documents/grymms_grimoires/command_manuals"
    local command=""
    local remove_unlisted=false

    # Reset OPTIND to 1 to ensure option parsing starts correctly
    OPTIND=1

    # Parse options
    while getopts ":hf:o:r" opt; do
        case ${opt} in
            h )
                echo "Description: Function to generate a PDF file from a man page"
                echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
                echo "Options:"
                echo "  -h           Display this help message"
                echo "  -f <file>    Specify a file with a list of commands"
                echo "  -o <dir>     Specify an output directory (default: ~/Documents/grymms_grimoires/command_manuals)"
                echo "  -r           Remove existing files in the output directory that are not listed in the specified file"
                return 0
                ;;
            f )
                file=$OPTARG
                ;;
            o )
                output_dir=$OPTARG
                ;;
            r )
                remove_unlisted=true
                ;;
            \? )
                echo "Invalid option: -$OPTARG" >&2
                echo "Usage: makeman [-h] [-f <file>] [-o <output_directory>] [-r] <command>"
                return 1
                ;;
            : )
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
        if ! man -w "$cmd" &> /dev/null; then
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
            [ -z "$cmd" ] && continue  # Skip empty lines
            cmd_list+=("$cmd")
            process_command "$cmd"
        done < "$file"
        
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

# Example usage:
# makeman ls
# makeman -f commands.txt
# makeman -o /custom/output/directory ls
# makeman -f commands.txt -r

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
# EXTRACT
################################################################################

# Describe the extract function and its options and usage

# extract
# Description: A function to extract compressed files
# Alias: ext
# Usage: extract [file]
# Options:
#   -h    Display this help message

# Example: extract file.tar.gz  ---Extracts the file file.tar.gz.

##########

# Function to extract compressed files
function extract() {
    if [ "$1" = "-h" ]; then
        echo "Description: A function to extract compressed files"
        echo "Usage: extract [file]"
        echo "Options:"
        echo "  -h    Display this help message"
        return
    fi

    if [ -z "$1" ]; then
        echo "Error: No file specified"
        return 1
    fi

    if [ ! -f "$1" ]; then
        echo "Error: File not found"
        return 1
    fi

    case "$1" in
        *.tar.bz2)   tar xjf "$1"     ;;
        *.tar.gz)    tar xzf "$1"     ;;
        *.bz2)       bunzip2 "$1"      ;;
        *.rar)       unrar x "$1"      ;;
        *.gz)        gunzip "$1"       ;;
        *.tar)       tar xf "$1"      ;;
        *.tbz2)      tar xjf "$1"     ;;
        *.tgz)       tar xzf "$1"     ;;
        *.zip)       unzip "$1"        ;;
        *.Z)         uncompress "$1"   ;;
        *.7z)        7z x "$1"         ;;
        *.deb)       ar x "$1"         ;;
        *.tar.xz)    tar xf "$1"     ;;
        *.tar.zst)   unzstd "$1"     ;;
        *)           echo "'$1' cannot be extracted using extract()" ;;
    esac
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

function mvfiles() {
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
# ALIASES
###################################################################################################################################################################

# Direct alias declarations
alias docs='cd ~/Documents && ls'
alias home='cd ~ && ls'
alias back='cd .. && ls'
alias cdgh='cd ~/Documents/github_repositories && ls'
alias temp='cd ~/Documents/Temporary && ls'
alias cbc='cdgh && cd custom_bash_commands && ls'
alias cbcc='cdgh && cd custom_bash_commands && ls && dv && cc'
alias rma='rm -rfi'
alias editbash='nvim ~/.bashrc'
alias seebash='batcat ~/.bashrc'
alias cls='clear && di && ls'
alias cla='clear && di && la'
alias refresh='source ~/.bashrc && clear && di'
alias c='clear && di'
alias gs='git status'
alias x='chmod +x'
alias myip='curl http://ipecho.net/plain; echo'
alias rfc='remove_figlet_config'
alias rnc='remove_neofetch_config'
alias rsc='remove_session_id_config'
alias dv='display_version'
alias rdvc='remove_display_version_config'
alias racc='remove_all_cbc_configs'
#alias testcbc='source ~/.test_update_commands.sh; source ~/.test_custom_bash_commands.sh'
alias gsw='git switch'
alias gswm='git switch master'
alias gswt='git switch test'
alias fh='filehash'
alias di='display_info'
alias py='python3'
alias python='python3'
alias rh='regex_help'
alias dt='cd ~/Documents/Deeptree && ls'
alias dtr='cd ~/Documents/Deeptree/reference_material && ls'
alias dispatch='cd ~/Documents/Deeptree/reference_material/dispatch && ls'
alias ucbc='updatecbc'
alias fzf='fzf -m'
alias fman='compgen -c | fzf | xargs man'
alias historysearch='history | sort -nr | fzf -m --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias historysearchexact='history | sort -nr | fzf -m -e --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias hsearch='historysearch'
alias hs='historysearch'
alias hse='historysearchexact'
alias fcom='eval "$(compgen -c | fzf)"'
alias fcomexact='eval "$(compgen -c | fzf -e)"'
alias fcome='fcomexact'
alias fhelp='eval "$(compgen -c | fzf)" -h'
alias fhelpexact='eval "$(compgen -c | fzf -e)" -h'
alias fhelpe='fhelpexact'
alias codecbc='code ~/Documents/github_repositories/custom_bash_commands/'
alias i='sudo apt install -y'
alias downloads='cd ~/Downloads && la'
alias dl='downloads'
alias ext='extract'
alias vim='nvim'
alias mv='mv -i'
alias cp='cp -i'
alias rm='rm -i'
alias ln='ln -i'
alias fobsidian='find ~/Documents/grymms_grimoires -type f | fzf | xargs -I {} obsidian "obsidian://open?vault=$(basename ~/Documents/grymms_grimoires)&file={}"'
alias fobs='fobsidian'
alias z='zellij'
alias ch='chezmoi'
alias chup='chezmoi update'
alias commands='cbcs -h | batcat'
alias comm='commands'
alias fopen='fzf --multi | xargs -r -I {} open "{}"'
alias fopenexact='fzf --multi | xargs -r -I {} open "{}"'
alias fo='fopen'
alias foe='fopenexact'

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
    figlet -f future Welcome to custom bash commands!
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
# Ensure that ranger is installed, and if not install it.
###################################################################################################################################################################

# Function to check if ranger is installed and install it if necessary
function check_install_ranger() {
    if ! command -v ranger &> /dev/null; then
        echo "ranger not found. Installing..."
        sleep 3
        sudo apt install ranger -y
        echo "Please use 'refresh' to refresh the terminal"
    fi
}

###################################################################################################################################################################
# Ensure thefuck is installed, and if not install it.
###################################################################################################################################################################

# Function to check if thefuck is installed and install it if necessary
function check_install_thefuck() {
    if ! command -v thefuck &> /dev/null; then
        echo "thefuck not found. Installing..."
        sleep 3
        sudo apt update
        sudo apt install python3-dev python3-pip python3-setuptools
        pip3 install thefuck --user
    fi
}

###################################################################################################################################################################
# Ensure obsidian is installed, and if not install it.
###################################################################################################################################################################

# Function to check if obsidian is installed and install it if necessary
function check_install_obsidian() {
    if ! command -v obsidian &> /dev/null; then
        echo "obsidian not found. Installing..."
        sleep 3
        sudo snap install obsidian --classic
        sudo apt install ripgrep -y
        sudo apt install xclip
        git clone --depth 1 https://github.com/wbthomason/packer.nvim ~/.local/share/nvim/site/pack/packer/start/packer.nvim
        echo "Obsidian installed. Please use 'refresh' to refresh the terminal."
        git clone https://github.com/iop098321qwe/grymms_grimoires.git ~/Documents/
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
        echo "Neovim not found. Please install from https://github.com/neovim/neovim/releases"
        echo "Download the nvim.appimage file, use 'chmod +x nvim.appimage' to make it executable, and run 'sudo mv nvim.appimage /bin/nvim' to install."

        # Download the neovim appimage file
        wget https://github.com/neovim/neovim/releases/download/v0.10.0/nvim.appimage

        # Make the appimage file executable
        chmod +x nvim.appimage

        # Move the appimage file to /bin/nvim
        sudo mv nvim.appimage /bin/nvim        
    fi

    # Set the default editor to neovim if and only if neovim is installed and set manpager as neovim
    if command -v nvim &> /dev/null; then
        export EDITOR=nvim
        export MANPAGER="nvim +Man!"
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
# Check if starship is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if starship is installed and install it if not
function check_install_starship() {
    if ! command -v starship &> /dev/null; then
        echo "Starship not found. Installing..."
        curl -sS https://starship.rs/install.sh | sh
        echo "Starship has been installed."
    fi
}

# Call the function to check if starship is installed and install it if necessary
check_install_starship

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
# Check if vscode is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if vscode is installed and install it if not
function check_install_vscode() {
    if ! command -v code &> /dev/null; then
        echo "VSCode not found. Installing..."
        sudo snap install code --classic
        echo "VSCode has been installed."
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
# Check if hstr is installed, and if not, install it.
###################################################################################################################################################################

# Function to check if hstr is installed and install it if not
function check_install_hstr() {
    if ! command -v hstr &> /dev/null; then
        echo "Hstr not found. Installing..."
        sudo apt install hstr -y
        echo "hstr has been installed."
    fi
}

# If hstr is installed, set configs for hstr
if command -v hstr &> /dev/null; then
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
#        sudo apt install "$line" -y
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
    if [[ "${BTOP:=false}" == "true" ]]; then
        # Call the function to check btop installation and install btop
        check_install_btop
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

# Read the configuration file and check if VSCODE=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "${VSCODE:=false}" == "true" ]]; then
        # Call the function to check vscdoe installation and install vscode
        check_install_vscode
    fi
fi

# Read the configuration file and check if ZELLI=true
if [[ -f "$CONFIG_FILE" ]]; then
    source "$CONFIG_FILE"
    if [[ "${ZELLI:=false}" == "true" ]]; then
        # Call the function to check zellij installation and install zellij
        check_install_zellij
    fi
fi

# Check if zoxide is installed, and if it is, source the zoxide init script
if command -v zoxide &> /dev/null; then
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

###################################################################################################################################################################
###################################################################################################################################################################
# ZELLIJ COMPLETION
###################################################################################################################################################################
###################################################################################################################################################################

_zellij() {
    local i cur prev opts cmds
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    cmd=""
    opts=""

    for i in ${COMP_WORDS[@]}
    do
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
            *)
                ;;
        esac
    done

    case "${cmd}" in
        zellij)
            opts="-h -V -s -l -c -d --help --version --max-panes --data-dir --server --session --layout --config --config-dir --debug options setup list-sessions list-aliases attach kill-session delete-session kill-all-sessions delete-all-sessions action run plugin edit convert-config convert-layout convert-theme pipe help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 1 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action)
            opts="-h --help write write-chars resize focus-next-pane focus-previous-pane move-focus move-focus-or-tab move-pane move-pane-backwards clear dump-screen dump-layout edit-scrollback scroll-up scroll-down scroll-to-bottom scroll-to-top page-scroll-up page-scroll-down half-page-scroll-up half-page-scroll-down toggle-fullscreen toggle-pane-frames toggle-active-sync-tab new-pane edit switch-mode toggle-pane-embed-or-floating toggle-floating-panes close-pane rename-pane undo-rename-pane go-to-next-tab go-to-previous-tab close-tab go-to-tab go-to-tab-name rename-tab undo-rename-tab new-tab move-tab previous-swap-layout next-swap-layout query-tab-names start-or-reload-plugin launch-or-focus-plugin launch-plugin rename-session pipe list-clients help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__clear)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__close__pane)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__close__tab)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__dump__layout)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__dump__screen)
            opts="-f -h --full --help <PATH>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__edit)
            opts="-d -l -f -i -x -y -h --direction --line-number --floating --in-place --cwd --x --y --width --height --help <FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__edit__scrollback)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__focus__next__pane)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__focus__previous__pane)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__go__to__next__tab)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__go__to__previous__tab)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__go__to__tab)
            opts="-h --help <INDEX>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__go__to__tab__name)
            opts="-c -h --create --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__half__page__scroll__down)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__half__page__scroll__up)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__help)
            opts="<SUBCOMMAND>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__launch__or__focus__plugin)
            opts="-f -i -m -c -s -h --floating --in-place --move-to-focused-tab --configuration --skip-plugin-cache --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__launch__plugin)
            opts="-f -i -c -s -h --floating --in-place --configuration --skip-plugin-cache --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__list__clients)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__move__focus)
            opts="-h --help <DIRECTION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__move__focus__or__tab)
            opts="-h --help <DIRECTION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__move__pane)
            opts="-h --help <DIRECTION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__move__pane__backwards)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__move__tab)
            opts="-h --help <DIRECTION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__new__pane)
            opts="-d -p -f -i -n -c -s -x -y -h --direction --plugin --cwd --floating --in-place --name --close-on-exit --start-suspended --configuration --skip-plugin-cache --x --y --width --height --help <COMMAND>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__new__tab)
            opts="-l -n -c -h --layout --layout-dir --name --cwd --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__next__swap__layout)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__page__scroll__down)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__page__scroll__up)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__pipe)
            opts="-n -a -p -c -l -s -f -i -w -t -h --name --args --plugin --plugin-configuration --force-launch-plugin --skip-plugin-cache --floating-plugin --in-place-plugin --plugin-cwd --plugin-title --help <PAYLOAD>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__previous__swap__layout)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__query__tab__names)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__rename__pane)
            opts="-h --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__rename__session)
            opts="-h --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__rename__tab)
            opts="-h --help <NAME>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__resize)
            opts="-h --help <RESIZE> <DIRECTION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__scroll__down)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__scroll__to__bottom)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__scroll__to__top)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__scroll__up)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__start__or__reload__plugin)
            opts="-c -h --configuration --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__switch__mode)
            opts="-h --help <INPUT_MODE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__toggle__active__sync__tab)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__toggle__floating__panes)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__toggle__fullscreen)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__toggle__pane__embed__or__floating)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__toggle__pane__frames)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__undo__rename__pane)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__undo__rename__tab)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__write)
            opts="-h --help <BYTES>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__action__write__chars)
            opts="-h --help <CHARS>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__attach)
            opts="-c -b -f -h --create --create-background --index --force-run-commands --help <SESSION_NAME> options help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__attach__help)
            opts="<SUBCOMMAND>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__attach__options)
            opts="-h --disable-mouse-mode --no-pane-frames --simplified-ui --theme --default-mode --default-shell --default-cwd --default-layout --layout-dir --theme-dir --mouse-mode --pane-frames --mirror-session --on-force-close --scroll-buffer-size --copy-command --copy-clipboard --copy-on-select --scrollback-editor --session-name --attach-to-session --auto-layout --session-serialization --serialize-pane-viewport --scrollback-lines-to-serialize --styled-underlines --serialization-interval --disable-session-metadata --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 3 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__convert__config)
            opts="-h --help <OLD_CONFIG_FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__convert__layout)
            opts="-h --help <OLD_LAYOUT_FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__convert__theme)
            opts="-h --help <OLD_THEME_FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__delete__all__sessions)
            opts="-y -f -h --yes --force --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__delete__session)
            opts="-f -h --force --help <TARGET_SESSION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__edit)
            opts="-l -d -i -f -x -y -h --line-number --direction --in-place --floating --cwd --x --y --width --height --help <FILE>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__help)
            opts="<SUBCOMMAND>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__kill__all__sessions)
            opts="-y -h --yes --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__kill__session)
            opts="-h --help <TARGET_SESSION>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__list__aliases)
            opts="-h --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__list__sessions)
            opts="-n -s -r -h --no-formatting --short --reverse --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
                return 0
            fi
            case "${prev}" in
                *)
                    COMPREPLY=()
                    ;;
            esac
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__options)
            opts="-h --disable-mouse-mode --no-pane-frames --simplified-ui --theme --default-mode --default-shell --default-cwd --default-layout --layout-dir --theme-dir --mouse-mode --pane-frames --mirror-session --on-force-close --scroll-buffer-size --copy-command --copy-clipboard --copy-on-select --scrollback-editor --session-name --attach-to-session --auto-layout --session-serialization --serialize-pane-viewport --scrollback-lines-to-serialize --styled-underlines --serialization-interval --disable-session-metadata --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__pipe)
            opts="-n -a -p -c -h --name --args --plugin --plugin-configuration --help <PAYLOAD>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__plugin)
            opts="-c -f -i -s -x -y -h --configuration --floating --in-place --skip-plugin-cache --x --y --width --height --help <URL>"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__run)
            opts="-d -f -i -n -c -s -x -y -h --direction --cwd --floating --in-place --name --close-on-exit --start-suspended --x --y --width --height --help <COMMAND>..."
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
        zellij__setup)
            opts="-h --dump-config --clean --check --dump-layout --dump-swap-layout --dump-plugins --generate-completion --generate-auto-start --help"
            if [[ ${cur} == -* || ${COMP_CWORD} -eq 2 ]] ; then
                COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
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
            COMPREPLY=( $(compgen -W "${opts}" -- "${cur}") )
            return 0
            ;;
    esac
}

complete -F _zellij -o bashdefault -o default zellij
function zr () { zellij run --name "$*" -- bash -ic "$*";}
function zrf () { zellij run --name "$*" --floating -- bash -ic "$*";}
function zri () { zellij run --name "$*" --in-place -- bash -ic "$*";}
function ze () { zellij edit "$*";}
function zef () { zellij edit --floating "$*";}
function zei () { zellij edit --in-place "$*";}
function zpipe () { 
  if [ -z "$1" ]; then
    zellij pipe;
  else 
    zellij pipe -p $1;
  fi
}

###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
###################################################################################################################################################################
# word
