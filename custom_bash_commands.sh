#!/bin/bash

# Function to display the version.txt file from the remote repository on GitHub
display_version() {
    # Get the raw URL of the version.txt file
    version_url="https://raw.githubusercontent.com/iop098321qwe/custom_bash_commands/blob/master/version.txt"

    # Use curl to fetch the contents of the version.txt file and display it in the terminal
    curl -s "$version_url"
}

# Call the display_version function
display_version


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

# A function to initialize a local git repo, create/connect it to a GitHub repo, and set up files
incon() {
    # Ensure the gh tool is installed
    if ! command -v gh &> /dev/null; then
        echo "gh (GitHub CLI) not found. Please install it to proceed."
        return
    fi

    # Check if the current directory already contains a git repository
    if [ -d ".git" ]; then
        echo "This directory is already initialized as a git repository."
        return
    fi

    # 1. Initialize a new local Git repository
    git init

    # Create a .gitignore and README.md file
    touch .gitignore
    repo_name=$(basename $(pwd) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    formatted_name=$(echo $repo_name | tr '_' ' ' | sed -e "s/\b\(.\)/\u\1/g")
    echo "# $formatted_name" > README.md
    echo "* Not started" >> README.md

    # 2. Create a new remote public repository on GitHub using the gh tool
    gh repo create $repo_name --private || { echo "Repository creation failed. Exiting."; return; }

    # 3. Connect the local repository to the newly created remote repository on GitHub
    git remote add origin "https://github.com/$(gh api user | jq -r '.login')/$repo_name.git"
    
    # 4. Add all files, commit, and push
    cc "Initial commit"
    git push -u origin master || { echo "Push to master failed. Exiting."; return; }

    # 5. Create a test branch, switch to it, and then switch back to master
    git checkout -b test
    cc "Initial test commit"
    git checkout master
}

# Define the custom command
update() {
    # Create the log directory if it doesn't exist
    mkdir -p ~/Documents/update_logs

    # Define the log file path
    log_file=~/Documents/update_logs/$(date +"%Y-%m-%d_%H-%M-%S").log

    # Run update commands with sudo, tee to output to terminal and append to log file
    command="sudo apt update"
    echo -e "\n================================================================================"
    echo "Running command: $command" | tee -a "$log_file"
    echo "================================================================================"
    eval "$command" | tee -a "$log_file"

    command="sudo apt upgrade -y"
    echo -e "\n================================================================================"
    echo "Running command: $command" | tee -a "$log_file"
    echo "================================================================================"
    eval "$command" | tee -a "$log_file"

    command="sudo apt autoremove -y"
    echo -e "\n================================================================================"
    echo "Running command: $command" | tee -a "$log_file"
    echo "================================================================================"
    eval "$command" | tee -a "$log_file"

    # Display the log file path
    echo -e "\nUpdate logs saved to: $log_file"

    # Display the command to navigate to the log file directory
    echo -e "\nTo navigate to the log file directory, use the following command:"
    echo -e "cd ~/Documents/update_logs"
}

echo "Custom bash commands loaded successfully."

# Create a variable to store a number that will serve as the session ID, and increment it by 1 each time it is loaded
if [ -f ~/.session_id ]; then
    session_id=$(< ~/.session_id)
    session_id=$((session_id+1))
    echo $session_id > ~/.session_id
else
    session_id=1
    echo $session_id > ~/.session_id
fi

# Print the session ID
echo "Session ID: $session_id"

# Run the update_commands.sh script
cd ... ~/.update_commands.sh
