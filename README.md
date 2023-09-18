# Custom Bash Commands Instructions

## Follow the instructions below to add to path.

* [Best Option (Linux)](https://medium.com/devnetwork/how-to-create-your-own-custom-terminal-commands-c5008782a78e)
* [More Info](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom)
* [Even More Info](https://betterprogramming.pub/create-custom-terminal-commands-or-shortcuts-alias-8cc8b2c3f45b)

### Current configuration:

* Set up .bashrc in the <user> directory (with hidden files) with the `source ~/.custom_bash_commands.sh` appended to the end.
* Ensure the most up-to-date version of the github repository is added to the user file (with hidden files).
* Open a new terminal as this will not work without the .bashrc file being reloaded.
* You can also optionally run `source .bashrc` to refresh the .bashrc file. (or `source .bash_profile`)

#### Additional Alias options:

* Append `alias docs="cd ~/Documents"` to the end of the .bashrc file in the <user> directory.
* Append `alias ...="cd ~"` to the end of the .bashrc file in the <user> directory.
* Append `alias back="cd .."` to the end of the .bashrc file in the <user> directory.

## Additional Plans:

* Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.
* Add a command to automatically update/copy the most recent version of the file into the <user> directory.