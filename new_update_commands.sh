#!/bin/bash

# Copy the custom_bash_commands.sh script to the home directory and make executable
cp custom_bash_commands.sh ~/.custom_bash_commands.sh && chmod +x ~/.custom_bash_commands.sh
echo "Copied custom_bash_commands.sh"

# Copy the update_commands.sh script to the home directory and make executable
cp update_commands.sh ~/.update_commands.sh && chmod +x ~/.update_commands.sh
echo "Copied update_commands.sh"

# Copy the .version file to the home directory
cp .version ~/.version
echo "Copied .version"

# Create several folders (temporary, update_logs, github_repositories, ai) in the ~/Documents folder
mkdir -p ~/Documents/update_logs ~/Documents/github_repositories ~/Documents/ai
echo "Created ~/Documents/update_logs, ~/Documents/github_repositories, ~/Documents/ai"
# Create a folder (temporary) in the home directory
mkdir -p ~/temporary
echo "Created ~/temporary"

# Verify that the current directory is the custom_bash_commands directory in the path ~/Documents/github_repositories/custom_bash_commands
if [ "$PWD" != "$HOME/Documents/github_repositories/custom_bash_commands" ]; then
    echo "##########################################################################################"
    echo "## ERROR: Current directory is NOT ~/Documents/github_repositories/custom_bash_commands ##"
    echo "##########################################################################################"
    exit 1
else
    echo "Custom Bash Commands directory successfully placed"
fi

# Print completion message
echo "Custom bash commands updated successfully."


