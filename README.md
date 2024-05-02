# Custom Bash Commands Instructions

* [Add to Path](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#follow-the-instructions-below-to-add-to-path)
* [Current Configuration](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#current-configuration)
* [Old Method](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#old-method)
* [New Method](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#new-method)
* [Functions](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#functions)
* [Aliases](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#aliases)
* [Additional Plans](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#additional-plans)
* [To Test](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#to-test)
* [Useful Commands to Remember](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#useful-commands-to-remember)

## Follow the instructions below to add to path.

* [Best Option (Linux)](https://medium.com/devnetwork/how-to-create-your-own-custom-terminal-commands-c5008782a78e)
* [More Info](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom)
* [Even More Info](https://betterprogramming.pub/create-custom-terminal-commands-or-shortcuts-alias-8cc8b2c3f45b)

### Current configuration:

#### OLD METHOD:
* Set up `.bashrc` in the home directory (with hidden files) with the `source ~/.custom_bash_commands.sh` appended to the end.
    * To open the `.bashrc` file, use this command in the Terminal: `open .bashrc`
* Ensure the most up-to-date version of the github repository is added to the user file (with hidden files).
* Open a new terminal as this will not work without the `.bashrc` file being reloaded.
* You can also optionally run `source .bashrc` to refresh the `.bashrc` file. (or `source .bash_profile`).
* There is a .update_commands.sh script that will run at the start of every terminal open that will automatically update to the latest version of the custom_bash_commands.sh file and add it to the correct directory
* This is done by creating a temporary directory, then initializing and cloning the github repo in it, then copying the file to the correct location, then delete itself.
* This ensures that every time you run the terminal you have the latest version of the custom commands already installed.

#### NEW METHOD:
* Append the following code to the end of the `.bashrc` file.
```bash
###################################################################################################################################################################
# Custom Additions
###################################################################################################################################################################

source ~/.update_commands.sh
source ~/.custom_bash_commands.sh
```
* This can be done using the `editbash` command after it has been initially installed.

#### Functions:

**INCOMPLETE**

A full list of functions will be added here for reference of what the script offers along with a short description.

#### Aliases:

**INCOMPLETE**

A full list of aliases will be added here for reference of what the script offers along with a short description.

## Additional Plans:

* ~~Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.~~
* ~~Add a command to automatically update/copy the most recent version of the file into the <user> directory.~~
* Add a smart function to automatically check if there were any updates before performing the automatic update of the .custom_bash_commands.sh script in the ~/ directory.
* ~~Add descriptions for alias' and custom functions in the README.md file.~~
* ~~Move all functions and alias' to the `custom_bash_commands.sh` script for easy transferral and one file to manage them all.~~
* Create a test workflow for testing the custom commands.
* ~~Change the figlet command to prompt the user for a username on first run, then run the command when the custom_bash_commands.sh script is loaded.~~
* ~~Create a function to change the figlet configuration.~~
* Consolidate the config files for optional items.
* Edit `odt` command to create a .odt file and open it in the directory specified and prompt to name it
* Edit `ods` command to create a .ods file and open it in the directory specified and prompt to name it
* Ensure that all custom commands have the "-h" help flag functionality.
* Create a command to toggle between the `master` and `test` branches for easy testing.
* Create a command to display information from "Shortcut-Terminal_Documentation" in the terminal for easy referencing.
* Update cbcc commands and definition for calling aliases.
* Create a script to install all the necessary files and assist with setting up for the first time, including optional add-ons.
    * zoxide
    * fzf
    * neofetch
    * session ID
    * display info command
    * figlet
    * neovim
    * tldr (short manuals)
    * Pika Backup (?) (file backups)
    * Timeshift (?) (system snapshots)
    * (some type of better terminal history manager)
    * GNU Stow (dotfile farm manager)
    * eza (better ls command)
        * Set up to optionally display info on terminal start, or by using command only
        * Set up to configure the display info command settings
    * Modularize the code better.
* Build a wiki to keep information organized.
* Build a SOP for creating new functions/aliases.
* Build an SOP for documenting changes.
* Create a list of commands (Useful Commands to Remember) that can be displayed using a command, potentially in the help command for CBC.
   * The idea is to have additional tools not created with the script to install additionally and display information about.
* ~~Set up zoxide and fzf automatic installation with setup.~~
* Set up `wiki` command to open default browser directly to the wiki page for CBC
* Set up `readme` command to open the default browser directly to the README.md page for CBC

# To Test

* Change the `.bashrc` file to read `source ~/.test_update_commands.sh`
* Run the terminal and verify the testing works by opening the .custom_bash_commands.sh in the user directory.
* Change the `.bashrc` file to read `source ~/.update_commands.sh` if it is not working.

# Useful Commands to Remember:

* `neofetch`: graphically shows system information with a beautiful output and ASCII Art of the Desktop Environment installed on Linux.
* `rsync`: tool to synchronize directories or files.
* `htop`: interactive and real-time view of the processes running on a syste
    * `btop`: alternative to htop that has better formatting
