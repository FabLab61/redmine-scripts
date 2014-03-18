#!/bin/bash
. configs/main.cfg

#use it as pre-commit hook

cd $PATH_TO_WWW_BETA/db
rm schema.sql
mysqldump --no-data -h localhost -u $REDMINE_MYSQL_SUPERUSER -p$REDMINE_SUPERUSER_PASSWORD $REDMINE_MASTER_DB > schema.sql
echo -e "\n\n ### 1) LATEST BETA DB SCHEMAS ###"
#cat schema.sql
#ls -la | grep ".schema.sql" | tail -n 2

cd $PATH_TO_SCRIPT_FOLDER/perl
cp dbi_version.pl $PATH_TO_WWW_BETA/db/dbi_version.pl
cd $PATH_TO_WWW_BETA/db
rm meta.txt
./dbi_version.pl
echo -e "\n\n ### 2) LATEST BETA META ###"
rm dbi_version.pl
cat meta.txt
#ls -la | grep ".txt" | tail -n 2