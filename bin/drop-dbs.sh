#!/bin/sh
if [[ $1 = -c ]]
then
    create=1
    shift
fi

host=${1:-10.0.0.1}

for db in AccessControl Logging Template FileStorage
do
    echo -n "Dropping $db ..."
    sqlcmd -Slocalhost -Usa -Ppassword -Q "drop database $db"
    echo ""
    if [[ $create = 1 ]]
    then
        echo -n "Creating $db as empty database, no schema ..."
        sqlcmd -Slocalhost -Usa -Ppassword -Q "create database $db"
        echo ""
    fi
done
