#!/bin/bash

# Nightly update script
# use it with crontab, like this:
# 0 2 * * * /home/sal/bin/nightly-update.sh >> /tmp/nightly-update.log 2>&1
# ADJUST the /home/sal/bin/ path to match the actual env!

sudo apt update

sudo apt install --only-upgrade -y windsurf
kiro-cli update
