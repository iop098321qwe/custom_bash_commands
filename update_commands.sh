#!/bin/bash

# Temporary directory for sparse checkout
SPARSE_DIR=$(mktemp -d)

# URL of the GitHub repository and the desired file path
REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git
FILE_PATH=custom_bash_commands.sh
TARGET_FILE=~/.custom_bash_commands.sh

# Initialize an empty git repository and configure for sparse checkout
cd $SPARSE_DIR
git init -q
git remote add origin $REPO_URL
git config core.sparseCheckout true
echo $FILE_PATH >> .git/info/sparse-checkout

# Fetch only the desired file
git pull origin master -q

# Copy the fetched file to the target location and overwrite if it exists
cp $SPARSE_DIR/$FILE_PATH $TARGET_FILE

# Also copy the '.update_commands.sh' file
FILE_PATH=update_commands.sh
TARGET_FILE=~/.update_commands.sh

# Copy the fetched file to the target location and overwrite if it exists
cp $SPARSE_DIR/$FILE_PATH $TARGET_FILE

# Clean up
rm -rf $SPARSE_DIR
cd ~
clear

echo "test2"