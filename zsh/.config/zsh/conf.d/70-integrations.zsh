#!/usr/bin/env zsh

if (( $+commands[zoxide] )); then
    eval "$(zoxide init zsh)"
fi

export NVM_DIR="${NVM_DIR:-$HOME/.config/nvm}"

_zsh_nvm_load() {
    unfunction nvm node npm npx corepack yarn pnpm 2>/dev/null
    [[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
    [[ -s "$NVM_DIR/bash_completion" ]] && source "$NVM_DIR/bash_completion"
}

zsh_lazy_loader _zsh_nvm_load nvm node npm npx corepack yarn pnpm

if _zsh_is_terminal; then
    zsh_load_plugins "${ZSH_TERMINAL_PLUGINS_PRE[@]}"

    if (( $+commands[fzf] )); then
        source <(fzf --zsh)
        typeset -g _ZSH_FZF_LOADED=1
    fi
    (( $+functions[_zsh_fzf_wrap_history_widget] )) && _zsh_fzf_wrap_history_widget

    zsh_load_plugins "${ZSH_TERMINAL_PLUGINS_POST[@]}"
fi
