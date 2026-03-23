# Kiro CLI pre block. Keep at the top of this file.
kiro-cli update >/dev/null 2>&1
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.pre.zsh"
###############################################################
### This is Sal's standard .zshrc; use as a starting point
### if just are getting started with zsh. You will have to
### customize the ENVIRONMENT VARIABLES.
###############################################################

OS_ID=$(source /etc/os-release; echo $ID)
if [ $TERM != linux ] && toe -a | grep -qs $TERM-256color
then
   TERM=$TERM-256color
fi

function hostip() { ipconfig.exe | grep -A 10 "WSL (Hyper-V firewall)" | grep "IPv4 Address" | awk '{print $NF}' | tr -d '\r' }

#sudo sed -i "s/nameserver .*/nameserver $(hostip)/" /etc/resolv.conf

if [[ ! -z $WSLENV ]]; then
   export DISPLAY=$(hostip):0
   nc -w1 $(hostip) 6000 && xset q >/dev/null 2>&1 && _x_status=green || _x_status=red
   if [[ $_x_status = red ]]; then
     echo -e "\033[33mNo X11; falling back to WSLg\033[0m"
     DISPLAY=":0"
     xset q >/dev/null 2>&1 && _x_status=green || _x_status=red
   fi

elif [[ -z $DISPLAY ]]; then
    # If X11 display can be reached directly, do it that way
    # in preference to display tunneled over SSH; more efficient.
    _REMOTE_IP=${SSH_CLIENT%% *}
    _REMOTE_IP=${_REMOTE_IP:=127.0.0.1}

    # the nc -w1 avoids long delay if X11 is not running
    _CAND_DISPLAY="${_REMOTE_IP}:0"
    _CAND_PORT=6000
    [[ "$_CAND_DISPLAY" =~ '^[^:]*:([0-9]+)(\.[0-9]+)?$' ]] && _CAND_PORT=$((6000 + match[1]))

    if [[ ! -z $SSH_CLIENT ]] &&
       nc -w1 $_REMOTE_IP $_CAND_PORT < /dev/null &&
       xset q -display $_REMOTE_IP:0 > /dev/null 2>&1
    then
      export DISPLAY=$_REMOTE_IP:0
#    else
#      # for WSL2
#      export DISPLAY=$(awk '/nameserver / {print $2; exit}' /etc/resolv.conf 2>/dev/null):0
#      # export DISPLAY=${DISPLAY:-127.0.0.1:0}
    fi
	# X11 TCP port = 6000 + DISPLAY number (e.g. :0 -> 6000, :10.0 -> 6010)
	unset X11_DPY_PORT
	[[ -n "$DISPLAY" && "$DISPLAY" =~ '^[^:]*:([0-9]+)(\.[0-9]+)?$' ]] && X11_DPY_PORT=$((6000 + match[1]))

	if [[ $DISPLAY = ?*:* ]]; then
	  nc -w1 ${DISPLAY/:*/} ${X11_DPY_PORT:-6000} && xset q >/dev/null 2>&1 && _x_status=green || _x_status=red
	else
	  echo "RISK OF HANG HERE" &&   xset q >/dev/null 2>&1 && _x_status=green || _x_status=red
	fi
fi


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
PATH=~/bin:~/.local/bin:$PATH

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

## load any secret keys
[ -f ~/.credentials ] && . ~/.credentials

export LESSOPEN='|lesspipe.sh %s'
#export LESS=''

#export TOOLS_DIR=~/tools

###############################################################
### PATH CONSTRUCTION
###############################################################

PATH=$PATH:/snap/bin

###############################################################
### Stuff...
###############################################################

setopt HIST_IGNORE_SPACE
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

export NO_AT_BRIDGE=1 ; # https://unix.stackexchange.com/a/230442

export SUDO_EDITOR=vim


if [[ -d $HOME/.nvm ]]
then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# place this after nvm initialization!
autoload -U add-zsh-hook
load-nvmrc() {
  local node_version="$(nvm version)"
  local nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$node_version" ]; then
      nvm use
    fi
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
fi

export QUOTING_STYLE=escape
eval $(dircolors $HOME/bin/dircolors.txt)

eval "$(direnv hook zsh)"

if [ $TILIX_ID ] || [ $VTE_VERSION ]; then
  # echo "vte init for tilix"
  source /etc/profile.d/vte.sh
fi

if [ -f $HOME/.custom.sh ]
then
  echo "Now sourcing $HOME/.custom.sh"
  source $HOME/.custom.sh
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="/home/dev/.sdkman"
[[ -s "/home/dev/.sdkman/bin/sdkman-init.sh" ]] && source "/home/dev/.sdkman/bin/sdkman-init.sh"

# Kiro CLI post block. Keep at the bottom of this file.
[[ -f "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh" ]] && builtin source "${HOME}/.local/share/kiro-cli/shell/zshrc.post.zsh"

# bun completions
[ -s "/home/dev/.bun/_bun" ] && source "/home/dev/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
