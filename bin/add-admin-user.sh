#!/bin/sh
host=${1:-10.0.0.1}

sqlcmd -S$host -Usa -Ppassword \
    -i $WORKSPACE/install/accesscontrol-install/src/main/sql/data/01_InitialUserAccounts.sql
