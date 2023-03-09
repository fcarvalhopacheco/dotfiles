#!/usr/bin/env zsh

#████████████████████████████████████████████████████████████████████████████
#
#
#          ███████╗███████╗██╗  ██╗███████╗███╗   ██╗██╗   ██╗
#          ╚══███╔╝██╔════╝██║  ██║██╔════╝████╗  ██║██║   ██║
#            ███╔╝ ███████╗███████║█████╗  ██╔██╗ ██║██║   ██║
#           ███╔╝  ╚════██║██╔══██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝
#       ██╗███████╗███████║██║  ██║███████╗██║ ╚████║ ╚████╔╝ 
#       ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  
#    
#       GitHub:  https://github.com/fcarvalhopacheco
#                                                             
#       Reference:
#           - https://thevaluable.dev/zsh-install-configure-mouseless/
#
#
#████████████████████████████████████████████████████████████████████████████

# XDG Base Directory Specification
#   : http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"

# GPG key 
export GPG_TTY=$(tty)

# (( ${+*} )) = if variable is set don't set it anymore
# Adpated from https://www.strcat.de/dotfiles/

# Set default terminal emulator
(( ${+TERMINAL} )) || export TERMINAL="alacritty"

# Set default browser
(( ${+BROWSER} )) || export BROWSER="brave"

# Term color
(( ${+TERM} )) || export TERM="xterm-256color"


# Set default directories
export WORKSPACE="$HOME/Documents/workspace"
export DOTFILES="$HOME/.dotfiles"


# Editor
export VISUAL="nvim"                
export EDITOR="nvim"                             


# Zsh enviroment variables
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=1000                   # Maximum events for internal history
export SAVEHIST=1000                  # Maximum events in history file


# PATH
[ -d "${HOME}/.config/zsh" ] && PATH="${PATH}:${HOME}/.config/zsh"
[ -d "${HOME}/.local/bin" ] && PATH="${PATH}:${HOME}/.local/bin"
# [ -d "${HOME}/miniconda3/condabin" ] && PATH="${PATH}:${HOME}/miniconda3/condabin"

# Alacrity 
. "$HOME/.cargo/env"

