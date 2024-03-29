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

git checkout develop
git pull origin develop
release_branch="release/$version"
git checkout -b "$release_branch"
recent_release_notes=$(ls -dtr release_notes/*/ | tail -n 1)
new_directory="release_notes/$version"
mkdir -p "$new_directory"
cp -r "$recent_release_notes"/* "$new_directory"
git add "$new_directory"

echo -e "\033[1;33mThe release notes directory has been created and populated with the most recent release notes.\033[0m\n"
echo -e "\033[1;33mHere are the next actions:\033[0m\n"
echo -e "1. \033[1;32mUpdate $new_directory/english.txt with the release notes for this release\033[0m\n"
echo -e "2. \033[1;32mCommit and push the release branch\033[0m"
echo -e "\033[1;33mSuggested command:\033[0m \033[1;36mgit commit -m \"chore: added release notes for ""$version""\" && git push origin $release_branch\033[0m\n"
echo -e "\033[1;33mOnce the branch has been pushed, the release candidate should begin building.\033[0m\n"