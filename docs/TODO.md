# TODO

## Not Complete

* [ ] Update `up` command to work properly.
  * [ ] Allow multiple levels of moving up with the command.
  * [ ] Ensure that flags are working properly.
* [ ] Update `cc` command to be more interactive and optionally automatically push.
* [ ] Change the update process to be a single command rather than a separate script that runs using `updatecbc` or `ucbc` natively.
* [ ] Change `test` to a command rather than an alias for more testing options.
* [ ] Consolidate the config files for optional items.
* [ ] Edit `odt` command to create a .odt file and open it in the directory specified and prompt to name it.
* [ ] Edit `ods` command to create a .ods file and open it in the directory specified and prompt to name it.
* [ ] Ensure that all custom commands have the "-h" help flag functionality.
* [ ] Create a command to display information from "Shortcut-Terminal_Documentation" in the terminal for easy referencing.
* [ ] Update cbcc commands and definition for calling aliases.
* [ ] Create a script to install all the necessary files and assist with setting up for the first time, including optional add-ons.
  * [ ] zoxide
  * [ ] fzf
  * [ ] neofetch
  * [ ] session ID
  * [ ] display info command
  * [ ] figlet
  * [ ] neovim
  * [ ] tldr (short manuals)
  * [ ] Pika Backup (?) (file backups)
  * [ ] Timeshift (?) (system snapshots)
  * [ ] (some type of better terminal history manager)
  * [ ] GNU Stow (dotfile farm manager)
  * [ ] eza (better ls command)
    * [ ] Set up to optionally display info on terminal start, or by using command only.
    * [ ] Set up to configure the display info command settings.
  * [ ] Ranger (terminal file manager)
  * [ ] Modularize the code better.
* [ ] Build a wiki to keep information organized.
* [ ] Build an SOP for documenting changes.
* [ ] Create a list of commands (Useful Commands to Remember) that can be displayed using a command, potentially in the help command for CBC.
  * [ ] The idea is to have additional tools not created with the script to install additionally and display information about.
* [ ] Set up `readme` command to open the default browser directly to the README.md page for CBC.

## Complete

* [x] Create command to test commands.
* [x] Create a command to toggle between the `master` and `test` branches for easy testing.
* [x] Build a SOP for creating new functions/aliases.
* [x] Set up zoxide and fzf automatic installation with setup.
* [x] Set up `wiki` command to open default browser directly to the wiki page for CBC.
* [x] Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.
* [x] Add a command to automatically update/copy the most recent version of the file into the <user> directory.
* [x] Add a smart function to automatically check if there were any updates before performing the automatic update of the .custom_bash_commands.sh script in the ~/ directory.
* [x] Add descriptions for alias' and custom functions in the README.md file.
* [x] Move all functions and alias' to the `custom_bash_commands.sh` script for easy transferral and one file to manage them all.
* [x] Create a test workflow for testing the custom commands.
* [x] Change the figlet command to prompt the user for a username on first run, then run the command when the custom_bash_commands.sh script is loaded.
* [x] Create a function to change the figlet configuration.
