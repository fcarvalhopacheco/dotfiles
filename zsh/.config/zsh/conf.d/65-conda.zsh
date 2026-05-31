#!/usr/bin/env zsh

unalias conda mamba condaon condaoff 2>/dev/null
unfunction conda mamba condaon condaoff 2>/dev/null
typeset -g ZSH_CONDA_LOADED=0

_zsh_conda_detect_home() {
    local dir
    for dir in "${ZSH_CONDA_HOME:-}" "$HOME/mambaforge" "$HOME/miniforge3" "$HOME/miniconda3" "$HOME/anaconda3"; do
        [[ -n "$dir" && -x "$dir/bin/conda" ]] && {
            print -r -- "$dir"
            return 0
        }
    done
    return 1
}

typeset -g ZSH_CONDA_HOME="${ZSH_CONDA_HOME:-$(_zsh_conda_detect_home)}"

_zsh_conda_bin() {
    print -r -- "$ZSH_CONDA_HOME/bin/conda"
}

_zsh_mamba_bin() {
    print -r -- "$ZSH_CONDA_HOME/bin/mamba"
}

_zsh_conda_load() {
    [[ "$ZSH_CONDA_LOADED" == "1" && -n "${CONDA_EXE:-}" ]] && return 0

    local conda_bin="$(_zsh_conda_bin)"
    local conda_sh="$ZSH_CONDA_HOME/etc/profile.d/conda.sh"
    local mamba_sh="$ZSH_CONDA_HOME/etc/profile.d/mamba.sh"
    local conda_setup

    unfunction conda mamba 2>/dev/null

    if [[ -x "$conda_bin" ]]; then
        conda_setup="$("$conda_bin" shell.zsh hook 2>/dev/null)" && eval "$conda_setup"
    elif [[ -f "$conda_sh" ]]; then
        source "$conda_sh"
    elif [[ -d "$ZSH_CONDA_HOME/bin" ]]; then
        _zsh_path_prepend "$ZSH_CONDA_HOME/bin"
    else
        print -u2 "Conda not found. Set ZSH_CONDA_HOME to your conda/mamba root."
        return 1
    fi

    [[ -f "$mamba_sh" ]] && source "$mamba_sh"
    ZSH_CONDA_LOADED=1
}

conda() {
    local conda_bin="$(_zsh_conda_bin)"

    case "${1:-}" in
        activate|deactivate)
            _zsh_conda_load || return
            conda "$@"
            ;;
        *)
            if [[ "$ZSH_CONDA_LOADED" == "1" ]]; then
                _zsh_conda_load || return
                conda "$@"
            elif [[ -x "$conda_bin" ]]; then
                "$conda_bin" "$@"
            else
                _zsh_conda_load || return
                conda "$@"
            fi
            ;;
    esac
}

mamba() {
    local mamba_bin="$(_zsh_mamba_bin)"

    case "${1:-}" in
        activate|deactivate)
            _zsh_conda_load || return
            mamba "$@"
            ;;
        *)
            if [[ "$ZSH_CONDA_LOADED" == "1" ]]; then
                _zsh_conda_load || return
                mamba "$@"
            elif [[ -x "$mamba_bin" ]]; then
                "$mamba_bin" "$@"
            else
                _zsh_conda_load || return
                mamba "$@"
            fi
            ;;
    esac
}

condaon() {
    _zsh_conda_load && print "conda is now on"
}

condaoff() {
    _zsh_conda_load || return
    conda deactivate
}
