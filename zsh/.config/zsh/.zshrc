#!/usr/bin/env zsh
#zmodload zsh/zprof

#████████████████████████████████████████████████████████████████████████████
#
#
#              ███████╗███████╗██╗  ██╗██████╗  ██████╗
#              ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#                ███╔╝ ███████╗███████║██████╔╝██║     
#               ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
#           ██╗███████╗███████║██║  ██║██║  ██║╚██████╗
#           ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#        
#           GitHub:  https://github.com/fcarvalhopacheco
#        
#           References:
#               - https://www.strcat.de/dotfiles/
#               - https://github.com/ChristianChiarulli/Machfiles/tree/master/zsh
# 
#████████████████████████████████████████████████████████████████████████████
#########################################################
# Test and then source the FUNCTIONS file.
# -f true if file exists and is a regular file. 
# See: man zshmisc | less -p "^CONDITIONAL EXPRESSIONS"
#########################################################
if [ -f $ZDOTDIR/zshfunctions ]; then
    source $ZDOTDIR/zshfunctions
else
    print "Note: $ZDOTDIR/zshfunctions is unavailable."
fi

# zsh_add_file function 
# Allows you to easily source a file in your zsh configuration 
# directory ($ZDOTDIR) by passing its name as an argument. 
# If the file exists, it will be sourced and its contents will be executed 
# in the current shell environment. If the file does not exist, an error msg
# will be displayed on the prompt.

#zsh_add_file ".zshenv"       - .zshenv is automatically sourced by Zsh for each shell session
zsh_add_file "zshoptions"
zsh_add_file "zshaliases"
zsh_add_file "zshcompctl"
zsh_add_file "zshcursor"
zsh_add_file "zshbindings"
zsh_add_file "zshstyle"
zsh_add_file "zshprompt"


# Plugins
zsh_add_completion "conda-incubator/conda-zsh-completion" false
zsh_add_plugin "hlissner/zsh-autopair"
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"

# Homebrew
eval "$(/usr/local/bin/brew shellenv)"

# Zoxide
eval "$(zoxide init zsh)"

# zprof
