#!/bin/bash
. ../configs/main.cfg

echo "Path to folder with backup script is: " $PATH_TO_SCRIPT_FOLDER

cd $PATH_TO_WWW_MASTER/config
USER=$(grep -R "username:" database.yml | grep -o -E "\b(\w+)$")
PASSWORD=$(grep -R "password:" database.yml | grep -o -E '"\b(\w+)"$' | sed -e 's/^"//'  -e 's/"$//')
DB=$(grep -R "database:" database.yml | grep -o -E "\b(\w+)$")
HOST=$(grep -R "host:" database.yml | grep -o -E "\b(\w+)$")


echo "Checking founded database.yml file. USER is $USER, PASSWORD is $PASSWORD, DATABASE is $DB, HOST id $HOST"

mysqldump -h $HOST -u $USER -p$PASSWORD $DB > $BACKUP_DIR/redmine-master_$(date +%Y%m%d_%H%M%S).data.sql
mysqldump --no-data -h $HOST -u $USER -p$PASSWORD $DB > $BACKUP_DIR/redmine-master_$(date +%Y%m%d_%H%M%S).schema.sql

cd $PATH_TO_SCRIPT_FOLDER/perl/
./db_schema_vcs.pl $PATH_TO_WWW_MASTER/config/database.yml
cp meta.txt $BACKUP_DIR/redmine-master_$(date +%Y%m%d_%H%M%S).txt
rm meta.txt

cd $BACKUP_DIR
echo -e "\n ### 1) LAST RPRODUCTION REDMINE SQL BACKUPS ###"
ls -la | grep "data.sql" | tail -n 2
echo -e "\n\n ### 2) LAST RPRODUCTION REDMINE DB SCHEMA BACKUPS ###"
ls -la | grep ".schema.sql" | tail -n 2
echo -e "\n\n ### 3) LAST PRODUCTION REDMINE META BACKUPS ###"
ls -la | grep ".txt" | tail -n 2

cd $PATH_TO_SCRIPT_FOLDER/logs
echo -e "$(date '+%Y.%m.%d %H:%M') New backup: redmine-master_$(date '+%Y%m%d_%H%M%S').data.sql & redmine-master_$(date '+%Y%m%d_%H%M%S').schema.sql & redmine-master_$(date '+%Y%m%d_%H%M%S').txt" >> backup.txt
