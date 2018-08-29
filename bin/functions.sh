#!/bin/echo Not a stand-alone program:

# Failure to style, as it may in Jenkins, for instance,
# should not cause program to fail
#(set +e; tput sgr0 2>/dev/null) || tput () { true; }
tput() {
    command tput "$@" 2> /dev/null || true; #echo -nE "<$@>"
}


fail () {
    echo -e "$1" 2>&1
    exit 1
}

heading ()
{
    (
        set +xv
        local cols=$(tput cols)
        local len=${#1}
        local half=$(( (cols - len - 2) / 2))
        local pad=$(printf '%*s' ${half})
        echo ""
        style bold bg-blue
        echo -n "$pad $1 $pad"
        style normal
        echo ""
    ) || echo "$1"
}

style () {
  ( set +xv
     for style
    do
      case $style in
        */*) style ${style%/*} bg-${style#*/} ;;
        black) tput setaf 0;;
        red) tput setaf 1;;
        green) tput setaf 2;;
        yellow) tput setaf 3;;
        blue) tput setaf 4;;
        magenta) tput setaf 5;;
        cyan) tput setaf 6;;
        white) tput setaf 7;;

        bg-black) tput setab 0;;
        bg-red) tput setab 1;;
        bg-green) tput setab 2;;
        bg-yellow) tput setab 3;;
        bg-blue) tput setab 4;;
        bg-magenta) tput setab 5;;
        bg-cyan) tput setab 6;;
        bg-white) tput setab 7;;

        dim) tput dim;;
        bold) tput bold;;
        reverse) tput rev;;
        underline) tput smul;;

        normal) tput sgr0;;

        *) echo -n "<$style>";;
      esac
    done
  )
}

sub-heading ()
{
    (
        set +xv
        echo ""
        style reverse bg-white cyan dim
        echo -n " $1 "
        style normal
        echo ""
    )
}

repl ()
{
    echo "$(style yellow)Interactive REPL. Enter '.' by itself to end.$(style normal)"
    local line
    while :
    do
      read -e -p '> ' line
      [[ ${line} = . ]] && break;
      eval "${line}" || true
    done
}

# Global variable PAUSE
pause ()
{
    [[ ${PAUSE} != 1 ]] && return

    read -n 1 -p "$(style bold)${1}$(style normal) [Press ENTER]:"
    test -z "$REPLY" && return ;# hitting RETURN

    echo ''
    case ${REPLY} in
        (\ ) return;;
        (r) repl;;
        (q) exit
            ;;
        (t) tree "${PWD}"
            pause "$@"
            ;;
        (T) tree -l "${PWD}"
            pause "$@"
            ;;
        (.) echo "No more pausing"
            PAUSE=0
            ;;
        (e|!) read -e -p "Command to execute inside this shell: "
            eval "$REPLY" || true
            pause "$@"
            ;;
        (*) echo "Huh?"
            pause "$@"
            ;;
    esac
}
