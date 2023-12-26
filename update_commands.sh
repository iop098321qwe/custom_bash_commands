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

# Fetch only the desired files from the master branch
git pull origin master -q

# Move the fetched files to the target directory
for path in "${FILE_PATHS[@]}"; do
    if [ "$path" = ".version" ]; then
        cp $SPARSE_DIR/$path ~/.
        echo "Copied $path"
    else
        new_filename=".$(basename $path)"
        cp $SPARSE_DIR/$path ~/$new_filename
        echo "Copied $path to $new_filename"
    fi
done

: '
# Fetch only the desired files from the test branch
git pull origin test -q

# Move the fetched files to the target directory with '.test_' prefix
for path in "${FILE_PATHS[@]}"; do
    new_filename=".test_$(basename $path)"
        cp $SPARSE_DIR/$path ~/$new_filename
        echo "Copied $path to $new_filename"
done
'

# Clean up
rm -rf $SPARSE_DIR
cd ~
clear
