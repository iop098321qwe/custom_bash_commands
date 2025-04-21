#!/usr/bin/env bash

# This script will hold all of the declared aliases from the cbc main script
# This will be a modularized way to keep the main script clean and organized
# The custom_bash_commands.sh script will source this file to load all of the aliases

###################################################################################################################################################################
# DECLARED ALIASES
###################################################################################################################################################################

# Direct alias declarations

dup() {
  file="$(fzf --prompt='Select URL list file: ')" || return
  awk 'NR==FNR{count[$0]++; next} count[$0]>1{lines[$0]=lines[$0] FNR ", "} END{for (url in lines) printf "%-5s\t%-50s\t%s\n", count[url], url, "lines: " substr(lines[url], 1, length(lines[url])-2)}' "$file" "$file" |
    sort -k1,1nr |
    column -t |
    GREP_COLORS='mt=1;32' grep --color=always '.*'
}

alias back='cd .. && ls'
alias bat='batcat'
alias batch_open='file=$(cat _master_batch.txt | fzf --prompt="Select a file: "); while IFS= read -r line; do xdg-open "$line"; done < "$file"'
alias bo='batch_open'
alias cbcc='cdgh && cd custom_bash_commands && ls && dv && cc'
alias cbc='cdgh && cd custom_bash_commands && ls'
alias c='clear && di'
alias cdgh='cd ~/Documents/github_repositories && ls'
alias ch='chezmoi'
alias chup='chezmoi update'
alias cla='clear && di && la'
alias cls='clear && di && ls'
alias commands='cbcs | batcat'
alias commandsmore='cbcs -a | batcat'
alias comm='commands'
alias commm='commandsmore'
alias cp='cp -i'
alias di='display_info'
alias dl='downloads'
alias docs='cd ~/Documents && ls'
alias downloads='cd ~/Downloads && ls'
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
alias gb='git branch'
alias gco='git checkout'
alias gcom='git checkout main'
alias gcomm='git commit'
alias ga='git add'
alias gaa='git add .'
alias gpsh='git push'
alias gpll='git pull'
alias gpfom='git push --follow-tags origin main'
alias gs='git status'
alias gsw='git switch'
alias gswm='git switch main'
alias gswt='git switch test'
alias historysearchexact='history | sort -nr | fzf -m -e --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias historysearch='history | sort -nr | fzf -m --query="$1" --no-sort --preview="echo {}" --preview-window=down:20%:wrap | awk '\''{ $1=""; sub(/^ /, ""); print }'\'' | xargs -d "\n" echo -n | xclip -selection clipboard'
alias home='cd ~ && ls'
alias hsearch='historysearch'
alias hse='historysearchexact'
alias hs='historysearch'
alias i='sudo apt install'
alias iopen='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias iopenexact='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias io='iopen'
alias ioe='iopenexact'
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
alias lg='lazygit'
alias ln='ln -i'
alias line='read -p "Enter line number: " line && file=$(fzf --prompt="Select a file: ") && nvim +$line "$file"'
alias man='sudo man'
alias mopen='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias mopenexact='find . -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias mo='mopen'
alias moe='mopenexact'
alias mv='mv -i'
alias myip='curl http://ipecho.net/plain; echo'
alias pron='fzf --multi=1 < _master_batch.txt | xargs -I {} yt-dlp --config-locations _configs.txt --batch-file {}'
alias pronfile='cd /media/$USER/T7 Shield/yt-dlp'
alias pronupdate='pronfile && pron || pron'
alias pu='pronupdate'
alias py='python3'
alias python='python3'
alias racc='remove_all_cbc_configs'
alias rdvc='remove_display_version_config'
alias refresh='source ~/.bashrc'
alias rfc='remove_figlet_config'
alias rh='regex_help'
alias rma='rm -rfI'
alias rm='rm -I'
alias rnc='remove_neofetch_config'
alias rsc='remove_session_id_config'
alias seebash='batcat ~/.bashrc'
alias sa='sortalpha'
alias s='sudo'
alias so='sopen'
alias soe='sopenexact'
alias ssort='smart_sort'
alias temp='cd ~/Documents/Temporary && ls'
alias test='source ~/Documents/github_repositories/custom_bash_commands/custom_bash_commands.sh; source ~/Documents/github_repositories/custom_bash_commands/cbc_aliases.sh'
alias ucbc='updatecbc'
alias update_master_list='cat _master_batch.txt | xargs -I {} cat {} | sort -u > _temp_master_list.txt && mv _temp_master_list.txt _master_list.txt && batcat _master_list.txt'
alias uml='update_master_list'
alias vault='cd ~/Documents/grymms_grimoires && ls'
alias ver='npx commit-and-tag-version'
alias verg='ver && gpfom && printf "\n Run gh cr to create a release\n"'
alias vim='nvim'
alias v='nvim'
alias vopen='find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m | xargs -r -d "\n" -I {} nohup open "{}"'
alias vopenexact='find . -type f \( -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.avi" -o -iname "*.mov" -o -iname "*.webm" \) | fzf -m -e | xargs -r -d "\n" -I {} nohup open "{}"'
alias vo='vopen'
alias voe='vopenexact'
alias x='chmod +x'
alias z='zellij'
alias ':wq'='exit'
alias ':q'='exit'
