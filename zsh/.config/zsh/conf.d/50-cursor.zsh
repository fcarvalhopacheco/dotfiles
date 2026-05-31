#!/usr/bin/env zsh

zle-keymap-select() {
    [[ -t 1 ]] || return
    case "$KEYMAP" in
        vicmd) print -n $'\e[1 q' ;;
        viins|main) print -n $'\e[5 q' ;;
    esac
}
zle -N zle-keymap-select

zle-line-init() {
    zle -K viins
    [[ -t 1 ]] && print -n $'\e[5 q'
}
zle -N zle-line-init

[[ -t 1 ]] && print -n $'\e[5 q'

_zsh_cursor_preexec() {
    [[ -t 1 ]] && print -n $'\e[5 q'
}
preexec_functions=(${preexec_functions:#_zsh_cursor_preexec} _zsh_cursor_preexec)
