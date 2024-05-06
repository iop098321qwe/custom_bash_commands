#!/bin/bash

# Temporary directory for sparse checkout
SPARSE_DIR=$(mktemp -d)

# URL of the GitHub repository
REPO_URL=https://github.com/iop098321qwe/custom_bash_commands.git

# List of file paths to download and move
FILE_PATHS=(
    custom_bash_commands.sh
    .version
    update_commands.sh
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

# Move .cbcconfig directory and its contents to the sparse checkout configuration if and only if it doesn't already exist in the home directory
if [ ! -d ~/.cbcconfig ]; then
    echo ".cbcconfig" >> .git/info/sparse-checkout
fi

# Fetch only the desired files from the master branch
git pull origin master -q

# Move the fetched files to the target directory
for path in "${FILE_PATHS[@]}"; do
    # Determine the new filename with '.' prefix (if not already prefixed)
    new_filename="$(basename $path)"
    if [[ $new_filename != .* ]]; then
        new_filename=".$new_filename"
    fi

    # Copy the file to the home directory with the new filename
    cp $SPARSE_DIR/$path ~/$new_filename
    echo "Copied $path to $new_filename"
done

# Clean up
rm -rf $SPARSE_DIR
cd ~
clear
