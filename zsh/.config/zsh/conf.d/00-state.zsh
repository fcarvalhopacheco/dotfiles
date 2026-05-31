#!/usr/bin/env zsh

if ! _zsh_ensure_dir "$ZSH_CACHE_DIR"; then
    export ZSH_CACHE_DIR="${TMPDIR:-/tmp}/zsh-${USER:-user}/cache"
    _zsh_ensure_dir "$ZSH_CACHE_DIR"
fi

if ! _zsh_ensure_dir "$ZSH_STATE_DIR"; then
    export ZSH_STATE_DIR="${TMPDIR:-/tmp}/zsh-${USER:-user}/state"
    _zsh_ensure_dir "$ZSH_STATE_DIR"
fi

[[ -t 0 ]] && export GPG_TTY="$(tty)"

# macOS /etc/zshrc resets history, so keep history config in .zshrc scope too.
export HISTFILE="$ZSH_STATE_DIR/history"
export HISTSIZE=50000
export SAVEHIST=50000
