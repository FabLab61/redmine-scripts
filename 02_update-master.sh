#!/bin/bash
. configs/main.cfg

cd $PATH_TO_WWW_BETA
BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo $BRANCH

cd $PATH_TO_WWW_MASTER
git pull beta $BRANCH

rm $PATH_TO_SCRIPT_FOLDER/configs/database.beta.yml
rm $PATH_TO_SCRIPT_FOLDER/configs/configuration.yml

cp $PATH_TO_SCRIPT_FOLDER/configs/database.beta.yml $PATH_TO_WWW_MASTER/config/database.yml
cp $PATH_TO_SCRIPT_FOLDER/configs/configuration.yml $PATH_TO_WWW_MASTER/config/configuration.yml


bundle install --without development test postgresql sqlite --verbose
rake generate_secret_token
rake db:migrate RAILS_ENV=production
rake redmine:plugins:migrate RAILS_ENV=production 
rake tmp:cache:clear
rake tmp:sessions:clear
echo "You are now set your MASTER@redmine working copy in commit (tag+branch) : "
git log -n 3 --oneline --decorate --color
chmod -R 777 files log tmp