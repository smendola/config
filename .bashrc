###############################################################
### This is Sal's standard .bashrc; use as a starting point
### if just getting started with cygwin. You will have to
### customize the ENVIRONMENT VARIABLES.  
###############################################################

[[ $TERM ]] && echo DOT-BASHRC $HOME $TERM

# If running in MSYS/MINGW, use some replacements for cyg programs
[[ $(uname) = MINGW* ]] && PATH=~/bin/msys:$PATH


###############################################################
### SHELL SETTINGS
###############################################################
shopt -u nullglob ; # prevents cd wrong* from causing cd ~
shopt -u progcomp ; # having trouble with that feature
shopt -s globstar 2> /dev/null;  # foo/**/bar matches bar at any subdir depth; not supported in MINGW

unset HISTFILE
histchars='!;'

###############################################################
### LOAD ALL MY STANDARD ALIASES AND FUNCTIONS
###############################################################
[ -f ~/.bashrc.aliases ] && . ~/.bashrc.aliases



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
export LESS=' -R '

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

###############################################################
### Stuff...
###############################################################
  
if [[ $XCONSOLE ]]; then
  prat 1 7 31
elif [[ $TERM == cygwin ]]; then
  prat 1 46
else
  prat 1 7 34 47
fi

###############################################################
### GIT FEATURES
### Normally, these are only loaded with --login shells, but
### I want them even if simple "exec bash"
###############################################################
type __git_ps1 > /dev/null 2>&1 || if [[ -f /etc/bash_completion.d/git ]] 
then
    . /etc/bash_completion.d/git
elif [[ -f /etc/git-prompt.sh ]] 
then
    . /etc/git-prompt.sh
fi

if [ -f /etc/bash_completion ]
then
    complete -o default -o nospace -F _git config
fi

