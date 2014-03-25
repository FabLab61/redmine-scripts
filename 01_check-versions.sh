#!/bin/bash
. configs/main.cfg

echo "######################"
echo "BETA VERSION"
echo "current branch is:"
cd $PATH_TO_WWW_BETA
git branch
echo "Last 3 commits in your beta@redmine working copy (tag+branch) : "
git log -n 5 --oneline --decorate --color

echo "######################"
echo "MASTER VERSION"
echo "current branch is:"
cd $PATH_TO_WWW_MASTER
git branch
echo "Last 3 commits in your master@redmine working copy  (tag+branch) : "
git log -n 5 --oneline --decorate --color