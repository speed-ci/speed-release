#!/bin/bash
set -e

REPO_URL=$(git config --get remote.origin.url | sed 's/\.git//g' | sed 's/\/\/.*:.*@/\/\//g')
APP_NAME= ${REPO_URL##*/}
PREVIOUS_TAG=$(git-semver-tags | sed '1 ! d')
INCREMENT=$(conventional-recommended-bump -p angular)
NEXT_TAG=`semver $PREVIOUS_TAG -i $INCREMENT`

git-changelog -a $APP_NAME -n $NEXT_TAG -r $REPO_URL
cat CHANGELOG.md

echo "git tag"
git status
git clean -f
git status