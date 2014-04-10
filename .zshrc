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
### LOAD ALL STANDARD ALIASES AND FUNCTIONS
###############################################################
[ -f ~/.aliases ] && . ~/.aliases


###############################################################
### ENVIRONMENT VARIABLES
### Adjust these values to your own environment; in particular:
###  - CATALINA_HOME (where you installed tomcat)
###  - CATALINA_BASE (probably ingore this)
###  - JAVA_HOME
###  - PHANTOMJS_BIN (where you installed PhantomJS)
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
export JAVA_HOME=$(mix "/c/tools/jdk7")
export CATALINA_HOME=/c/tools/tomcat
export CATALINA_BASE=$CATALINA_HOME

export KANDO=ssh://kando/studywork-ng.git
export MAVEN_OPTS="-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"

export PHANTOMJS_BIN=c:/tools/phantomjs/phantomjs.exe
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
export LESS='-R -x4'

export TOOLS_DIR=/c/tools

export JENKINS_HOME=$(mix ~/jenkins)

###############################################################
### PATH CONSTRUCTION
###############################################################

PATH=~/bin.personal:~/bin:$PATH
PATH=$(unx "$JAVA_HOME/bin"):$PATH
PATH=$(unx "$WORKSPACE/tools"):$PATH


# Add all /c/tools/springsource/*/bin and  /c/tools/*/bin to PATH
#
# NOTE: some of these packages may contain binaries
#       whose names confict with cygwin utils, e.g.
#       AccuRev has a "diff.exe"
#       For this reason, it's safer to add these to the PATH
#       *after* not in before, /bin
#
for d in $TOOLS_DIR/springsource/* $TOOLS_DIR/*
do
    if [ -d $d/Scripts ]
    then
        PATH=$PATH:$d/Scripts
    fi
    if [ -d $d/bin ]
    then
        PATH=$PATH:$d/bin
    else
        PATH=$PATH:$d
    fi
done

# There is a python in /usr/bin, but it doesn't seem to work well,
# let's move the non-cygwin python up in front of /usr/bin
PATH=/c/tools/Python27:/c/tools/Python27/Scripts:$PATH

# Remove various Windows crap from PATH
PATH=$(pp | egrep -iv '/c/Program|/AppData/' | tr '\012' :)

# but add back this one for sqlcmd
PATH=/c/Program\ Files/Microsoft\ SQL\ Server/100/Tools/Binn:$PATH


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
  echo -n -e "\ec\e[3J" ;# Clear the scrollback buffer
  zle clear-screen ;# redisplays the prompt and current command line
}

bindkey '\xc2\x8c' cls ;# C-Shift-L
bindkey '\e^L' cls ;# C-M-L

histchars='!;#'

ZSH=$HOME/.oh-my-zsh
if [[ -f $ZSH/oh-my-zsh.sh ]]
then
    plugins=(DISABLED-git DISABLED-mvn pip dircycle encode64 )
    # Path to your oh-my-zsh configuration.
    ZSH_THEME="sm"
    #MYBG=057
    MYBG=012
    source $ZSH/oh-my-zsh.sh
else
    echo "*** Oh-my-zsh is not present"
fi



# Allows e.g: cd access-control-implementation
# from anywhre. try this: 
# $ cd ac<TAB>im<TAB>
# or even try it without cd; try 
# $ a-c-im<TAB><ENTER>
cdpath=($WS/test/robotframework/src/main $WS/services/*)



export CATALINA_OPTS="-javaagent:C:/tools/jrebel/jrebel.jar -Drebel.remoting_plugin=true"
#  "-Drebel.spring_data_plugin=true"