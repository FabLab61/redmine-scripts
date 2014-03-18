#!/bin/bash
. configs/main.cfg

# example of usage: sh compare-db.sh 2.1.0 2.4.2
# suggests that two test mysql databases and two sub-domains already existing
# you don't need global CREATE mysql rule for test user
# thanks to Github user ticean for his gist https://gist.github.com/ticean/965614

# print passed arguments

if [ $# -eq 0 ]
  then
    echo "No arguments supplied. Usage: ./compare-db [version1] [version2], e.g. './compare-db 2.1.0 2.4.2'"
    exit 1
   else
   	if [ $# -eq 2 ]
	  	then
	  		if [[ "$1" =~ ^[0-9].[0-9].[0-9]$ ]] && [[ "$2" =~ ^[0-9].[0-9].[0-9]$ ]]
	  			then
	    			echo "Correct.args"
	    		else
	    			echo "Not correct versions placed"
	    			exit 1
	    	fi
	  	else 
	  		echo "Too small or too many arguments"
	    	exit 1
	fi
fi


echo "Migrating from old $1 version to new $2 version"

# Functions

update_paths() {
	rm -rf *
	rm -rf .git .bundle .gitignore .hgignore .travis.yml
	git init
	git remote add src $PATH_TO_MIRROR
	git pull src master --tags
	git checkout master
}

drop_all_tables() {
	$MYSQL -u $MUSER -p$MPASS -h $MHOST -e "use $1" &>/dev/null
	if [ $? -ne 0 ]
	then
	echo "Error - Cannot connect to mysql server using given username, password or database does not exits!"
	exit 2
	fi

	TABLES=$($MYSQL -u $MUSER -p$MPASS -h $MHOST $1 -e 'show tables' | $AWK '{ print $1}' | $GREP -v '^Tables' )

	for t in $TABLES
	do
	echo "Deleting $t table from $1 database..."
	$MYSQL -u $MUSER -p$MPASS -h $MHOST $1 -Bse "drop table $t"
	done
}

move_database_yml_file() {
	sudo cp "$PATH_TO_SCRIPT_FOLDER/configs/database.test.yml" $ABSOLUTE_PATH_TO_WWW/$1/config/database.yml
	echo "Moving database config to ${ABSOLUTE_PATH_TO_WWW}/$1/config/database.yml"
}

change_gemfile_in_old_v () {
	echo "Doing cat of existent file"
	cat Gemfile | grep 'gem "mysql"'
	sed -e 's/gem "mysql"/gem "mysql", "~>2.8.1"/' Gemfile > Gemfile_temp
	rm Gemfile
	cp Gemfile_temp Gemfile
	rm Gemfile_temp
}

# Start execute script

FULL_OLD_V_DOMAIN="${DEPLOY_OLD_VERSION_SUBDOMAIN}.${DOMAIN}"
FULL_NEW_V_DOMAIN="${DEPLOY_NEW_VERSION_SUBDOMAIN}.${DOMAIN}"


### Unit test that path's are correct ###
echo "Domain with OLD version will be: $FULL_OLD_V_DOMAIN"
echo "Domain with NEW version will be: $FULL_NEW_V_DOMAIN"
echo "Path from which script is executing: $PATH_TO_SCRIPT_FOLDER"
######

############# Deploying old version ####################################
cd $ABSOLUTE_PATH_TO_WWW/$FULL_OLD_V_DOMAIN
echo "Change path to ${ABSOLUTE_PATH_TO_WWW}/${FULL_OLD_V_DOMAIN}"
update_paths
git checkout $1
move_database_yml_file $FULL_OLD_V_DOMAIN
cd config
sed -e "s/mysql2/mysql/" database.yml > database_temp.yml
rm database.yml
cp database_temp.yml database.yml
rm database_temp.yml
cd ..
drop_all_tables $DB_OLD_V
bundle update
bundle install  --without development test postgresql sqlite rmagick --verbose
change_gemfile_in_old_v
rake generate_secret_token
rake db:migrate RAILS_ENV=production
chown -R www-data:www-data files log tmp public/plugin_assets
chmod -R 755 files log tmp public/plugin_assets
 #######################################################################

############# Deploying new version ####################################
cd $ABSOLUTE_PATH_TO_WWW/$FULL_NEW_V_DOMAIN
echo "Change path to ${ABSOLUTE_PATH_TO_WWW}/${FULL_NEW_V_DOMAIN}"
update_paths
git checkout $2
move_database_yml_file $FULL_NEW_V_DOMAIN
cd config
sed -e "s/$DB_OLD_V/$DB_NEW_V/" database.yml > database_temp.yml
rm database.yml
cp database_temp.yml database.yml
rm database_temp.yml
drop_all_tables $DB_NEW_V
bundle update
bundle install  --without development test postgresql sqlite rmagick --verbose
rake generate_secret_token
rake db:migrate RAILS_ENV=production
chown -R www-data:www-data files log tmp public/plugin_assets
chmod -R 755 files log tmp public/plugin_assets
 #######################################################################

cd $PATH_TO_SCRIPT_FOLDER
echo "Migration from OLD redmine to NEW in natural MySQL language"
mysqldiff --user=$MUSER --password=$MPASS $DB_OLD_V $DB_NEW_V > migrations/migrate_query_up_$DB_OLD_V $DB_NEW_V.txt
cat migrate_query_up.txt

echo "Migration from NEW redmine to OLD in natural MySQL language"
mysqldiff --user=$MUSER --password=$MPASS $DB_NEW_V $DB_OLD_V > migrations/migrate_query_down_$DB_NEW_V $DB_OLD_V.txt
cat migrate_query_down.txt

# echo "Show deleted from new version tables or columns"
# cat migrate_query.txt | grep "DROP"
