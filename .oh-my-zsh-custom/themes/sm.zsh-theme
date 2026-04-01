# based on kolo.zsh-theme
autoload -U colors && colors

autoload -Uz vcs_info

zstyle ':vcs_info:*' stagedstr '%F{green}●%F{11}'
zstyle ':vcs_info:*' unstagedstr '%F{yellow}●%F{11}'
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:(sv[nk]|bzr):*' branchformat '(BF) %b%F{red}:%F{11}%r'
zstyle ':vcs_info:*' enable git svn
theme_precmd () {
    if [[ -z $(git ls-files --other --exclude-standard 2> /dev/null) ]] {
        zstyle ':vcs_info:*' formats ' %F{green}[%b%c%u%F{green}]'
    } else {
        zstyle ':vcs_info:*' formats ' %F{green}[%b%c%u%F{red}●%F{green}]'
    }

    vcs_info
    
    # Set virtualenv indicator
    if [[ -n "$VIRTUAL_ENV" ]]; then
        VENV_PROMPT=" %F{cyan}($(basename $VIRTUAL_ENV))%f"
    else
        VENV_PROMPT=""
    fi
}

MYBG=${MYBG:-012}
setopt prompt_subst

# force red prompt BG for root
if [[ $(id -u) = 0 ]]; then
	MYBG=160
fi

if [[ "$SSH_CONNECTION" && $(id -u) = 0 ]]; then
   _m_color=black
elif [[ "$SSH_CONNECTION" ]]; then
  _m_color=red
else
  _m_color=white
fi

PROMPT='%{%(?..
${(%)BG[001]}[$?]$reset_color
)
$BG[$MYBG] %F{$_m_color}%m%F{white}: %B%F{yellow}%~%B%F{green}${vcs_info_msg_0_}${VENV_PROMPT} $reset_color%}
%# '

# Prints running command in title bar
# Differs from OMZ default in that it prepends %~
omz_termsupport_preexec () {
    emulate -L zsh
    setopt extended_glob
    local CMD=${1[(wr)^(*=*|sudo|ssh|rake|-*)]}
    local LINE="${2:gs/$/\\$}"
    LINE="[%~]: ${LINE:gs/%/%%}"
    title "$CMD" "%100>...>$LINE%<<"
}

autoload -U add-zsh-hook
add-zsh-hook precmd  theme_precmd

### The end effect of the following is to add numeric prefix
#   to window label, to make them easier to distinguish
#   in Windows taskbar.cls
_tty=$(tty)
_tty=${_tty##*/}

# This is supposed to be the minified window title
# On Win10/bash it becomes the window title and taskbar button
ZSH_THEME_TERM_TAB_TITLE_IDLE='%m: %~'

# This is the window title. On Windows, it is also the label used in the
# task bar button. BTW, %l comes close to ${_tty} but not quite
ZSH_THEME_TERM_TITLE_IDLE='%m: %~'

