#!/usr/bin/env zsh
# zmodload zsh/zprof

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

# zsh_add_file funtion 
# Allows you to easily source a file in your zsh configuration 
# directory ($ZDOTDIR) by passing its name as an argument. 
# If the file exists, it will be sourced and its contents will be executed 
# in the current shell environment. If the file does not exist, an error msg
# will be displayed on the prompt.
zsh_add_file ".zshenv"
zsh_add_file "zshoptions"
zsh_add_file "zshaliases"
zsh_add_file "zshcompctl"
zsh_add_file "zshbindings"
zsh_add_file "zshstyle"
export PROMPT_SHOW_PYTHON=true
zsh_add_file "zshprompt"

# Homebrew
eval "$(/usr/local/bin/brew shellenv)"


# zprof


