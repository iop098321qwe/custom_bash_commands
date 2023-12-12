#!/bin/bash

# Copy scripts from the local repository to the home directory and make executable
cp custom_bash_commands.sh ~/.custom_bash_commands.sh && chmod +x ~/.custom_bash_commands.sh
cp update_commands.sh ~/.update_commands.sh && chmod +x ~/.update_commands.sh

# Copy the .version file to the home directory
cp .version ~/.version

# Print completion message
echo "Custom bash commands updated successfully."


