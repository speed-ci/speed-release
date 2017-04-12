#!/bin/bash
set -e

APP_NAME=$CI_PROJECT_NAME
REPO_URL=$CI_PROJECT_URL

git remote -v
git status

echo "git-semver-tags"
OLD_TAG=$(git-semver-tags | sed '1 ! d')
echo $OLD_TAG

echo "conventional-recommended-bump"
INCREMENT=$(conventional-recommended-bump -p angular)
echo $INCREMENT

echo "git-changelog"
git-changelog -a $APP_NAME -n $OLD_TAG -r $REPO_URL
cat CHANGELOG.md

echo "semver"
NEXT_TAG=`semver $OLD_TAG -i $INCREMENT`
echo $NEXT_TAG

echo "git tag"
git status
git clean -f
git status