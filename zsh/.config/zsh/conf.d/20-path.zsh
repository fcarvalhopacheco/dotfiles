#!/usr/bin/env zsh

_zsh_path_prepend \
    "$HOME/.config/local/share/nvim/mason/bin" \
    "$HOME/.config/zsh/bin" \
    "$HOME/.config/zsh" \
    "$HOME/.config/scripts/zsh" \
    "$HOME/.local/bin" \
    "$HOME/.cargo/bin"

if [[ -d /usr/local/Homebrew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="/usr/local/Cellar"
    export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
    _zsh_path_prepend "/usr/local/bin" "/usr/local/sbin"
    _zsh_fpath_prepend "/usr/local/share/zsh/site-functions"
    [[ -n "${MANPATH-}" ]] && export MANPATH=":${MANPATH#:}"
    export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
fi
