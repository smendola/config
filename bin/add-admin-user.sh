#!/bin/sh
host=${1:-10.0.0.1}

sqlcmd -S$host -Usa -Ppassword -dAccessControl \
    -i $(cygpath -w $WORKSPACE/install/access-control-install/src/main/sql/data/01_InitialUserAccounts.sql)
