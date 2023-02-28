#!/bin/sh


alias vi="nvim"
alias vim="nvim"
alias aedit=" $EDITOR $ZSH_CONFIG/zsh-aliases.zsh; source $ZSH_CONFIG/zsh-aliases.zsh"


# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'

# easier to read disk
alias df='df -h'     # human-readable sizes


# Navigation
alias ..="cd .."
alias ...="cd ../.."
alias cl=clear

# ls using exa
alias ls="exa --icons --color=auto --group --git"               
alias l="exa -la --time-style long-iso --icons --color=auto --group --git"        
alias ll="exa -l --time-style long-iso --icons --color=auto --group --git"
alias lll="exa -lasnew --time-style long-iso --icons --color=auto --group --git"        
alias lt='exa -Tla --time-style long-iso --icons --color=auto --group --git'

# CD Shortcuts
alias docs="cd ~/Documents"
alias dl="cd ~/Downloads/"
alias dw="cd ~/Documents/workspace/"
alias dwg="cd ~/Documents/workspace/1.git/"
alias dot="cd ~/.dotfiles/"







