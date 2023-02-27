export EDITOR="nvim"
export TERMINAL="alacritty"
export BROWSER="brave"


# XDG Base Directory Specification
# http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export ZSH_CONFIG="$XDG_CONFIG_HOME/zsh"
export ZSH_CACHE="$XDG_CACHE_HOME/zsh"
mkdir -p $ZSH_CACHE

# search path
export PATH="$HOME/.local/bin":$PATH

export DATE=$(date +%Y-%m-%d)
