#!/bin/bash

# Access Skytap REST API objects as XML
# Usage:
#    skapi [CURL_OPTS] [https://cloud.skytap.com/]RESOURCE
#
# Example:
#     skapi get configurations
#     skapi get https://cloud.skytap.com/configurations
#     skapi get v2/configurations/123456 | xpath /name
# TODO: deal with count/offset; defaults to count=smallnumber
function skapi() {
    local verb=$( echo "$1" | tr a-z A-Z)
    shift;
    local args=("$@")
	local lastPos=$(( ${#args[*]} - 1 ))
	local noun=${args[$lastPos]}
	noun=${noun#https://cloud.skytap.com}
	unset args[$lastPos]
 	curl -Ls \
        -X "${verb}" \
        -H "Authorization: Basic $CRED" \
        -H Accept:text/xml \
        "${args[@]}" \
        "https://cloud.skytap.com/${noun}" |
	trace
}

function trace() {
  if [[ $DEBUG = 1 ]]
  then
    tee >(cat - >&2)
  else
    cat
  fi
}

# Wrapper for most common use of xmlstarlet sel
function xsl() {
	xmlstarlet sel -T -t "$@" -n | trace
}

# Extract content matching XPATH from XML input
# Usage: cat books.xml | xpath //author/last-name
function xpath() {
	xmlstarlet sel -T -t -v "$1" -n | trace
}

HOSTNAME=amqhost
CRED=$(echo -n smendola@phtcorp.com:552d965dbd403a52dbbd7e3ecd41f9ddc5f0f338 | base64 | tr -d '\n')

# Process the options
while getopts :123456789dih:v OPTNAME
do
    case $OPTNAME in
    \?) # Option not recognized
        echo "$0: Unknown option $OPTARG" >&2
        exit 1;;
    d)    DEBUG=1; set -xv;;
    i)    INTERACTIVE=1; VERBOSE=1;;
    h)    HOSTNAME=$OPTARG; shift;;
    v)    VERBOSE=1;;
    [1-9]) POS="[$OPTNAME]";;
    *)    huh?
    esac
done
shift $(( $OPTIND - 1 ))

cfg_urls=( $(skapi get "v2/configurations?scope=me&query=status:running" | xpath "//configuration${POS}/url") )
if [[ ${#cfg_urls[@]} = 0 ]]
then
    echo "$0: No matching configurations" >&2
    exit 1
elif [[ ${#cfg_urls[@]} -gt 1 ]]
then
    if [[ $INTERACTIVE != 1 ]]
    then
        echo "Too many matching configurations" >&2
        exit 1
    fi
fi

for url in "${cfg_urls[@]}"
do
    if [[ $VERBOSE = 1 ]]
    then
        # -m -v -v -v causes all output to be contingent on the -m match
        skapi get "${url}" |
            xsl -m ".//vm/*/interface[hostname='${HOSTNAME}']/*/service[internal_port='22']" \
                -v 'external_port' \
                -v '" "' \
                -c '/*/name' ;# Note leading / here
	else
		skapi get "${url}" |
			xsl -m ".//vm/*/interface[hostname='${HOSTNAME}']/*/service[internal_port='22']" \
                -v 'external_port'

	fi
done
