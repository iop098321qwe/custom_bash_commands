#!/usr/bin/env bash

# This script will hold all of the declared aliases from the cbc main script
# This will be a modularized way to keep the main script clean and organized
# The custom_bash_commands.sh script will source this file to load all of the aliases

###################################################################################################################################################################
# ALIASES
###################################################################################################################################################################

alias back='cd ..'
alias bat='batcat'
alias c='clear'
alias cdgh='cd ~/Documents/github_repositories'
alias commands='cbcs | batcat'
alias commandsmore='cbcs -a | batcat'
alias comm='commands'
alias commm='commandsmore'
alias cp='cp -i'
alias di='display_info'
alias dl='downloads'
alias docs='cd ~/Documents'
alias downloads='cd ~/Downloads'
alias dv='display_version'
alias editbash='$EDITOR ~/.bashrc'
alias ext='extract'
alias fcome='fcomexact'
alias fcom='eval "$(compgen -c | fzf)"'
alias fcomexact='eval "$(compgen -c | fzf -e)"'
alias fhelpe='fhelpexact'
alias fhelp='eval "$(compgen -c | fzf)" -h'
alias fhelpexact='eval "$(compgen -c | fzf -e)" -h'
alias fh='filehash'
alias fman='compgen -c | fzf | xargs man'
alias fobs='fobsidian'
alias fobsidian='find ~/Documents/grymms_grimoires -type f | fzf | xargs -I {} obsidian "obsidian://open?vault=$(basename ~/Documents/grymms_grimoires)&file={}"'
alias foe='fopenexact'
alias fo='fopen'
alias fopenexact='fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias fopen='fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias fzf='fzf -m'
alias historysearchexact='history | sort -nr | fzf -m -e --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias historysearch='history | sort -nr | fzf -m --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias home='cd ~'
alias hsearch='historysearch'
alias hse='historysearchexact'
alias hs='historysearch'
alias i='sudo apt install'
# TODO: add if statement to check for wayland or x11 and alias accordingly
alias imv='imv-x11'
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
alias ln='ln -i'
alias line='read -p "Enter line number: " line && file=$(fzf --prompt="Select a file: ") && nvim +$line "$file"'
alias lg='lazygit'
alias lzd='lazydocker'
alias lzg='lazygit'
alias man='sudo man'
alias mv='mv -i'
alias myip='curl http://ipecho.net/plain; echo'
alias nv='files=$(fzf --multi --prompt="Select files/dirs for nvim: " --bind "enter:accept") && [ -n "$files" ] && nvim $files'
alias please='sudo $(history -p !!)'
alias py='python3'
alias python='python3'
alias refresh='source ~/.bashrc && clear'
alias rh='regex_help'
alias rma='rm -rfI'
alias rm='rm -I'
alias seebash='batcat ~/.bashrc'
# TODO: Check if sortalpha still exists, if not remove this alias
alias sa='sortalpha'
alias s='sudo'
# TODO: Check if smartsort still exists, if not remove this alias
alias ssort='smartsort'
alias temp='cd ~/Documents/Temporary'
alias test='source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh; source ~/Documents/github_repositories/custom_bash_commands/cbc_aliases.sh'
alias ucbc='updatecbc'
alias vault='cd ~/Documents/grymms_grimoires'
alias ver='npx commit-and-tag-version'
alias verg='ver && gpfom && printf "\n Run gh cr to create a release\n"'
alias vim='nvim'
alias v='nvim'
alias x='chmod +x'
alias z='zellij'
alias ':wq'='exit'
alias ':q'='exit'
