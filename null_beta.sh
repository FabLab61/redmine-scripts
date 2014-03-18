#!/bin/bash
. configs/main.cfg

cd $PATH_TO_WWW_BETA
rm -rf *
rm -rf .git .bundle .gitignore .hgignore .travis.yml
git init
git remote add core $PATH_TO_MIRROR
git pull core master --tags
git checkout -b core
git branch -D master