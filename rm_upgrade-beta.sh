#!/bin/bash
. configs/main.cfg
TARGET_VERSION=$1

git_unit_test() {
echo "########### Unit test ###############"
echo "You are now set your beta@redmine working copy in commit (tag+branch) : "
git log -n 3 --oneline --decorate --color
echo "#####################################"
}

if [ $# -eq 0 ]
  then
    echo "No arguments supplied\n Usage:\t upgrade_beta.sh [version], e.g. 'upgrade_beta.sh 2.4.2'"
    exit 1
  else
  	if [[ "$1" =~ ^[0-9].[0-9].[0-9]$ ]] 
  		then
  		echo "Making beta version -> $1"
  		cd $PATH_TO_WWW_BETA
  		git checkout core
		git pull core master --tags
		git checkout $TARGET_VERSION
		echo "Successfull checked out to $TARGET_VERSION tag"
		git checkout -b "develop_$1"
		cp $PATH_TO_SCRIPT_FOLDER/configs/gitignore-custom.txt $PATH_TO_WWW_BETA/.gitignore
		cp $PATH_TO_SCRIPT_FOLDER/database.beta.yml $PATH_TO_WWW_BETA/config/database.yml
		echo "Apply new gitignore file OK"
		git add -A
		git commit -am "Upgrade redmine version to $TARGET_VERSION and set all .yml's"
		git_unit_test
		bundle update
		bundle install --without development test
		rake generate_secret_token
		rake db:migrate RAILS_ENV=production
		rake redmine:plugins:migrate RAILS_ENV=production 
		rake tmp:cache:clear
		rake tmp:sessions:clear
		mkdir tmp tmp/pdf public/plugin_assets
		sudo chown -R www-data:www-data files log tmp public/plugin_assets
		sudo chmod -R 777 files log tmp public/plugin_assets
    else 
    	echo "Arguments are not valid"
    	exit 1
    fi
fi




