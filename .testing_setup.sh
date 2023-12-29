#!/bin/bash

# Create a script to run when I want to update the test version of the custom_bash_commands.sh script
# This script will copy the custom_bash_commands.sh script to the home directory and make executable
# This script will copy the update_commands.sh script to the home directory and make executable
# This script will copy the .version file to the home directory

# Run this script from the custom_bash_commands directory

# Copy the custom_bash_commands.sh script to the home directory as '.test_custom_bash_commands.sh' and make executable
cp custom_bash_commands.sh ~/.test_custom_bash_commands.sh
chmod +x ~/.test_custom_bash_commands.sh

# Copy the update_commands.sh script to the home directory as '.test_update_commands.sh' and make executable
cp update_commands.sh ~/.test_update_commands.sh
chmod +x ~/.test_update_commands.sh

# Copy the .version file to the home directory as '.test_version'
cp .version ~/.test_version

# Append '.test_custom_bash_commands.sh' and '.test_update_commands.sh' to the end of the .bashrc file and source it
echo "source ~/.test_update_commands.sh" >> ~/.bashrc
echo "source ~/.test_custom_bash_commands.sh" >> ~/.bashrc



