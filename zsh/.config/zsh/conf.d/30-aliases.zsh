#!/usr/bin/env zsh

alias vi="nvim"
alias vim="nvim"

# Allow this file to be sourced repeatedly after aliases/functions already exist.
unalias aedit zedit lf ld lh today 2>/dev/null
unfunction aedit zedit lf ld lh today 2>/dev/null

aedit() {
    "$EDITOR" "$ZDOTDIR/zshaliases" && source "$ZDOTDIR/zshaliases"
}

zedit() {
    "$EDITOR" "$ZDOTDIR/.zshrc" && source "$ZDOTDIR/.zshrc"
}

alias cp="cp -i"
alias mv="mv -i"
alias rm="rm -i"
alias df="df -h"

alias ..="cd .."
alias ...="cd ../.."
alias cl="clear"
alias d="dirs -v"
for index ({1..9}) alias "$index"="cd +${index}"
unset index

if (( $+commands[eza] )); then
    alias l="eza -l --icons --git -a"
    alias ld="eza -lD --icons --color=always --group --git --sort=modified --time-style=+'%Y %b %d %H:%M'"
    lf() {
        eza -lF --icons --color=always --group --git --sort=modified --time-style=+'%Y %b %d %H:%M' "$@" | grep -v /
    }
    alias lh="eza -dl .* --group-directories-first --icons --color=always --group --git --sort=modified --time-style=+'%Y %b %d %H:%M'"
    alias ll="eza -al --group-directories-first --icons --color=always --git --sort=modified --time-style=+'%Y %b %d %H:%M'"
    alias lt="eza -al --icons --color=always --group --git --sort=modified --time-style=+'%Y %b %d %H:%M'"
else
    alias l="ls -la"
    ld() { command ls -ld ./*(/N); }
    lf() { command ls -l ./*(.N); }
    lh() { command ls -ld .*(DN); }
    alias ll="ls -la"
    alias lt="ls -lat"
fi

alias docs="cd ~/Documents"
alias dl="cd ~/Downloads/"
alias dw="cd ~/Documents/workspace/"
alias dwg="cd ~/Documents/workspace/1.git/"
alias dot="cd ~/.dotfiles/"

alias nb="TERM=xterm-256color newsboat"

today() {
    nvim "/Users/fcp/Documents/zettelkasten/daily/$(date +'%Y%m%d').md" +ObsidianToday
}

alias tadd='python3 $HOME/.dotfiles/scripts/.config/scripts/python/taskwarrior/taskadd.py'
alias taskadd="zsh $HOME/.dotfiles/scripts/.config/scripts/zsh/taskadd.sh"
alias ssh='TERM="screen-256color" ssh'
