#!/bin/bash

# Find all dbus-daemon processes for the current user
# that aren't the system or session main bus
USER_DAEMONS=$(ps -u $(whoami) -o pid,cmd | grep "dbus-daemon" | grep -v "system" | grep -v "$(cat /var/run/user/$(id -u)/bus)" | awk '{print $1}')

# Calculate how long each process has been running
for PID in $USER_DAEMONS; do
    START_TIME=$(ps -p $PID -o etimes | tail -n 1 | tr -d ' ')
    
    # If it's been running for more than 1 hour (3600 seconds)
    # and doesn't have any child processes, terminate it
    if [ $START_TIME -gt 3600 ]; then
        CHILD_COUNT=$(pgrep -P $PID | wc -l)
        if [ $CHILD_COUNT -eq 0 ]; then
            echo "Killing old dbus-daemon process: $PID"
            kill $PID
        fi
    fi
done
