#!/bin/bash
set -e

APP_NAME=$CI_PROJECT_NAME
REPO_URL=$CI_PROJECT_URL

env

echo "git-semver-tags"
TAGS=$(git-semver-tags)
echo $TAGS

echo "conventional-recommended-bump"
INCREMENT=$(conventional-recommended-bump -p angular)
echo $INCREMENT

echo "git-changelog"
git-changelog -a $APP_NAME -r $REPO_URL
cat CHANGELOG.md

echo "semver"
semver -i $INCREMENT
