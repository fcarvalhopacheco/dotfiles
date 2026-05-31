#!/usr/bin/env zsh

if [[ -z "${_ZSH_FZF_CONFIGURED:-}" ]]; then
    export FZF_DEFAULT_OPTS="--height=70% --layout=reverse --border=rounded --cycle --info=inline ${FZF_DEFAULT_OPTS:-}"

    # Use exact matching for history so Ctrl-R behaves like command search,
    # not broad fuzzy matching across unrelated command text.
    export FZF_CTRL_R_OPTS="--exact --prompt='history> ' --header='exact history search | Ctrl-R sort | Alt-R raw | Ctrl-/ wrap' ${FZF_CTRL_R_OPTS:-}"

    export FZF_CTRL_T_OPTS="--walker-skip .git,node_modules,target,.venv,__pycache__ ${FZF_CTRL_T_OPTS:-}"
    export FZF_ALT_C_OPTS="--walker-skip .git,node_modules,target,.venv,__pycache__ --prompt='cd> ' ${FZF_ALT_C_OPTS:-}"

    typeset -g _ZSH_FZF_CONFIGURED=1
fi
