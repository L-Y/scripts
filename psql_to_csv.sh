#!/bin/bash
DB_USERNAME="$USERNAME"
DB_NAME="$DBNAME"
DBMS_SHELL="psql"

#if [ "$1" = '--help' ]; then
if [[ ( "$1" == '--help' ) || ( "$1" == '-h' ) ]]; then
        echo "usage: $0 [DB_NAME] [DBMS_SHELL]"
        echo "default DB_NAME is your dbname"
        echo "default DBMS_SHELL is 'psql'"
        exit 0
fi

if [ -n "$1" ]
then DB_USERNAME="$1"
fi
if [ -n "$2" ]
then DB_NAME="$2"
fi
if [ -n "$3" ]
then DBMS_SHELL="$3"
fi

alias echo='>&2 echo'

mkdir -p "$DB_NAME"
echo "Fetching table list ..."
$DBMS_SHELL "$DB_NAME" -U $DB_USERNAME  -c "copy (select table_name from information_schema.tables where table_schema='public') to STDOUT;" > "$DB_NAME/tables.txt"
dbms_success=$?
if ! [ $dbms_success ]
then exit 4
fi

echo "Fetching tables ..."
tables=($(awk -F= '{print $1}' $DB_NAME/tables.txt))
Npars=${#tables[@]}
for ((i=0;i<$Npars;i++)); do
        $DBMS_SHELL -d "$DB_NAME" -U $DB_USERNAME -c "copy ${tables[$i]} to STDOUT with delimiter ','CSV HEADER;" > "$DB_NAME/${tables[$i]}.csv"
done
