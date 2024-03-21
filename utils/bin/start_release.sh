#!/bin/bash

# Check if version argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

version=$1

# Validate version format
if [[ ! $version =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Invalid version format. Please use format v#.#.# (e.g., v7.50.0)"
    exit 1
fi

## Checkout develop branch
#git checkout develop
#
## Pull latest changes from origin
#git pull origin develop
#
## Checkout new release branch
#release_branch="release/$version"
#git checkout -b "$release_branch"
#
## Find most recent release notes directory
#recent_release_notes=$(ls -dtr release_notes/*/ | tail -n 1)
#
## Create new directory within release_notes
new_directory="release_notes/$version"
#mkdir -p "$new_directory"
#cp -r "$recent_release_notes"/* "$new_directory"
#
## Add new directory to git
#git add "$new_directory"


echo -e "\n\033[1;33mSuggested commit message:\033[0m \033[1;36mchore:\033[0m added release notes for \033[1;32m$version\033[0m"
echo -e "⚠️⚠️ \033[1;31mRemember to edit the release notes file in $new_directory.\033[0m ⚠️⚠️"
