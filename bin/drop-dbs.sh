#!/bin/sh
if [[ $1 = -c ]]
then
    create=1
    shift
fi

host=${1:-localhost}

for db in AccessControl Logging Template FileStorage StudyDesign ClinicalData DeviceSynch
do
    echo -n "Dropping $db ..."
    sqlcmd -S${host} -Usa -Ppassword -Q "ALTER DATABASE [$db] SET SINGLE_USER WITH ROLLBACK IMMEDIATE"
    sqlcmd -S${host} -Usa -Ppassword -Q "DROP DATABASE [$db]"
    echo ""
    if [[ $create = 1 ]]
    then
        echo -n "Creating $db as empty database, no schema ..."
        sqlcmd -S${host} -Usa -Ppassword -Q "CREATE DATABASE [$db]"
        echo ""
    fi
done
