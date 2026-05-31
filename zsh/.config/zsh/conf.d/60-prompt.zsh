#!/usr/bin/env zsh

setopt prompt_subst
autoload -U colors
colors

: "${ZSH_PROMPT_GIT_MODE:=light}"

_zsh_prompt_git_head() {
    local dir="$PWD"
    local git_dir git_file line head

    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]]; then
            git_dir="$dir/.git"
            break
        elif [[ -f "$dir/.git" ]]; then
            git_file="$dir/.git"
            IFS= read -r line < "$git_file" || return
            git_dir="${line#gitdir: }"
            [[ "$git_dir" == "$line" ]] && return
            [[ "$git_dir" == /* ]] || git_dir="$dir/$git_dir"
            break
        fi
        dir="${dir:h}"
    done

    [[ -n "$git_dir" ]] || return
    IFS= read -r head < "$git_dir/HEAD" 2>/dev/null || return

    if [[ "$head" == "ref: refs/heads/"* ]]; then
        print -r -- "${head#ref: refs/heads/}"
    elif [[ "$head" == "ref: "* ]]; then
        print -r -- "${head#ref: }"
    else
        print -r -- "${head[1,7]}"
    fi
}

_zsh_prompt_git_light() {
    local branch="$(_zsh_prompt_git_head)" || return
    [[ -n "$branch" ]] && print -r -- "%{$fg_bold[magenta]%}${branch}%{$reset_color%}"
}

_zsh_prompt_git_full() {
    if (( ! $+functions[__git_ps1] )); then
        local git_prompt="$DOTFILES/scripts/.config/scripts/zsh/git-prompt.sh"
        [[ -f "$git_prompt" ]] && source "$git_prompt"
    fi
    (( $+functions[__git_ps1] )) || return

    GIT_PS1_SHOWDIRTYSTATE=1
    GIT_PS1_SHOWSTASHSTATE=1
    GIT_PS1_SHOWUNTRACKEDFILES=1
    GIT_PS1_SHOWUPSTREAM="auto"
    GIT_PS1_SHOWCOLORHINTS=1

    local git_info
    git_info="$(__git_ps1 "%s")" || return
    git_info="${git_info//\*/%{$fg_bold[red]%}x%{$fg_bold[magenta]%}}"
    git_info="${git_info//+/%{$fg_bold[yellow]%}+%{$fg_bold[magenta]%}}"
    git_info="${git_info//=/%{$fg_bold[green]%}=%{$fg_bold[magenta]%}}"
    git_info="${git_info//>/%{$fg_bold[blue]%}>%{$fg_bold[magenta]%}}"
    print -r -- "%{$fg_bold[magenta]%}${git_info}%{$reset_color%}"
}

_zsh_prompt_precmd() {
    local last_status=$?
    local env_name="${CONDA_DEFAULT_ENV##*/}"
    local conda_env=""

    if [[ -n "$env_name" && "$env_name" != "base" ]]; then
        conda_env="%{$fg_bold[green]%}($env_name) "
    fi

    local ps_symbol
    if (( last_status == 0 )); then
        ps_symbol="%{$fg_bold[cyan]%}>"
    else
        ps_symbol="%{$fg_bold[red]%}!"
    fi

    local user_host="%{$fg_bold[magenta]%}%n%{$fg_no_bold[green]%}@%m"
    local current_dir="%{$fg_bold[blue]%}%~"
    local git_info=""

    if [[ "$ZSH_PROMPT_GIT_MODE" == "full" ]]; then
        git_info="$(_zsh_prompt_git_full)"
    else
        git_info="$(_zsh_prompt_git_light)"
    fi
    [[ -n "$git_info" ]] && git_info=" [${git_info}%{$fg_no_bold[white]%}]"

    PS1="${conda_env}${user_host} ${ps_symbol} ${current_dir}${git_info} %{$reset_color%} "
}

precmd_functions=(${precmd_functions:#_zsh_prompt_precmd} _zsh_prompt_precmd)
_zsh_prompt_precmd
