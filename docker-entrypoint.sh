#!/bin/bash
set -e

gitlab url "https://gitlab-poc.sln.nc"
gitlab token "okb1eijUAWbeq6Ysi7G7"
gitlab me
gitlab groups
gitlab users

REPO_URL=$(git config --get remote.origin.url | sed 's/\.git//g' | sed 's/\/\/.*:.*@/\/\//g')
APP_NAME=${REPO_URL##*/}
PREVIOUS_TAG=$(git-semver-tags | sed '1 ! d')
PREVIOUS_TAG=${PREVIOUS_TAG:-"0.0.0"}
INCREMENT=$(conventional-recommended-bump -p angular)
NEXT_TAG=`semver $PREVIOUS_TAG -i $INCREMENT`

git-changelog -a $APP_NAME -n $NEXT_TAG -r $REPO_URL
cat CHANGELOG.md

echo "git tag"
git status
git clean -f
git status