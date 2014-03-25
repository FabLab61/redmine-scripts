#!/bin/bash
. configs/main.cfg

cd $PATH_TO_SCRIPT_FOLDER
echo -e "Init in $PATH_TO_SCRIPT_FOLDER "

mkdir logs
chmod -R 777 logs

rm logs/backup.txt
touch logs/backup.txt

rm logs/fetch.txt
touch logs/fetch.txt

rm logs/replica.txt
touch logs/replica.txt

cd logs
chmod 777 *

cp $PATH_TO_SCRIPT_FOLDER/pre_plugin_migration.sh  $PATH_TO_WWW_BETA/pre_plugin_migration.sh

cp $PATH_TO_SCRIPT_FOLDER/perl/get_schema.pl  $PATH_TO_WWW_BETA/db/get_schema.pl
chmod +x $PATH_TO_WWW_BETA/db/get_schema.pl

cp $PATH_TO_SCRIPT_FOLDER/calc_plugin_migration.sh  $PATH_TO_WWW_BETA/db/calc_plugin_migration.sh
chmod +x $PATH_TO_WWW_BETA/db/calc_plugin_migration.sh

cp $PATH_TO_SCRIPT_FOLDER/configs/pre-commit $PATH_TO_WWW_BETA/.git/hooks/pre-commit
chmod 777 $PATH_TO_WWW_BETA/.git/hooks/pre-commit

