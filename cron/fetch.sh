#!/bin/bash
# 0 */12 * * * /var/www/serikov/data/www/redmine-scripts/fetch.sh >> ../logs/fetch.txt

. ../configs/main.cfg

echo -e "$(date +%Y.%m.%d %H:%M) New fetch :"
#date -R
cd $PATH_TO_MIRROR
git fetch
