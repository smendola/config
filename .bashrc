env > ENV
###############################################################
### This is Sal's standard .bashrc
###############################################################

[[ $TERM ]] && echo DOT-BASHRC $TERM

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
###############################################################
export JAVA_HOME=$(mix /c/tools/jdk6)
#export CATALINA_HOME=....

#export LESSOPEN='|lesspipe.sh %s'
#CYGWIN32='tty'

export LESSOPEN="| source-highlight -f esc -i %s"
export LESS=' -R '


###############################################################
### PATH CONSTRUCTION
###############################################################
PATH=~/bin:~/bin.personal:$PATH
PATH=$(unx $JAVA_HOME)/bin:$PATH

# Add all /c/tools/springsource/*/bin and  /c/tools/*/bin to PATH
for d in /c/tools/springsource/* /c/tools/*
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

# These tools have binaries at top level, rather than bin
#PATH=/tools/python:/tools/android-sdk/platform-tools:/tools/play:$PATH

###############################################################
### Stuff...
###############################################################
#prat 5 32
#prat 7 31
#prat 7 1 32 46
  
if [[ $XCONSOLE ]]; then
  prat 1 7 31
elif [[ $TERM == cygwin ]]; then
  prat 1 46
else
  prat 1 7 34 47
fi

if [ -f /etc/bash_completion ]
then
    complete -o default -o nospace -F _git config
fi

export KANDO=kando@engvmkando:studywork-ng.git
export WORKSPACE=$(mix ~/ng)
export AXIS2_HOME=$(mix /c/tools/axis2)
export JENKINS_HOME=$(mix ~/jenkins)
export MAVEN_OPTS="-Xms512m -Xmx1024m -XX:PermSize=256m -XX:MaxPermSize=512m"

export PYTHONPATH=~/tools/PatchAuditTrail/src

export SKYTAP_CONFIGURATION=482220
export SKYTAP_VM=1044952

export PHANTOMJS_BIN=c:/tools/phantomjs/phantomjs.exe

export BUILD_NUMBER=SNAPSHOT
