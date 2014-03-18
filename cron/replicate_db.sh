#!/bin/bash
. ../configs/main.cfg

cd $PATH_TO_WWW_BETA/config
BETA_USER=$(grep -R "username:" database.yml | grep -o -E "\b(\w+)$")
BETA_PASSWORD=$(grep -R "password:" database.yml | grep -o -E '"\b(\w+)"$' | sed -e 's/^"//'  -e 's/"$//')
BETA_DB=$(grep -R "database:" database.yml | grep -o -E "\b(\w+)$")
BETA_HOST=$(grep -R "host:" database.yml | grep -o -E "\b(\w+)$")

MYSQL_LOGIN_STRING="mysql -u $BETA_USER -p$BETA_PASSWORD -h $BETA_HOST"

echo -e "Cleaning beta database"
TABLES=$(eval $MYSQL_LOGIN_STRING "-e 'use $BETA_DB; show tables;'" | awk '{ print $1}' | grep -v '^Tables' )
for t in $TABLES
do
echo "Deleting $t table from $BETA_DB database..."
eval $MYSQL_LOGIN_STRING "-Bse 'use $BETA_DB; drop table $t'"
done

cd $PATH_TO_WWW_MASTER/config
USER=$(grep -R "username:" database.yml | grep -o -E "\b(\w+)$")
PASSWORD=$(grep -R "password:" database.yml | grep -o -E '"\b(\w+)"$' | sed -e 's/^"//'  -e 's/"$//')
DB=$(grep -R "database:" database.yml | grep -o -E "\b(\w+)$")
HOST=$(grep -R "host:" database.yml | grep -o -E "\b(\w+)$")

mysqldump -h $HOST -u $USER -p$PASSWORD $DB | mysql -h $BETA_HOST -u $BETA_USER -p$BETA_PASSWORD $BETA_DB

echo -e "Copying OK"

cd $PATH_TO_SCRIPT_FOLDER/logs
echo -e "$(date '+%Y.%m.%d %H:%M') New replication" >> replica.txt