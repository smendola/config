#!/bin/bash

declare -a PATTERNS=("*.java" "*.xml" "*.js" "*.json" "*.sql")

# TODO I have a better impl of join in hz-dev VM
function join() {
    local IFS SEP res
    SEP="$1"
    shift
    IFS=":"
    res="$*"
    echo "${res//:/$SEP}"
}

find .  -type f \
        \( -name $(join " -o -name " ${PATTERNS[*]}) \) \
        -print \
        -exec bash -c 'expand -i -t 4 "$0" > "$0.detab" && mv -v "$0.detab" "$0"' {} \;
