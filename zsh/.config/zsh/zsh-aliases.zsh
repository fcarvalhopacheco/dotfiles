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
alias ls="exa --icons --color=auto"               
alias l="exa -lah --time-style long-iso --icons --color=auto"        
alias ll="exa -lh --time-style long-iso --icons --color=auto --git"
alias lll="exa -lasnew --time-style long-iso --icons --color=auto --git"        
alias lt='exa -Tlah --time-style long-iso --icons --color=auto'

# CD Shortcuts
alias docs="cd ~/Documents"
alias dl="cd ~/Downloads/"
alias dw="cd ~/Documents/workspace/"
alias dwg="cd ~/Documents/workspace/1.git/"
alias dot="cd ~/.dotfiles/"







