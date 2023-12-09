# Custom Bash Commands Instructions

## Follow the instructions below to add to path.

* [Best Option (Linux)](https://medium.com/devnetwork/how-to-create-your-own-custom-terminal-commands-c5008782a78e)
* [More Info](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom)
* [Even More Info](https://betterprogramming.pub/create-custom-terminal-commands-or-shortcuts-alias-8cc8b2c3f45b)

### Current configuration:

* Set up `.bashrc` in the <user> directory (with hidden files) with the `source ~/.custom_bash_commands.sh` appended to the end.
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

## Additional Plans:

* Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.
* ~~Add a command to automatically update/copy the most recent version of the file into the <user> directory.~~
 * Add `-q` for quiet output for `cc`.
 * Add a smart function to automatically check if there were any updates before performing the automatic update of the .custom_bash_commands.sh script in the ~/ directory.

 # To Test

 * Change the `.bashrc` file to read `source ~/.test_update_commands.sh`
 * Run the terminal and verify the testing works by opening the .custom_bash_commands.sh in the user directory.
 * Change the `.bashrc` file to read `source ~/.update_commands.sh` if it is not working.