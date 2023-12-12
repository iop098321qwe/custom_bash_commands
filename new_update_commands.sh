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

# Print completion message
echo "Custom bash commands updated successfully."


