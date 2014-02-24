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
    psql -h ${host} -U postgres -c "DROP DATABASE \"$db\""
    if [[ $create = 1 ]]
    then
        echo -n "Creating $db as empty database, no schema ..."
        psql -h ${host} -U postgres -c "CREATE DATABASE \"$db\""
        echo ""
    fi
done
