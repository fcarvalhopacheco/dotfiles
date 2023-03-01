#
#     ███████╗███████╗██╗  ██╗███████╗███╗   ██╗██╗   ██╗
#     ╚══███╔╝██╔════╝██║  ██║██╔════╝████╗  ██║██║   ██║
#       ███╔╝ ███████╗███████║█████╗  ██╔██╗ ██║██║   ██║
#      ███╔╝  ╚════██║██╔══██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝
#  ██╗███████╗███████║██║  ██║███████╗██║ ╚████║ ╚████╔╝ 
#  ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  
#                                                        
#  Reference
#    : https://thevaluable.dev/zsh-install-configure-mouseless/
#

# XDG Base Directory Specification
#   : http://standards.freedesktop.org/basedir-spec/basedir-spec-latest.html
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$XDG_CONFIG_HOME/local/share"
export XDG_CACHE_HOME="$XDG_CONFIG_HOME/cache"


# (( ${+*} )) = if variable is set don't set it anymore
# Adpated from https://www.strcat.de/dotfiles/

# Set default terminal emulator
(( ${+TERMINAL} )) || export TERMINAL="alacritty"

# Set default browser
(( ${+BROWSER} )) || export BROWSER="brave"

# Term color
(( ${+TERM} )) || export TERM="xterm-256color"


# Set default directories
export WORKSPACE="$HOME/Documents/workspace"
export DOTFILES="$HOME/.dotfiles"


# Editor
export VISUAL="nvim"                
export EDITOR="nvim"                             


# Zsh enviroment variables
export HISTFILE="$ZDOTDIR/.zhistory"    # History filepath
export HISTSIZE=10000                   # Maximum events for internal history
export SAVEHIST=10000                   # Maximum events in history file


# PATH
[ -d "${HOME}/.config/zsh" ] && PATH="${PATH}:${HOME}/.config/zsh"
[ -d "${HOME}/.local/bin" ] && PATH="${PATH}:${HOME}/.local/bin"
[ -d "/usr/local/bin" ] && PATH="${PATH}:/usr/local/bin"



# # Check some directories and add existing to $PATH
# for dir in \
#       /usr/local/bin \
#       /usr/local/sbin \
#       /usr/dietlibc/bin \
#       /usr/X11R6/bin \
#       /usr/share/texmf/bin \
#       /usr/X11R6/libexec/fvwm/2.4.16 \
#       /usr/lib/java/bin \
#       /var/qmail/bin \
#       /usr/pkg/bin \
#       /usr/pkg/sbin \
#   /usr/lib/gentoolkit/bin \
#   /home/dope/dev-bin/9/bin \
#   /opt/ati/bin \
#   /opt/Acrobat7 \
#       /usr/games \
#   /usr/games/bin \
#   /cygdrive/c/WINDOWS/system32 \
#   /cygdrive/c/WINDOWS \
#   /cygdrive/c/WINDOWS/System32/Wbem
# do
#       [ -d "${dir}" ] && PATH="${PATH}:${dir}"
# done


# PS{1,2,3}, RPOMPT, .. 
# The "prompt" of the shell.
#  See zshmisc(1) (/PROMPT EXPANSION) for details.
# 
# %n         $USERNAME.
# @          literal '@'
# %m         machine name.
# %M         The full machine hostname.
# %%         %
# %/         Present working directory ($PWD) (i. e.: /home/$USERNAME)
# %~         Present working directory ($PWD) (i. e.: ~)
# %h         Current history event number.
# %!         Current history event number.
# %L         The current value of $SHLVL.
# %S (%s)    Start (stop) standout mode.
# %U (%u)    Start (stop) underline mode.
# %B (%b)    Start (stop) boldface mode.
# %t / %@    Current time of day, in 12-hour, am/pm format.
# %T         Current time of day, in 24-hour format.
# %*         Current time of day in 24-hour  format,  with  seconds
# %N         The  name  of  the  script,  sourced file, or shell
#            function that zsh is currently executing,
# %i         The line number currently  being  executed  in  the script
# %w         The date in day-dd format.
# %W         The date in mm/dd/yy format.
# %D         The date in yy-mm-dd format.
# %D{string} string  is  formatted  using the strftime function (strftime(3))
# %l         The line (tty) the user is logged in on
# %?         The  return  code of the last command executed just before the prompt
# %_         The status of the parser
# %E         Clears to end of line
# %#         A  `#'  if  the shell is running with privileges, a `%' if not
# %v         The  value  of the first element of the psvar array parameter
# %{...%}    Include a string as a literal escape sequence
# :          literal ':'
# %Nc        "relative path", ie last N components of $PWD.
# >          literal '>'
#
# Some examples:
#  PS1="PS1='%B%n%b@%m:%4c>'"
#  PS1="%B(%b%n@%m%B)%b : %B(%b%3~%B)%b: "
#  PS1=$'%{\e[1;31m%}[%n@%m:%~ ]%{\e[0m%} '
#  PS1=$'%{\e[0;36m%}%n%{\e[0m%}:%{\e[0;31m%}%3~%{\e[0m%}%# ' ## user:~%
#  PS1=$'%{\e[0;36m%}%n%{\e[0m%}:%{\e[0;31m%}%3~%{\e[0m%}%B>%b ' ## user:~>
#  PS1='%n@%m:%4c%1v> ';RPS1=$'%{\e[0;36m%}%D{%A %T}%{\e[0m%}' ## user@host:~> ; Day time(hh:mm:ss)
#  PS1='%B[%b%n%B:%b%~%B]%b$ ' ## [user:~]$
#  PS1=$'%{\e[0;36m%}%n%{\e[0m%}:%20<..<%~%B>%b ' ## user:..c/vim-common-6.0>
#  PS1=$'%{\e[0;36m%}%#%{\e[0m%} ';RPS1=$'%{\e[0;31m%}%~%{\e[0m%}' ## % ; ~
#  PS1=$'%{\e[0;36m%}%n%{\e[0m%}%{\e[0;31m%}%#%{\e[0m%} ';RPS1=$'%{\e[0;31m%}%~%{\e[0m%}' ## user% ; ~
#  PS1='%# ';RPS1='%B%~%b' ## % ; ~ : no colors
#  PS1='%n@%m:%B%~%b> ' ## user@host:~> : no colors
#  PS1=$'%{\e[1;31m%}%B(%b%{\e[0m%}%n@%m%{\e[1;31m%})%{\e[0m%} : %{\e[1;31m%}(%{\e[0m%}%~%{\e[1;31m%})%{\e[0m%}: '
#  PS1=$'%{\e[0;33m%}[%{\e[0m%}%n%{\e[0;33m%}@%{\e[0m%}%m%{\e[0;33m%}:%{\e[0m%}%~%{\e[0;33m%}]%{\e[0m%}%# '
#  PS1=$(echo '\033[1m\033[30m(%/)\033[0m\033[39m\n[%n@%m \033[0m\033[34m%~\033[0m\033[39m]%# ')
#  PS1='%n@%U%m%u %B%30<..<%~%b %(!.#.>)' # user@host (underlined), pwd(bold; max 30 chars.) > or #
#  PS1=$'%{\e[0;31m%}[%{\e[0;36m%}%n%{\e[0;32m%}@%{\e[0;35m%}%m%{\e[0;34m%}:%{\e[0;33m%}%.%{\e[0;31m%}]%{\e[0;0m%}%# '
#  PROMPT=$'%n@%m %0(3c,%c,%~) %0(?,%{\e[0;32m%}=%),%{\e[0;31m%}=(%s)%b %# '
# random colors? sure. no problem ;)
#  $ setopt prompt_subst ; PROMPT=$'[%{\e[$((color=$((30+$RANDOM % 8))))m%}%n@%m %c%{\e[00m%}]%% '
#
#
#
