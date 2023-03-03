#!/usr/bin/env zsh

#     ███████╗███████╗██╗  ██╗██████╗  ██████╗
#     ╚══███╔╝██╔════╝██║  ██║██╔══██╗██╔════╝
#       ███╔╝ ███████╗███████║██████╔╝██║     
#      ███╔╝  ╚════██║██╔══██║██╔══██╗██║     
#  ██╗███████╗███████║██║  ██║██║  ██║╚██████╗
#  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝
#                                             
#  Reference
#    : https://www.strcat.de/dotfiles/

####################################################
#
# -f true if file exists and is a regular file. 
#
# See: 
#   $ man zshmisc | less -p "^CONDITIONAL EXPRESSIONS"
#
####################################################

# Test and then source EXPORTED variables.
if [ -f $ZDOTDIR/.zshenv ]; then
        source $ZDOTDIR/.zshenv
else
        print "Note: $ZDOTDIR/.zshenv is unavailable."
fi


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/fcp/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/fcp/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/fcp/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/fcp/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<


# test and then source some options
if [ -f $ZDOTDIR/zshoptions ]; then
    source $ZDOTDIR/zshoptions
else
    print "Note: $ZDOTDIR/zshoptions is unavailable."
fi


# Test and then source ALIAS variables.
if [ -f $ZDOTDIR/zshaliases ]; then
        source $ZDOTDIR/zshaliases
else
        print "Note: $ZDOTDIR/zshaliases is unavailable."
fi


# # Test and then source the functions.
# if [ -f ~/.zsh/zshfunctions ]; then
#         source ~/.zsh/zshfunctions
# else
#         print "Note: ~/.zsh/zshfunctions is unavailable."
# fi
#
# # Test and then source the lineeditor
# if [ -f ~/.zsh/zshzle ]; then
#         source ~/.zsh/zshzle
# else
#         print "Note: ~/.zsh/zshzle is unavailable."
# fi
#

# Test and then source the COMPLETIONSYSTEM
if [ -f $ZDOTDIR/zshcompctl ]; then
    source $ZDOTDIR/zshcompctl
else
    print "Note: $ZDOTDIR/zshcompctl is unavailable."
fi

# Test and then source the KEYBINDINGS
if [ -f $ZDOTDIR/zshbindings ]; then
        source $ZDOTDIR/zshbindings
else
        print "Note: $ZDOTDIR/zshbindings is not available."
fi


# Test and then source the ZSTYLES
if [ -f $ZDOTDIR/zshstyle ]; then
        source $ZDOTDIR/zshstyle
else
        print "Note: $ZDOTDIT/zshstyle is unavailable."
fi
#
# # Test and then source the wretched rest 
# if [ -f ~/.zsh/zshmisc ]; then
#         source ~/.zsh/zshmisc
# else
#         print "Note: ~/.zsh/zshmisc is unavailable."
# fi
#
# # http://www.unixreview.com/documents/s=9513/ur0501a/ur0501a.htm
# if [ -f ~/.zsh/zshkeep ]; then
#         source ~/.zsh/zshkeep
# else
#         print "Note: ~/.zsh/zshkeep is unavailable."
# fi
#

# Homebrew
eval "$(/usr/local/bin/brew shellenv)"


