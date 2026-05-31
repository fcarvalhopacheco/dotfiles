#!/usr/bin/env zsh

zsh_lazy_loader() {
    local loader="$1"
    shift

    local command_name
    for command_name in "$@"; do
        unalias "$command_name" 2>/dev/null
        eval "function $command_name() { $loader || return; $command_name \"\$@\"; }"
    done
}
