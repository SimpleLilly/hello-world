#!/bin/bash

# Terminate the script at the first command error
set -o errexit

# Script to permanently delete files/folders from your git repository.  To use 
# it, cd to your repository's root and then run the script with a list of paths
# you want to delete, e.g., git-purge path1 path2

if [ $# -eq 0 ]; then
    echo "Error: no argument!"
    exit 0
fi

# make sure we're at the root of git repo
if [ ! -d .git ]; then
    echo "Error: must run this script from the root of a git repository"
    exit 1
fi

# first do a garbage collection to remove any dangling commit/blob
echo COMMAND: gc
git gc --aggressive --prune=all

# check that everything is OK
echo COMMAND: fsck
git fsck --full

# remove all paths passed as arguments from the history of the repo
echo COMMAND: filter-branch
files=$@
git filter-branch --prune-empty --index-filter "git rm -rfq --cached --ignore-unmatch $files" --tag-name-filter cat -- --all

# remove the temporary history git-filter-branch otherwise leaves behind for a long time
rm -rf .git/refs/original/
rm -rf .git/logs/

echo COMMAND: reflog expire
git reflog expire --all

echo COMMAND: gc
git gc --aggressive --prune=all

echo Everything OK
exit 0
