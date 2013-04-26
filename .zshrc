###############################################################
### This is Sal's standard .bashrc; use as a starting point
### if just getting started with cygwin. You will have to
### customize the ENVIRONMENT VARIABLES.  
###############################################################

[[ -z $TERM ]] || echo DOT-BASHRC $HOME $TERM

# If running in MSYS/MINGW, use some replacements for cyg programs
[[ $(uname) = MINGW* ]] && PATH=~/bin/msys:$PATH


###############################################################
### SHELL SETTINGS
###############################################################

unset HISTFILE
histchars='!;#'

GLOBIGNORE=.:..

###############################################################
### LOAD ALL MY STANDARD ALIASES AND FUNCTIONS
###############################################################
[ -f ~/.zshrc.aliases ] && . ~/.zshrc.aliases



###############################################################
### ENVIRONMENT VARIABLES
### Adjust these values to your own environment; in particular:
###  - CATALINA_HOME (where you installed tomcat)
###  - CATALINA_BASE (probably ingore this)
###  - JAVA_HOME
###  - PHANTOMJS_BIN (where you installed PhantomJS)
###  - WORKSPACE (where you git-clone'd studywork-ng)
### Recommend installing all dev tools/sdk's in a single place, e.g.
### C:\tools, and point TOOLS_DIR to that dir. Put JRE there, as
### well (e.g. $TOOLS_DIR/jre6)
###############################################################
export JAVA_HOME=$(mix "/c/tools/jdk6")
export CATALINA_HOME=/c/tools/tomcat
export CATALINA_BASE=$CATALINA_HOME

export KANDO=kando@engvmkando:studywork-ng.git
export MAVEN_OPTS="-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"

export PHANTOMJS_BIN=c:/tools/phantomjs/phantomjs.exe
export WORKSPACE=$(mix ~/ng)
export BUILD_NUMBER=SNAPSHOT

export LESSOPEN='| source-highlight --failsafe -f esc -i %s'
export LESS='-R -x4'

export TOOLS_DIR=/c/tools

export JENKINS_HOME=$(mix ~/jenkins)

###############################################################
### PATH CONSTRUCTION
###############################################################

PATH=~/bin:$PATH
PATH=$(unx "$JAVA_HOME/bin"):$PATH


# Add all /c/tools/springsource/*/bin and  /c/tools/*/bin to PATH
for d in $TOOLS_DIR/springsource/* $TOOLS_DIR/*
do
    if [ -d $d/Scripts ]
    then
        PATH=$d/Scripts:$PATH
    fi
    if [ -d $d/bin ]
    then
        PATH=$d/bin:$PATH
    else
        PATH=$d:$PATH
    fi
done


# Remove various Windows crap from PATH
PATH=$(pp | egrep -iv '/c/Program|/AppData/' | tr '\012' :)

# but add back this one for sqlcmd
PATH=/c/Program\ Files/Microsoft\ SQL\ Server/100/Tools/Binn:$PATH

###############################################################
### Stuff...
###############################################################
  

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
  echo -n -e "\ec\e[3J" ;# Clear the scrollback buffer
  zle clear-screen ;# redisplays the prompt and current command line
}

bindkey '\xc2\x8c' cls ;# C-Shift-L
bindkey '\e^L' cls ;# C-M-L

plugins=(git mvn pip dircycle)# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh
histchars='!;#'
ZSH_THEME="sm"
#MYBG=057
MYBG=021
source $ZSH/oh-my-zsh.sh


