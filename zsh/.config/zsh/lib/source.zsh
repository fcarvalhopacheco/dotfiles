#!/usr/bin/env zsh

typeset -g ZSH_ROOT="${ZSH_ROOT:-${ZDOTDIR:-$HOME/.config/zsh}}"
typeset -U path PATH fpath FPATH

_zsh_source() {
    local file="$1"
    [[ "$file" == /* ]] || file="$ZSH_ROOT/$file"

    if [[ -r "$file" ]]; then
        source "$file"
    else
        print -u2 "zsh: missing config file: $file"
        return 1
    fi
}

_zsh_source_if() {
    local file="$1"
    [[ "$file" == /* ]] || file="$ZSH_ROOT/$file"
    [[ -r "$file" ]] && source "$file"
}

_zsh_ensure_dir() {
    [[ -d "$1" ]] || mkdir -p "$1" 2>/dev/null
}

_zsh_path_prepend() {
    local dir
    for dir in "$@"; do
        [[ -d "$dir" ]] && path=("$dir" $path)
    done
    export PATH
}

_zsh_fpath_prepend() {
    local dir
    for dir in "$@"; do
        [[ -d "$dir" ]] && fpath=("$dir" $fpath)
    done
    export FPATH
}

_zsh_is_terminal() {
    [[ -o interactive && -t 0 && -t 1 && -o zle ]]
}

zreload() {
    source "$ZDOTDIR/.zshrc"
}
