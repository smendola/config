###############################################################
### This is Sal's standard .zshrc; use as a starting point
### if just getting started with cygwin. You will have to
### customize the ENVIRONMENT VARIABLES.
###############################################################

OS_ID=$(source /etc/os-release; echo $ID)
if [ $TERM != linux ] && toe -a | grep -qs $TERM-256color
then
   TERM=$TERM-256color
fi

if [[ -z $DISPLAY ]]; then
    # If X11 display can be reached directly, do it that way
    # in preference to display tunneled over SSH; more efficient.
    _REMOTE_IP=${SSH_CLIENT%% *}
    # the nc -w1 avoids long delay if X11 is not running
    if [[ ! -z $SSH_CLIENT ]] &&
       nc -w1 $_REMOTE_IP 6000 < /dev/null &&
       xset q -display $_REMOTE_IP:0 > /dev/null 2>&1
    then
      export DISPLAY=$_REMOTE_IP:0
    else
      export DISPLAY=${DISPLAY:-:0}
    fi
fi
xset q >/dev/null 2>&1 && _x_status=green || _x_status=red

# [[ -z $PS18 ]] || print -P "Sourcing file %B%N%b
# SSH_CONNECTION=%B$SSH_CONNECTION%b
# HOST=%B$HOST%b
# OS_ID=%B$OS_ID%b
# USER=%B$USER%b
# TERM=%B$TERM%b
# tty=%B%y%b
# DISPLAY=%F{$_x_status}$DISPLAY%f"
[[ -z $PS1 ]] || print -P "Sourcing file %B%N%b
SSH_CONNECTION=%B$SSH_CONNECTION%b
Logged in as %B$USER@$HOST%b
%B$TERM%b on %B%y%b
DISPLAY=%F{$_x_status}${DISPLAY//\%/%%}%f"

PS4='+%{%F{green}%}%N%{%}:%{%F{yellow}%}%i%{%f%}> '

# These need to be up here, for now; cygpath is in ~/bin
PATH=~/bin:$PATH
PATH=/vagrant/bin:$PATH

###############################################################
### SHELL SETTINGS
###############################################################

unset HISTFILE
histchars='!;#'

GLOBIGNORE=.:..
ESC=$'\e'
# for zsh builtin time command
TIMEFMT="${ESC}[1;33mElapsed: %*E${ESC}[0m"
# for /bin/time
export TIME="${ESC}[1;33mElapsed: %E${ESC}[0m"

# Format trace output with color
# +++file-or-func:11>
PS4="+%{%F{green}%}%N%{$reset_color%}:%{%F{yellow}%}%i%{%f%}> "

###############################################################
### LOAD ALL STANDARD ALIASES AND FUNCTIONS
###############################################################
[ -f ~/.aliases ] && . ~/.aliases
[ -f ~/.aliases.ng ] && . ~/.aliases.ng


export LESSOPEN='|lesspipe.sh %s'
#export LESS=''

#export TOOLS_DIR=~/tools
export AC_DIFF_CLI='meld %1 %2'
export AC_MERGE_CLI='meld  %1%  %a%  %2%  --output=%o%  --auto-merge'

###############################################################
### PATH CONSTRUCTION
###############################################################

# Add all ~/tools/*/bin to PATH
#
# NOTE: some of these packages may contain binaries
#       whose names confict with cygwin utils, e.g.
#       AccuRev has a "diff.exe"
#       For this reason, it's safer to add these to the PATH
#       *after* not in before, /bin
#
# for d in $TOOLS_DIR/*
# do
    # if [ -d $d/Scripts ]
    # then
        # PATH=$PATH:$d/Scripts
    # fi
    # if [ -d $d/bin ]
    # then
        # PATH=$PATH:$d/bin
    # else
        # PATH=$PATH:$d
    # fi
# done

PATH=$PATH:/opt/AccuRev/bin

###############################################################
### Stuff...
###############################################################

setopt extended_glob

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Comment this out to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how many often would you like to wait before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)

zle -N cls
function cls() {
  #tput reset  (this doesn't work with PuTTY, at least not with TERM=xterm)
  echo -n -e "\ec\e[3J" ;# Clear the scrollback buffer
  zle clear-screen ;# redisplays the prompt and current command line
}


histchars='!;#'

ZSH=$HOME/.oh-my-zsh
if [[ -f $ZSH/oh-my-zsh.sh ]]
then
    plugins=(DISABLED-git DISABLED-mvn pip dircycle encode64 urltools)
    # Path to your oh-my-zsh configuration.
    ZSH_THEME="sm"
    MYBG=012
    source $ZSH/oh-my-zsh.sh
else
    echo "*** Oh-my-zsh is not present"
fi
# This needs to be set after oh-my-zsh is loaded, or else
# it gets unset
bindkey '^L' cls ;# C-Shift-L

# This needs to be set after oh-my-zsh is loaded, or else
# it gets unset
bindkey '^L' cls ;# C-Shift-L

# Note: do not move this up near the other variables, e.g. near LESSOPEN;
# oh-my-zsh sets LESS, so our own setting has to be way down here
export LESS='-i -R -x4'

# Strip out all references to "." in PATH, including :: and trailing : which
# apparently are interpreted as .
# . in PATH is a security threat, and also can cause unexpected behaviors.
# TODO: also remove relative paths, such as :bin:
PATH=${PATH/::/:}
PATH=${PATH/:.:/:}
PATH=${PATH/:.\/*:/:}
PATH=${PATH%:}

# deprecated variable, causes warnings to stdout
unset GREP_OPTIONS
unset GREP_COLOR

# do this last, it will error out if path elems do not exist

export SUDO_EDITOR=vim

# NG-specific settings
[ -f ~/.zshrc.ng ] && . ~/.zshrc.ng

# Here's everyone's chance to add custom stuff
if [ -f $HOME/.custom.sh ]
then
  echo "Now sourcing $HOME/.custom.sh"
  source $HOME/.custom.sh
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
