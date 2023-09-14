#!/bin/bash

# Function to combine the git add/commit process
function cc() {
  # Check if a message was provided
  if [ $# -eq 0 ]; then
    echo "Commit message is not provided"
    return 1
  fi
  
  # Combine all arguments into a single commit message
  message="$@"
  
  # If a message is provided, proceed with git operations
  currentBranch=$(git symbolic-ref --short -q HEAD)  # Getting the current branch
  
  git add .
  git commit -m "$message"
  git push origin "$currentBranch"
}

# test