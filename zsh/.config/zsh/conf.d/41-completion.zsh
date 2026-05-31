#!/usr/bin/env zsh

zsh_load_completion_plugins
_zsh_source "conf.d/40-completion-styles.zsh"

zmodload zsh/complist
autoload -Uz compinit

mkdir -p "$ZSH_CACHE_DIR" 2>/dev/null
_zsh_compdump="$ZSH_CACHE_DIR/zcompdump"

if [[ -z "${_ZSH_COMPINIT_DONE:-}" || ! -s "$_zsh_compdump" ]]; then
    if [[ -s "$_zsh_compdump" ]]; then
        compinit -C -d "$_zsh_compdump"
    else
        compinit -d "$_zsh_compdump"
    fi
    typeset -g _ZSH_COMPINIT_DONE=1
fi

_comp_options+=(globdots)
unset _zsh_compdump
