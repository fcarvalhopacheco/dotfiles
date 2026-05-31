#!/usr/bin/env zsh

typeset -ga ZSH_COMPLETION_PLUGINS=(
    "conda-incubator/conda-zsh-completion"
)

typeset -ga ZSH_TERMINAL_PLUGINS_PRE=(
    "hlissner/zsh-autopair"
    "zsh-users/zsh-autosuggestions"
)

typeset -ga ZSH_TERMINAL_PLUGINS_POST=(
    "zsh-users/zsh-syntax-highlighting"
)
