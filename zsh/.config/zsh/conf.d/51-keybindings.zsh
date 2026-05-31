#!/usr/bin/env zsh

bindkey -v
export KEYTIMEOUT=1

autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd 'v' edit-command-line

if [[ -o menucomplete ]]; then
    bindkey -M menuselect 'h' vi-backward-char
    bindkey -M menuselect 'k' vi-up-line-or-history
    bindkey -M menuselect 'j' vi-down-line-or-history
    bindkey -M menuselect 'l' vi-forward-char
    bindkey -M menuselect 'i' accept-and-menu-complete
    bindkey -M menuselect 'o' accept-and-infer-next-history
    bindkey -M menuselect '^d' clear-screen
    bindkey -M menuselect 'u' undo
fi

autoload -Uz select-bracketed select-quoted
zle -N select-quoted
zle -N select-bracketed

local km c
for km in viopp visual; do
    bindkey -M "$km" -- '-' vi-up-line-or-history

    for c in {a,i}${(s..)^:-\'\"\`\|,./:;=+@}; do
        bindkey -M "$km" "$c" select-quoted
    done

    for c in {a,i}${(s..)^:-'()[]{}<>bB'}; do
        bindkey -M "$km" "$c" select-bracketed
    done
done
unset km c
