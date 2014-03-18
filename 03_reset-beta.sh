#!/bin/bash
# Thanks to 
#http://stackoverflow.com/questions/468370/a-regex-to-match-a-sha1

. configs/main.cfg

cd $PATH_TO_WWW_BETA
rm -rf *
rm -rf .git .bundle .gitignore .hgignore .travis.yml
git init
git remote add main $PATH_TO_WWW_MASTER
git pull main master --tags
git remote rm main
echo "Git remote are clean"
git remote -v

git log --oneline --decorate --color | grep "tagged version"
LAST_TAGGED_COMMIT=$(git log --oneline | grep "tagged" | grep -o -E "([0-9a-f]{5,40})")
echo "SHA-1 of last tagged commit is " $LAST_TAGGED_COMMIT


# Restore original version tags if forget
git remote add mirror /var/www/serikov/data/www/redmine-repos/redmine.git
git fetch --tags mirror
LAST_VERSION=$(git tag | tail -n 1)		#maybe be older
#LAST_VERSION=$(git describe --tags)
echo "Latest tagged version is : " $LAST_VERSION

git checkout -b develop_$LAST_VERSION
A=$(git log --oneline --color -n 2)
git checkout master
git commit -am "Checkout to master for merge from mirror"

#git reset --hard $LAST_TAGGED_COMMIT
#git checkout $LAST_TAGGED_COMMIT		# remove all user commits from master
#git checkout LAST_VERSION				# same as checkout to commit

B=$(git log --oneline --color -n 2)
git pull mirror master --tags
C=$(git log --oneline --color -n 2)
git branch

echo -e "### 1) Latest commits from develop branch : " 
echo -e $A
echo -e "### 2) Latest master commit BEFORE upgrade commit history from mirror and AFTER checkout to last tag: "
echo -e $B
echo -e "### 3) Latest master commit AFTER upgrade commit history from mirror : "
echo -e $C

git checkout develop_$LAST_VERSION
echo -e "Checking OLD database.yml"
cat config/database.yml

rm config/database.yml
cp $PATH_TO_SCRIPT_FOLDER/configs/database.beta.yml config/database.yml

rm config/configuration.yml
cp $PATH_TO_SCRIPT_FOLDER/configs/configuration.yml config/configuration.yml

echo -e "Checking NEW database.yml"
cat config/database.yml 
echo -e "Change database.yml file succesfull"

bundle update
bundle install --without development test
rake db:migrate RAILS_ENV=production
rake redmine:plugins:migrate RAILS_ENV=production 
rake tmp:cache:clear
rake tmp:sessions:clear
rake generate_secret_token
mkdir tmp tmp/pdf public/plugin_assets
sudo chown -R www-data:www-data files log tmp public/plugin_assets
sudo chmod -R 777 files log tmp public/plugin_assets

echo -e "All is OK. Exit"


# git reset --merge

