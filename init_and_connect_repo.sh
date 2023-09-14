# A function to initialize a local git repo and create/connect it to a GitHub repo
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

    # 2. Create a new remote repository on GitHub using the gh tool
    # The name of the repo will be the name of the current directory, converted to lowercase and spaces replaced with underscores
    repo_name=$(basename $(pwd) | tr '[:upper:]' '[:lower:]' | tr ' ' '_')
    gh repo create $repo_name --confirm

    # 3. Connect the local repository to the newly created remote repository on GitHub
    git remote add origin "https://github.com/$(gh api user | jq -r '.login')/$repo_name.git"
    
    # 4. Add all files, commit and push
    cc "Initial commit"
    git push -u origin master
}
 