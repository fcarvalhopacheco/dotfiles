#!/usr/bin/env zsh

_zsh_fzf_trim() {
    local value="$*"
    value="${value#"${value%%[![:space:]]*}"}"
    value="${value%"${value##*[![:space:]]}"}"
    print -r -- "$value"
}

_zsh_fzf_prepend_once() {
    local var="$1"
    shift
    local defaults="$1"
    shift
    local current="${(P)var:-}"
    local stale

    # Remove older copies of these dotfiles defaults inherited by nested shells.
    for stale in "$defaults" "$@"; do
        while [[ "$current" == *"$stale"* ]]; do
            current="${current//$stale/}"
        done
    done

    current="$(_zsh_fzf_trim "$current")"
    typeset -gx "$var=$defaults${current:+ $current}"
}

_zsh_fzf_command() {
    if (( $+functions[__fzfcmd] )); then
        __fzfcmd
    elif [[ -n "${TMUX_PANE:-}" && ( "${FZF_TMUX:-0}" != 0 || -n "${FZF_TMUX_OPTS:-}" ) ]]; then
        print -r -- "fzf-tmux ${FZF_TMUX_OPTS:--d${FZF_TMUX_HEIGHT:-40%}} --"
    else
        print -r -- "fzf"
    fi
}

_zsh_fzf_history_file_entries() {
    [[ -r "$HISTFILE" ]] || return 0
    (( $+commands[perl] )) || return 0

    perl -0ne '
        while (/: \d+:\d+;(.*?)(?=\n: \d+:\d+;|\z)/msg) {
            push @commands, $1;
        }
        for my $command (reverse @commands) {
            $command =~ s/\n\z//;
            $command =~ s/\\\n/\n/g;
            $command =~ s/\n/\\n/g;
            print "$command\n" if length $command;
        }
    ' "$HISTFILE"
}

_zsh_fzf_history_entries() {
    {
        _zsh_fzf_history_file_entries
        builtin fc -rl 1 2>/dev/null |
            awk '{
                cmd = $0
                sub(/^[ \t]*[0-9]+\**[ \t]+/, "", cmd)
                print cmd
            }'
    } | awk 'length($0) && !seen[$0]++'
}

_zsh_fzf_history_widget() {
    setopt localoptions pipefail no_aliases no_glob no_sh_glob extendedglob 2>/dev/null

    local selected ret fzf_cmd fzf_opts

    # Make Ctrl-R reflect the live shell plus commands written by other tabs.
    builtin fc -AI "$HISTFILE" 2>/dev/null
    builtin fc -RI "$HISTFILE" 2>/dev/null

    fzf_cmd="$(_zsh_fzf_command)"
    fzf_opts="--scheme=history --no-sort --bind=ctrl-r:toggle-sort,alt-r:toggle-raw --wrap-sign='> ' --highlight-line --multi --query=${(qqq)LBUFFER} ${FZF_CTRL_R_OPTS:-}"

    selected="$(
        _zsh_fzf_history_entries |
            FZF_DEFAULT_OPTS="$fzf_opts" FZF_DEFAULT_OPTS_FILE='' ${=fzf_cmd} < /dev/tty
    )"
    ret=$?

    if [[ -n "$selected" ]]; then
        BUFFER="${selected//\\n/$'\n'}"
        CURSOR=${#BUFFER}
    fi

    zle reset-prompt
    return $ret
}

_zsh_fzf_install_history_widget() {
    (( $+commands[fzf] )) || return 0
    (( $+widgets[zle-line-init] || $+widgets[self-insert] )) || return 0

    zle -N fzf-history-widget _zsh_fzf_history_widget
    bindkey -M emacs '^R' fzf-history-widget
    bindkey -M vicmd '^R' fzf-history-widget
    bindkey -M viins '^R' fzf-history-widget
}

if [[ -z "${_ZSH_FZF_CONFIGURED:-}" ]]; then
    _zsh_fzf_prepend_once FZF_DEFAULT_OPTS "--height=70% --layout=reverse --border=rounded --cycle --info=inline"

    # Use exact matching for history so Ctrl-R behaves like command search,
    # not broad fuzzy matching across unrelated command text.
    _zsh_fzf_prepend_once FZF_CTRL_R_OPTS \
        "--exact --prompt=history> --header=recent-first,Ctrl-R:sort,Alt-R:raw" \
        "--exact --prompt='history> ' --header='exact history search | Ctrl-R sort | Alt-R raw | Ctrl-/ wrap'"

    _zsh_fzf_prepend_once FZF_CTRL_T_OPTS \
        "--walker-skip=.git,node_modules,target,.venv,__pycache__" \
        "--walker-skip .git,node_modules,target,.venv,__pycache__"
    _zsh_fzf_prepend_once FZF_ALT_C_OPTS \
        "--walker-skip=.git,node_modules,target,.venv,__pycache__ --prompt=cd>" \
        "--walker-skip .git,node_modules,target,.venv,__pycache__ --prompt='cd> '"

    typeset -g _ZSH_FZF_CONFIGURED=1
fi
