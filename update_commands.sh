#!/bin/bash

# Temporary directory for sparse checkout
SPARSE_DIR=$(mktemp -d)

# URL of the GitHub repository
REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

# List of file paths and directories to download
FILE_PATHS=(
    custom_bash_commands.sh
    .version
    update_commands.sh
    .cbcconfig
)

# Initialize an empty git repository and configure for sparse checkout
cd $SPARSE_DIR
git init -q
git remote add origin $REPO_URL
git config core.sparseCheckout true

# Add each file path to the sparse checkout configuration
for path in "${FILE_PATHS[@]}"; do
    echo $path >> .git/info/sparse-checkout
done

# Fetch only the desired files and directories from the master branch
git pull origin master -q

# Move the fetched files to the target directory
for path in "${FILE_PATHS[@]}"; do
    if [[ -d $path && $path == "cbcconfig" ]]; then
        # Handle copying the directory as a hidden directory
        cp -r $path ~/.cbcconfig
        echo "Copied directory $path to ~/.cbcconfig"
    elif [[ -f $path ]]; then
        # Handle copying files, rename with a dot prefix if necessary
        cp $path ~/$path
        echo "Copied file $path to home directory"
    fi
done

# Clean up
rm -rf $SPARSE_DIR
cd ~
clear
