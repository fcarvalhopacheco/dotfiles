#!/usr/bin/env zsh

typeset -g ZSH_ROOT="${ZDOTDIR:-$HOME/.config/zsh}"

source "$ZSH_ROOT/lib/source.zsh" || return
_zsh_source "lib/lazy.zsh"
_zsh_source "lib/plugins.zsh"
_zsh_source "lib/benchmark.zsh"

_zsh_source "conf.d/00-state.zsh"
_zsh_source "conf.d/10-options.zsh"
_zsh_source "conf.d/20-path.zsh"
_zsh_source "conf.d/30-aliases.zsh"
_zsh_source "conf.d/35-plugins.zsh"
_zsh_source "conf.d/41-completion.zsh"
_zsh_source "conf.d/45-fzf.zsh"

if _zsh_is_terminal; then
    _zsh_source "conf.d/50-cursor.zsh"
    _zsh_source "conf.d/51-keybindings.zsh"
fi

_zsh_source "conf.d/60-prompt.zsh"
_zsh_source "conf.d/65-conda.zsh"
_zsh_source "conf.d/70-integrations.zsh"
