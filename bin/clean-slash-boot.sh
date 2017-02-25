#!/bin/bash

CUR_REL=$(uname -r | sed -r 's/([0-9.-]+)-[^0-9]+/\1/')

echo "Current release: $CUR_REL"

dpkg --list \
	| grep -E "linux-image-|linux-headers-" \
	| awk '{ print $2 }' \
    | sort -V \
    | sed -n "/${CUR_REL}/q;p" \
	| xargs echo sudo apt-get -y purge \
    | tee >(sh)
