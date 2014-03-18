#!/bin/bash
# Extract parameters from database.yml file
. ../configs/main.cfg

echo $PATH_TO_SCRIPT_FOLDER
echo $PATH_TO_SCRIPT_FOLDER_EXPERIMENTAL

A=$(grep -R "database:" ../configs/database.beta.yml | grep -o -E "\b(\w+)$")
echo $A
