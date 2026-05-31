#!/usr/bin/env zsh

typeset -ga _ZSH_LOADED_PLUGINS

zsh_add_file() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        print "Usage: zsh_add_file <file-relative-to-ZDOTDIR>"
        return 0
    fi

    _zsh_source "$1"
}

_zsh_plugin_name() {
    print -r -- "${1:t}"
}

_zsh_plugin_dir() {
    print -r -- "$ZDOTDIR/plugins/$(_zsh_plugin_name "$1")"
}

zsh_add_plugin() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        print "Usage: zsh_add_plugin <github_username/repo>"
        return 0
    fi

    local repo="$1"
    local plugin_name="$(_zsh_plugin_name "$repo")"
    local plugin_dir="$(_zsh_plugin_dir "$repo")"
    local entry
    local -a entries

    if (( ${_ZSH_LOADED_PLUGINS[(Ie)$plugin_name]} )); then
        return 0
    fi

    if [[ ! -d "$plugin_dir" ]]; then
        print -u2 "Plugin missing: $repo. Run: zsh_install_plugin $repo"
        return 1
    fi

    entries=(
        "$plugin_dir/$plugin_name.plugin.zsh"
        "$plugin_dir/$plugin_name.zsh"
        "$plugin_dir/${plugin_name%.zsh}.zsh"
        "$plugin_dir/init.zsh"
    )

    for entry in "${entries[@]}"; do
        if [[ -r "$entry" ]]; then
            source "$entry"
            _ZSH_LOADED_PLUGINS+=("$plugin_name")
            return 0
        fi
    done

    print -u2 "Plugin entrypoint not found: $plugin_name"
    return 1
}

zsh_add_completion() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        print "Usage: zsh_add_completion <github_username/repo>"
        return 0
    fi

    local repo="$1"
    local plugin_name="$(_zsh_plugin_name "$repo")"
    local plugin_dir="$(_zsh_plugin_dir "$repo")"
    local -a completion_files

    if [[ ! -d "$plugin_dir" ]]; then
        print -u2 "Completion plugin missing: $repo. Run: zsh_install_plugin $repo"
        return 1
    fi

    completion_files=("$plugin_dir"/_*(N))
    if (( ${#completion_files} )); then
        _zsh_fpath_prepend "${completion_files[1]:h}"
    else
        _zsh_fpath_prepend "$plugin_dir"
    fi

    local entry="$plugin_dir/$plugin_name.plugin.zsh"
    [[ -r "$entry" ]] && source "$entry"
}

zsh_install_plugin() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        print "Usage: zsh_install_plugin <github_username/repo>"
        return 0
    fi

    local repo="$1"
    local plugin_dir="$(_zsh_plugin_dir "$repo")"

    if [[ -d "$plugin_dir" ]]; then
        print "Plugin already installed: ${repo:t}"
        return 0
    fi

    command git clone "https://github.com/$repo.git" "$plugin_dir"
}

zsh_update_plugins() {
    local plugin_dir
    for plugin_dir in "$ZDOTDIR"/plugins/*(/N); do
        print "Updating ${plugin_dir:t}"
        command git -C "$plugin_dir" pull --ff-only
    done
}

zsh_load_completion_plugins() {
    local repo
    for repo in "${ZSH_COMPLETION_PLUGINS[@]}"; do
        zsh_add_completion "$repo"
    done
}

zsh_load_plugins() {
    local repo
    for repo in "$@"; do
        zsh_add_plugin "$repo"
    done
}

zsh_sync_declared_plugins() {
    local repo
    for repo in "${ZSH_COMPLETION_PLUGINS[@]}" "${ZSH_TERMINAL_PLUGINS_PRE[@]}" "${ZSH_TERMINAL_PLUGINS_POST[@]}"; do
        [[ -n "$repo" ]] && zsh_install_plugin "$repo"
    done
}
