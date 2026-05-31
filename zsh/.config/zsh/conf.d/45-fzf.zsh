#!/usr/bin/env zsh

_zsh_fzf_strip_defaults() {
    local var="$1"
    shift
    local current="${(P)var:-}"
    local stale

    for stale in "$@"; do
        while [[ "$current" == *"$stale"* ]]; do
            current="${current//$stale/}"
        done
    done

    current="${current#"${current%%[![:space:]]*}"}"
    current="${current%"${current##*[![:space:]]}"}"
    typeset -gx "$var=$current"
}

_zsh_fzf_set_defaults() {
    _zsh_fzf_strip_defaults FZF_DEFAULT_OPTS \
        "--height=70% --layout=reverse --border=rounded --cycle --info=inline --bind=ctrl-z:ignore" \
        "--height=70% --layout=reverse --border=rounded --cycle --info=inline"
    export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border=rounded --cycle --info=inline --bind=ctrl-z:ignore${FZF_DEFAULT_OPTS:+ $FZF_DEFAULT_OPTS}"

    _zsh_fzf_strip_defaults FZF_CTRL_R_OPTS \
        "--exact --no-sort --prompt='history> ' --header='recent-first | Ctrl-R: sort | Ctrl-/: wrap' --bind=backward-eof:ignore" \
        "--exact --prompt=history> --header=recent-first,Ctrl-R:sort" \
        "--exact --prompt=history> --header=recent-first,Ctrl-R:sort,Alt-R:raw" \
        "--exact --prompt='history> ' --header='exact history search | Ctrl-R sort | Alt-R raw | Ctrl-/ wrap'"
    export FZF_CTRL_R_OPTS="--exact --no-sort --prompt='history> ' --header='recent-first | Ctrl-R: sort | Ctrl-/: wrap' --bind=backward-eof:ignore${FZF_CTRL_R_OPTS:+ $FZF_CTRL_R_OPTS}"

    _zsh_fzf_strip_defaults FZF_CTRL_T_OPTS \
        "--walker-skip=.git,node_modules,target,.venv,__pycache__" \
        "--walker-skip .git,node_modules,target,.venv,__pycache__"
    export FZF_CTRL_T_OPTS="--walker-skip=.git,node_modules,target,.venv,__pycache__${FZF_CTRL_T_OPTS:+ $FZF_CTRL_T_OPTS}"

    _zsh_fzf_strip_defaults FZF_ALT_C_OPTS \
        "--walker-skip=.git,node_modules,target,.venv,__pycache__ --prompt='cd> '" \
        "--walker-skip=.git,node_modules,target,.venv,__pycache__ --prompt=cd>" \
        "--walker-skip .git,node_modules,target,.venv,__pycache__ --prompt='cd> '"
    export FZF_ALT_C_OPTS="--walker-skip=.git,node_modules,target,.venv,__pycache__ --prompt='cd> '${FZF_ALT_C_OPTS:+ $FZF_ALT_C_OPTS}"
}

_zsh_fzf_sync_history() {
    [[ -n "${HISTFILE:-}" ]] || return 0
    builtin fc -AI "$HISTFILE" 2>/dev/null
    builtin fc -RI "$HISTFILE" 2>/dev/null
}

_zsh_fzf_wrap_history_widget() {
    (( $+functions[fzf-history-widget] )) || return 0

    unfunction _zsh_fzf_history_widget_upstream 2>/dev/null
    functions -c fzf-history-widget _zsh_fzf_history_widget_upstream

    fzf-history-widget() {
        _zsh_fzf_sync_history
        _zsh_fzf_history_widget_upstream "$@"
    }

    zle -N fzf-history-widget
    bindkey -M emacs '^R' fzf-history-widget
    bindkey -M vicmd '^R' fzf-history-widget
    bindkey -M viins '^R' fzf-history-widget
}

_zsh_fzf_set_defaults
