#!/usr/bin/env zsh
# zmodload zsh/zprof
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
[[ "${XDG_DATA_HOME:-}" == "$HOME/.config/local/share" ]] && unset XDG_DATA_HOME
[[ "${XDG_CACHE_HOME:-}" == "$HOME/.config/cache" ]] && unset XDG_CACHE_HOME
[[ "${ZSH_CACHE_DIR:-}" == "$HOME/.config/cache/zsh" ]] && unset ZSH_CACHE_DIR

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"

export ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-$XDG_CACHE_HOME/zsh}"
export ZSH_STATE_DIR="${ZSH_STATE_DIR:-$XDG_STATE_HOME/zsh}"

# (( ${+*} )) = if variable is set don't set it anymore
# Adapted from https://www.strcat.de/dotfiles/

# Set default terminal emulator
(( ${+TERMINAL} )) || export TERMINAL="alacritty"

# Set default browser
(( ${+BROWSER} )) || export BROWSER="brave"

# Term color
#20231006 Backup
#(( ${+TERM} )) || export TERM=alacritty-direct
#(( ${+TERM} )) || export TERM="screen-256color"
#
# 20240306 Deactivate to avoid conflict with tmux/nvim?
# if [[ "$TERM" == "tmux-256color" ]]; then
#   export TERM=screen-256color
# fi

# Set default directories
export WORKSPACE="$HOME/Documents/workspace"
export DOTFILES="$HOME/.dotfiles"


# Editor
export VISUAL="nvim"
export EDITOR="nvim"


# Zsh environment variables
export HISTFILE="$ZSH_STATE_DIR/history"
export HISTSIZE=50000
export SAVEHIST=50000

# Add to PATH without duplicating entries.
typeset -U path PATH
[[ -d "$HOME/.config/local/share/nvim/mason/bin" ]] && path=("$HOME/.config/local/share/nvim/mason/bin" $path)
[[ -d "$HOME/.config/zsh/bin" ]] && path=("$HOME/.config/zsh/bin" $path)
[[ -d "$HOME/.config/zsh" ]] && path=("$HOME/.config/zsh" $path)
[[ -d "$HOME/.config/scripts/zsh" ]] && path=("$HOME/.config/scripts/zsh" $path)
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[[ -d "$HOME/.cargo/bin" ]] && path=("$HOME/.cargo/bin" $path)
export PATH

# # PATH
# [ -d "${HOME}/.config/zsh" ] && PATH="${PATH}:${HOME}/.config/zsh"
# [ -d "${HOME}/.config/zsh/scripts" ] && PATH="${PATH}:${HOME}/.config/zsh/scripts"
# [ -d "${HOME}/.local/bin" ] && PATH="${PATH}:${HOME}/.local/bin"
# # [ -d "${HOME}/miniconda3/condabin" ] && PATH="${PATH}:${HOME}/miniconda3/condabin"

# zprof
