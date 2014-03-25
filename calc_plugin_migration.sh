# execute from db

echo "Migration from OLD redmine to NEW in natural MySQL language"
mysqldiff --user=$MUSER --password=$MPASS $DB_OLD_V $DB_NEW_V > migrations/migrate_query_up_$DB_OLD_V $DB_NEW_V.txt
cat migrate_query_up.txt

echo "Migration from NEW redmine to OLD in natural MySQL language"
mysqldiff --user=$MUSER --password=$MPASS $DB_NEW_V $DB_OLD_V > migrations/migrate_query_down_$DB_NEW_V $DB_OLD_V.txt
cat migrate_query_down.txt