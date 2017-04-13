#!/bin/bash
set -e

GITLAB_TOKEN="okb1eijUAWbeq6Ysi7G7"
GITLAB_URL="https://gitlab-poc.sln.nc"
GITLAB_API_URL="$GITLAB_URL/api/v4"

REPO_URL=$(git config --get remote.origin.url | sed 's/\.git//g' | sed 's/\/\/.*:.*@/\/\//g')
APP_NAME=${REPO_URL##*/}
PREVIOUS_TAG=$(git-semver-tags | sed '1 ! d')
PREVIOUS_TAG=${PREVIOUS_TAG:-"0.0.0"}
INCREMENT=$(conventional-recommended-bump -p angular)
NEXT_TAG=`semver $PREVIOUS_TAG -i $INCREMENT`

git-changelog -a $APP_NAME -n $NEXT_TAG -r $REPO_URL
cat CHANGELOG.md

echo "git tag"

PROJECT_ID=`curl --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects?search=$APP_NAME" | jq .[0].id`

curl --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects/$PROJECT_ID/repository/tags" | jq .[0].name


git status
git clean -f
git status