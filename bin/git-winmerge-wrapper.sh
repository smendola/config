#!/bin/sh

# support non-cygwin use of git
type cygpath > /dev/null 2>&1 || alias cygpath=dummy-cygpath

if (($PRINT_ARGS))
then
  echo "$0:"
  for x in "$@"
  do
    echo ">>>" $x
  done
fi

if [[ $# < 2 || $# > 4 ]]
then
  echo "Usage: ${0##*/} left right [base [merged]]"
  exit -1
fi

left=$1
right=$2
base=$3
merged=$4

# Somewhat accurate attempt to extract the file name.
# Note that ANY of base, left, right and merged could be temp files
# but base is always not temp in case of diff (as opposed to merge)
for name in $left $right $base $merged
do
    # Note: msysgit uses c:/users/.../Temp/... not /tmp/...
    if [[ $name && $name != /tmp/* && $name != /dev/null && $name != */Temp/* ]]
    then
        break
    fi
done



if [[ $left = /dev/null ]]
then
    echo "*** New file $name"
    exit
elif [[ $right == /dev/null ]]
then
    echo "*** Deleted file $name"
    exit
elif cmp -s "$left" "$right" 
then
    echo IDENTICAL: $left $right
    exit
fi

# WinmergeU cryptic options:
#   -ul -> no MRU for left
#   -wl -> read-only for left
#   -dl xxx -> label xxx for left
#   Similarly for for right: -ur, -wr, -dr xxx
#   -e exit on ESC key
#   -u -> no MRU, left or right

add()
{
	local arg
    for arg
    do
		opts[${#opts[*]}]=$arg
    done
}

declare -a opts

if [[ $left = /tmp/* ]]
then
	add -wl -dl "[OTHER] $name"
else
	add -dl "[WORKSPACE] $name"
fi

if [[ $right = /tmp/* ]]
then
	add -wr -dr "[OTHER] $name"
else
	add -dr "[WORKSPACE] $name"
fi


left=$(cygpath -m "$left")
right=$(cygpath -m "$right")

add "$left" "$right"
[[ $merged ]] && add "$(cygpath -m "$merged")"

winmergeU -e -u "${opts[@]}"
