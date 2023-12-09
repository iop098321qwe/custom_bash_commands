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
* Append `alias gs='git status'` to the end of the `.bashrc` file in the <user> directory.
    * This will get the status of the git repository you are in quickly.
* Append `alias editbash='code ~/.bashrc && source ~/.bashrc'` to the end of the `.bashrc` file in the <user> directory.

#### Additional Function options:

Add to the end of the `.bashrc` file:
```bash
# Custom function to make directories and switch into it, and move into the deepest directory created.
function mkcd() {
  mkdir -p "$1" && cd "$1"
}
```
This will create a function to make a directory or directories and change into the deepest created directory.
###### Syntax `mkcd <directory1>/<directory2>` (Example: `mkcd project/project_notes`)

---

Add to the end of the `.bashrc` file: 
```bash
# Function to create a backup file of a file.
function bkup() {
  cp "$1" "${1}.bak"
}
```
This will create a backup file of the file chosen in the same directory.
###### Syntax: `bkup <filename>` (Example: `bkup testfile.odt`)

---

Add to the end of the `.bashrc` file:
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

## Additional Plans:

* Add the alias functions above into the .custom_bash_commands.sh file for simple one file upload.
* ~~Add a command to automatically update/copy the most recent version of the file into the <user> directory.~~
* Add a smart function to automatically check if there were any updates before performing the automatic update of the .custom_bash_commands.sh script in the ~/ directory.
* Add descriptions for alias' and custom functions in the README.md file.

# To Test

* Change the `.bashrc` file to read `source ~/.test_update_commands.sh`
* Run the terminal and verify the testing works by opening the .custom_bash_commands.sh in the user directory.
* Change the `.bashrc` file to read `source ~/.update_commands.sh` if it is not working.

# Useful Commands to Remember:

* `neofetch`: graphically shows system information with a beautiful output and ASCII Art of the Desktop Environment installed on Linux.