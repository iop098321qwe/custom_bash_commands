![Logo](cbc_logo_00001.png)

# Custom Bash Commands Instructions

- [Add to Path](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#follow-the-instructions-below-to-add-to-path)
- [Current Configuration](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#current-configuration)
- [Old Method](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#old-method)
- [New Method](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#new-method)
- [Functions](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#functions)
- [Aliases](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#aliases)
- [Additional Plans](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#additional-plans)
- [To Test](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#to-test)
- [Useful Commands to Remember](https://github.com/iop098321qwe/custom_bash_commands?tab=readme-ov-file#useful-commands-to-remember)

## Follow the instructions below to add to path

- [Best Option (Linux)](https://medium.com/devnetwork/how-to-create-your-own-custom-terminal-commands-c5008782a78e)
- [More Info](https://gitbetter.substack.com/p/automate-repetitive-tasks-with-custom)
- [Even More Info](https://betterprogramming.pub/create-custom-terminal-commands-or-shortcuts-alias-8cc8b2c3f45b)

### Current configuration

#### OLD METHOD

- Set up `.bashrc` in the home directory (with hidden files) with the `source ~/.custom_bash_commands.sh` appended to the end
  - To open the `.bashrc` file, use this command in the Terminal: `open .bashrc`
- Ensure the most up-to-date version of the github repository is added to the user file (with hidden files).
- Open a new terminal as this will not work without the `.bashrc` file being reloaded.
- You can also optionally run `source .bashrc` to refresh the `.bashrc` file. (or `source .bash_profile`).
- There is a .update_commands.sh script that will run at the start of every terminal open that will automatically update to the latest version of the custom_bash_commands.sh file and add it to the correct directory.
- This is done by creating a temporary directory, then initializing and cloning the github repo in it, then copying the file to the correct location, then delete itself.
- This ensures that every time you run the terminal you have the latest version of the custom commands already installed.

#### NEW METHOD

- Append the following code to the end of the `.bashrc` file.

```bash
###################################################################################################################################################################
# Custom Additions
###################################################################################################################################################################

source ~/.update_commands.sh
source ~/.custom_bash_commands.sh
```

- This can be done using the `editbash` command after it has been initially installed.

#### Functions

**INCOMPLETE**
A full list of functions will be added here for reference of what the script offers along with a short description.

#### Aliases

**INCOMPLETE**
A full list of aliases will be added here for reference of what the script offers along with a short description.

## Visit the TODO.md file for additional plans

[TODO](docs/TODO.md)

# Adjusting settings on Linux

## Installing Kitty Terminal Emulator

- Install the kitty terminal emulator.
- Adjust the default application settings to `kitty` for terminal emulator.
- Set the terminal shortcuts to `Ctrl + Alt + T` for kitty.
  - In Settings > Shortcuts, add the `kitty` application.
  - Change the custom shortcut.
  - Select 'okay' if it prompts to override Konsole.

# Create a command to update the custom commands script instead of using an automatic script

# To Test

- Change the `.bashrc` file to read `source ~/.test_update_commands.sh`
- Run the terminal and verify the testing works by opening the .custom_bash_commands.sh in the user directory.
- Change the `.bashrc` file to read `source ~/.update_commands.sh` if it is not working.

# Useful Commands to Remember

- `neofetch`: graphically shows system information with a beautiful output and ASCII Art of the Desktop Environment installed on Linux.
- `rsync`: tool to synchronize directories or files.
- `htop`: interactive and real-time view of the processes running on a system
  - `btop`: alternative to htop that has better formatting

ADD

```bash
alias fobsidian='find ~/Documents/grymms_grimoires -type f | fzf | xargs -I {} obsidian "obsidian://open?vault=$(basename ~/Documents/grymms_grimoires)&file={}'
alias fobs='fobsidian'
```
