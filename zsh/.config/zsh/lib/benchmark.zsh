#!/usr/bin/env zsh

zbench() {
    local rounds="${1:-10}"
    local i start finish elapsed total=0

    zmodload zsh/datetime || return
    for (( i = 1; i <= rounds; i++ )); do
        start="$EPOCHREALTIME"
        zsh -i -c exit >/dev/null 2>&1
        finish="$EPOCHREALTIME"
        elapsed=$(( (finish - start) * 1000 ))
        total=$(( total + elapsed ))
        printf "%2d  %.1f ms\n" "$i" "$elapsed"
    done
    printf "avg %.1f ms\n" "$(( total / rounds ))"
}

zsmoke() {
    local file failed=0
    local -a files

    files=(
        "$ZDOTDIR/.zshenv"
        "$ZDOTDIR/.zshrc"
        "$ZDOTDIR"/lib/*.zsh(N)
        "$ZDOTDIR"/conf.d/*.zsh(N)
        "$ZDOTDIR"/zsh*(N)
    )

    for file in "${files[@]}"; do
        zsh -n "$file" || failed=1
    done
    (( failed )) && return 1

    zsh -i -c 'source ~/.config/zsh/.zshrc; source ~/.config/zsh/.zshrc; whence -w conda mamba nvm node _conda >/dev/null; print smoke-ok'
}

zcompile_zsh() {
    local file
    local -a files

    files=(
        "$ZDOTDIR/.zshrc"
        "$ZDOTDIR"/lib/*.zsh(N)
        "$ZDOTDIR"/conf.d/*.zsh(N)
    )

    for file in "${files[@]}"; do
        zsh -n "$file" || return
    done

    for file in "${files[@]}"; do
        zcompile "$file"
    done
}
