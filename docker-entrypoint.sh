#!/bin/bash
set -e

GITLAB_TOKEN="okb1eijUAWbeq6Ysi7G7"
GITLAB_URL="https://gitlab-poc.sln.nc"
GITLAB_API_URL="$GITLAB_URL/api/v4"
echo $GITLAB_API_URL


REPO_URL=$(git config --get remote.origin.url | sed 's/\.git//g' | sed 's/\/\/.*:.*@/\/\//g')
APP_NAME=${REPO_URL##*/}
PREVIOUS_TAG=$(git-semver-tags | sed '1 ! d')
PREVIOUS_TAG=${PREVIOUS_TAG:-"0.0.0"}
INCREMENT=$(conventional-recommended-bump -p angular)
NEXT_TAG=`semver $PREVIOUS_TAG -i $INCREMENT`

git-changelog -a $APP_NAME -n $NEXT_TAG -r $REPO_URL
CHANGELOG=$(cat CHANGELOG.md)

echo "git tag"


PROJECT_ID=`curl --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects?search=$APP_NAME" | jq .[0].id`
LAST_COMMIT_ID=$(git log --format="%H" -n 1)

curl --noproxy '*' --header -XPOST "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects/$PROJECT_ID/repository/tags" -d "id=$PROJECT_ID" -d "tag_name=$NEXT_TAG" -d "ref=$LAST_COMMIT_ID" -d "release_description=$CHANGELOG" | jq .[0].name


# curl --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects/$PROJECT_ID/repository/tags" | jq .[0].name


git status
git clean -f
git status