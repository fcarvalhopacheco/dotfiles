# Measure boot time
bootTimeStart=$(gdate +%s%N 2>/dev/null || date +%s%N)

# history
HISTFILE=~/.zsh_history

# source
source "$HOME/.config/zsh/aliases.zsh"

# Starship
eval "$(starship init zsh)"

# GPG key 
export GPG_TTY=$(tty)

fpath+=${ZDOTDIR:-~}/.zsh_functions



