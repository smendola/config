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
	local what=${args[-1]#https://cloud.skytap.com}
	unset args[-1]
	curl -Ls \
        -X "${verb}" \
        -H "Authorization: Basic $CRED" \
        -H Accept:text/xml \
        "${args[@]}" \
        "https://cloud.skytap.com/${what}"
}

# Wrapper for most common use of xmlstarlet sel
function xsl() {
	xmlstarlet sel -T -t "$@" -n
}

# Extract content matching XPATH from XML input
# Usage: cat books.xml | xpath //author/last-name
function xpath() {
	xmlstarlet sel -T -t -v "$1" -n
}

CRED=$(echo -n smendola@phtcorp.com:552d965dbd403a52dbbd7e3ecd41f9ddc5f0f338 | base64 -w0)

cfg_url=$(skapi get "v2/configurations?scope=me&query=status:running" | xpath '//configuration/url')

if [[ -z ${cfg_url} ]]
then
    echo "No running configurations"
    exit 1
fi

HOSTNAME=apphost1
if [[ $1 = -h ]]
then
    shift; HOSTNAME=$1; shift;
fi

if [[ $1 = "-v" ]]
then
    skapi get "${cfg_url}" |
        xsl -v ".//vm/*/interface[hostname='${HOSTNAME}']/*/service[internal_port='22']/external_port" \
            -v '" "' \
            -c '/*/name' \
            -n
else
    shift
    skapi get "${cfg_url}" |
        xsl -v ".//vm/*/interface[hostname='${HOSTNAME}']/*/service[internal_port='22']/external_port" -n

fi
