#!/bin/bash

# Verify that the current directory is the custom_bash_commands directory in the path ~/Documents/github_repositories/custom_bash_commands
if [ "$PWD" != "$HOME/Documents/github_repositories/custom_bash_commands" ]; then
  echo "##########################################################################################"
  echo "## ERROR: Current directory is NOT ~/Documents/github_repositories/custom_bash_commands ##"
  echo "##########################################################################################"
  echo ""
  echo "Please ensure that the git repository is cloned to the correct location."
  echo "It is currently important for functionality of the Custom Bash Commands."
  echo ""
  echo "##########################################################################################"
  exit 1
else
  echo "Verified Custom Bash Commands Directory Successfully placed"
fi

# Copy the custom_bash_commands.sh script to the home directory and make executable
cp custom_bash_commands.sh ~/.custom_bash_commands.sh && chmod +x ~/.custom_bash_commands.sh
echo "Copied custom_bash_commands.sh to home directory"

# Copy the cbc_aliases.sh script to the home directory and make executable
cp cbc_aliases.sh ~/.cbc_aliases.sh && chmod +x ~/.cbc_aliases.sh
echo "Copied cbc_aliases.sh to home directory"

# Add source command to .bashrc file if missing
touch ~/.bashrc
if ! grep -qx "source ~/.custom_bash_commands.sh" ~/.bashrc; then
  echo "source ~/.custom_bash_commands.sh" >>~/.bashrc
  echo "Added source command to .bashrc"
else
  echo "Source command already present in .bashrc"
fi

# Countdown from 5 seconds
echo "Refreshing in 5 seconds..."
for i in {5..1}; do
  echo -ne "$i\r"
  sleep 1
done

# Source the .bashrc file
source ~/.bashrc
