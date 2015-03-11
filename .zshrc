###############################################################
### This is Sal's standard .zshrc; use as a starting point
### if just getting started with cygwin. You will have to
### customize the ENVIRONMENT VARIABLES.
###############################################################

# First-time boot setup
~/bin/post-vagrant-config.sh

OS_ID=$(source /etc/os-release; echo $ID)

if toe -a | grep -qs $TERM-256color
then
   TERM=$TERM-256color
fi

# If X11 display can be reached directly, do it that way
# in preference to display tunneled over SSH; more efficient.
_REMOTE_IP=$(eval set $SSH_CLIENT; echo $1)
# the nc -w1 avoids long delay if X11 is not running
if [ ! -z $SSH_CLIENT ] &&
   nc -w1 $_REMOTE_IP 6000 < /dev/null &&
   xset q -display $_REMOTE_IP:0 > /dev/null 2>&1
then
  export DISPLAY=$_REMOTE_IP:0
else
  export DISPLAY=${DISPLAY:-:0}
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
DISPLAY=%F{$_x_status}$DISPLAY%f"



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


###############################################################
### ENVIRONMENT VARIABLES
### Adjust these values to your own environment; in particular:
###  - CATALINA_HOME (where you installed tomcat)
###  - CATALINA_BASE (probably ingore this)
###  - JAVA_HOME
###  - WS (where you git-clone'd studywork-ng) (Unix style path)
###  - WORKSPACE (computed from $WS; absolute path, DOS style)
### Recommend installing all dev tools/sdk's in a single place, e.g.
### C:\tools, and point TOOLS_DIR to that dir. Put JDK there, as
### well (e.g. $TOOLS_DIR/jdk7)
###
### Keep in mind:
###   The less you customize this file, the easier life will be
###   when it comes time to update/merge with latest version from
###   master.
###############################################################
#export JAVA_HOME=/usr/lib/jvm/java-1.8.0
export JAVA_HOME=/usr/java/jdk1.7.0_75

export CATALINA_HOME=/opt/tomcat7
export CATALINA_BASE=~/tomcat-inst

export KANDO=ssh://kando/studywork-ng.git
#export MAVEN_OPTS="-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"

export WS=$(readlink -f ~/ng)
# DO NOT CHANGE the following WORKSPACE= line; though you may change WS= line
# The following line results in WORKSPACE being set to an absolute, DOS style
# path, which Java and some other tools require.
# The trailing slash is important! If ~ng is a Windows symbolic link
# (try type mklink) and not a Cygwin symbolic link, then the absolutization
# fails unless the trailing slash is there.
export WORKSPACE=$(mix $WS/)
export BUILD_NUMBER=SNAPSHOT

export LESSOPEN='|lesspipe.sh %s'
# LESS has to be set after oh-my-zsh is loaded
#export LESS=''

#export TOOLS_DIR=~/tools
export AC_DIFF_CLI='diffuse %1 %2'

###############################################################
### PATH CONSTRUCTION
###############################################################

PATH=$(unx "$JAVA_HOME/bin"):$PATH
PATH=$(unx "$WORKSPACE/tools"):$PATH
PATH=$CATALINA_HOME/bin:$CATALINA_BASE/bin:$JAVA_HOME/bin:$PATH


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
  #echo -n -e "\ec\e[3J" ;# Clear the scrollback buffer
  tput reset
  zle clear-screen ;# redisplays the prompt and current command line
}

bindkey '\xc2\x8c' cls ;# C-Shift-L
bindkey '\e^L' cls ;# C-M-L

histchars='!;#'

ZSH=$HOME/.oh-my-zsh
if [[ -f $ZSH/oh-my-zsh.sh ]]
then
    plugins=(DISABLED-git DISABLED-mvn pip dircycle encode64 urltools)
    # Path to your oh-my-zsh configuration.
    ZSH_THEME="sm"
    #MYBG=057
    MYBG=012
    source $ZSH/oh-my-zsh.sh
else
    echo "*** Oh-my-zsh is not present"
fi

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

my-server localhost:2080

# do this last, it will error out if path elems do not exist

# Allows e.g: cd access-control-implementation
# from anywhre. try this:
# $ cd ac<TAB>im<TAB>
# or even try it without cd; try
# $ a-c-im<TAB><ENTER>
if readlink -e $WS > /dev/null
then
    cdpath=($WS/test/robotframework/src/main $WS/services/* $WS/api/src/main/java/com/phtcorp/sw)
fi

export SUDO_EDITOR=vim

# Here's everyone's chance to add custom stuff
if [ -f $HOME/.custom.sh ]
then
  echo "Now sourcing $HOME/.custom.sh"
  source $HOME/.custom.sh ]
else
  echo "No customizations in $HOME/.custom.sh; how sad."
fi

