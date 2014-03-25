#!/bin/bash
# Launch it manually before rake redmine:plugins:migrate RAILS_ENV=production 
# Store it in redmine /db directory
 
DB_FOR_MANIPULATION="redmine_calculate"   #

cd config
BETA_USER=$(grep -R "username:" database.yml | grep -o -E "\b(\w+)$")
BETA_PASSWORD=$(grep -R "password:" database.yml | grep -o -E '"\b(\w+)"$' | sed -e 's/^"//'  -e 's/"$//')
BETA_DB=$(grep -R "database:" database.yml | grep -o -E "\b(\w+)$")
BETA_HOST=$(grep -R "host:" database.yml | grep -o -E "\b(\w+)$")

MYSQL_LOGIN_STRING="mysql -u $BETA_USER -p$BETA_PASSWORD -h $BETA_HOST"

echo -e "Cleaning calculation database"
TABLES=$(eval $MYSQL_LOGIN_STRING "-e 'use $DB_FOR_MANIPULATION; show tables;'" | awk '{ print $1}' | grep -v '^Tables' )
for t in $TABLES
do
echo "Deleting $t table from $DB_FOR_MANIPULATION database..."
eval $MYSQL_LOGIN_STRING "-Bse 'use $BETA_DB; drop table $t'"
done

mysqldump -h $BETA_HOST -u $BETA_USER -p$PASSWORD $BETA_DB | mysql -h $BETA_HOST -u $BETA_USER -p$BETA_PASSWORD $DB_FOR_MANIPULATION
echo -e "Copying OK"