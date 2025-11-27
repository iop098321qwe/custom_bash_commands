#!/usr/bin/env bash

# This script will hold all of the declared aliases from the cbc main script
# This will be a modularized way to keep the main script clean and organized
# The custom_bash_commands.sh script will source this file to load all of the aliases

################################################################################
# ALIASES
################################################################################

alias dl='downloads'
alias editbash='$EDITOR ~/.bashrc'
alias fman='compgen -c | fzf | xargs man'
alias fzf='fzf -m'
# TODO: add if statement to check for wayland or x11 and alias accordingly
alias imv='imv-x11'
alias line='read -p "Enter line number: " line && file=$(fzf --prompt="Select a file: ") && nvim +$line "$file"'
alias myip='curl http://ipecho.net/plain; echo'
alias nv='files=$(fzf --multi --prompt="Select files/dirs for nvim: " --bind "enter:accept") && [ -n "$files" ] && nvim $files'
alias please='sudo $(history -p !!)'
alias refresh='source ~/.bashrc && clear'
alias rma='rm -rfI'
# TODO: Check if sortalpha still exists, if not remove this alias
alias sa='sortalpha'
# TODO: Check if smartsort still exists, if not remove this alias
alias ssort='smartsort'

################################################################################
# CBC SPECIFIC
################################################################################

alias comm='commands'
alias commm='commandsmore'
alias di='display_info'
alias dv='display_version'
alias ext='extract'
alias fh='filehash'
alias rh='regex_help'
alias test='source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh; source ~/Documents/github_repositories/custom_bash_commands/cbc_aliases.sh'
alias ucbc='updatecbc'

################################################################################
# VIM TO NVIM
################################################################################

alias vim='nvim'

################################################################################
# SINGLE LETTER ALIAS
################################################################################

alias c='clear'
alias i='sudo apt install'
alias s='sudo'
alias v='nvim'
alias x='chmod +x'
alias z='zellij'

################################################################################
# VIM EXIT
################################################################################

alias ':wq'='exit'
alias ':q'='exit'

################################################################################
# EZA
################################################################################

# TODO: only use eza aliases if not on Arch Linux
alias la="eza --icons=always --group-directories-first -a"
alias lar="eza --icons=always -r --group-directories-first -a"
alias le="eza --icons=always --group-directories-first -s extension"
alias ll="eza --icons=always --group-directories-first --smart-group --total-size -hl"
alias llt="eza --icons=always --group-directories-first --smart-group --total-size -hlT"
alias lsd="eza --icons=always --group-directories-first -D"
alias ls="eza --icons=always --group-directories-first"
alias lsf="eza --icons=always --group-directories-first -f"
alias lsr="eza --icons=always --group-directories-first -r"
alias lt="eza --icons=always --group-directories-first -T"

################################################################################
# PYTHON
################################################################################

alias py='python3'
alias python='python3'

################################################################################
# CD SHORTCUTS
################################################################################

alias back='cd ..'
alias cdgh='cd ~/Documents/github_repositories'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'
alias home='cd ~'
alias temp='cd ~/Documents/Temporary'
alias vault='cd ~/Documents/grymms_grimoires'

################################################################################
# BATCAT
################################################################################

alias bat='batcat'
alias commands='cbcs | batcat'
alias commandsmore='cbcs -a | batcat'
alias seebash='batcat ~/.bashrc'

################################################################################
# INTERACTIVE ALIASES
################################################################################

alias cp='cp -i'
alias ln='ln -i'
alias mv='mv -i'
alias rm='rm -I'

################################################################################
# HISTORY
################################################################################

alias historysearchexact='history | sort -nr | fzf -m -e --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias historysearch='history | sort -nr | fzf -m --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias hsearch='historysearch'
alias hse='historysearchexact'
alias hs='historysearch'
