#!/bin/sh
host=${1:-localhost}

sqlcmd -S$host -Usa -Ppassword -dAccessControl \
    -i $(cygpath -w $WORKSPACE/install/access-control-install/src/main/sql/data/01_InitialUserAccounts.sql)
