#!/usr/bin/env bash

# This script will hold all of the declared aliases from the cbc main script
# This will be a modularized way to keep the main script clean and organized
# The custom_bash_commands.sh script will source this file to load all of the aliases

################################################################################
# ALIASES
################################################################################

alias editbash='$EDITOR ~/.bashrc'
alias fman='compgen -c | fzf | xargs man'
# TODO: add if statement to check for wayland or x11 and alias accordingly
alias imv='imv-x11'
alias myip='curl http://ipecho.net/plain; echo'
alias nv='files=$(fzf -m --prompt="Select files/dirs for nvim: " --bind "enter:accept") && [ -n "$files" ] && nvim $files'
alias please='sudo $(history -p !!)'
alias refresh='source ~/.bashrc && clear'

################################################################################
# CBC SPECIFIC
################################################################################

alias dv='display_version'
alias test='source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh; source ~/Documents/github_repositories/custom_bash_commands/cbc_aliases.sh'
alias ucbc='cbc update'

################################################################################
# VIM TO NVIM
################################################################################

alias vim='nvim'

################################################################################
# SINGLE LETTER ALIAS
################################################################################

alias c='clear'
alias s='sudo'
alias v='nvim'
alias x='chmod +x'
alias z='zellij'

################################################################################
# EZA
################################################################################

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
# BATCAT
################################################################################

# alias bat if any only if on Ubuntu
if [ -f /etc/os-release ]; then
  . /etc/os-release
  case "$ID_LIKE" in
    *ubuntu*)
      alias bat='batcat'
      ;;
  esac
fi

alias seebash='bat ~/.bashrc'
