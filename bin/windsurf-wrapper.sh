#!/bin/bash

# Save original DBUS_SESSION_BUS_ADDRESS
ORIGINAL_DBUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS"

# Check if we already have a session bus running for Windsurf
if [ -f ~/.windsurf/dbus-session-address ]; then
    source ~/.windsurf/dbus-session-address
    if [ -n "$WINDSURF_DBUS_SESSION_BUS_ADDRESS" ]; then
        export DBUS_SESSION_BUS_ADDRESS="$WINDSURF_DBUS_SESSION_BUS_ADDRESS"
    fi
else
    # Create directory if it doesn't exist
    mkdir -p ~/.windsurf
    
    # Launch a dedicated dbus session for Windsurf
    eval $(dbus-launch --sh-syntax)
    echo "WINDSURF_DBUS_SESSION_BUS_ADDRESS=\"$DBUS_SESSION_BUS_ADDRESS\"" > ~/.windsurf/dbus-session-address
fi

# Launch Windsurf with the dedicated session bus
/usr/share/windsurf/windsurf "$@"

# Restore original DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_ADDRESS="$ORIGINAL_DBUS_ADDRESS"
