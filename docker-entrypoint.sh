#!/bin/bash
set -e

printstep() {
    # 36 is blue
    echo -e "\033[36m\n== ${1} \033[37m \n"
}
printmainstep() {
   # 35 is purple
   echo -e "\033[35m\n== ${1} \033[37m \n"
}
printinfo () {
    # 32 is green
    echo -e "\033[32m==== INFO : ${1} \033[37m"
}
printwarn () {
    # 33 is yellow
    echo -e "\033[33m==== ATTENTION : ${1} \033[37m"
}
printerror () {
    # 31 is red
    echo -e "\033[31m==== ERREUR : ${1} \033[37m"
}

init_env () {
    CONF_DIR=/conf/
    if [ ! -d $CONF_DIR ]; then
        printerror "Impossible de trouver le dossier de configuration $CONF_DIR sur le runner"
        exit 1
    else
        source $CONF_DIR/variables
    fi
    APP_DIR=/usr/src/app/
    if [ ! -d $APP_DIR ]; then
        printerror "Impossible de trouver le dossier du code source de l'application $APP_DIR sur le runner"
        exit 1
    fi    
    if [[ -z $GITLAB_TOKEN ]];then
        printerror "La variable GITLAB_TOKEN n'est pas présente, sortie..."
        exit 1
    fi
}

init_env

REPO_URL=$(git config --get remote.origin.url | sed 's/\.git//g' | sed 's/\/\/.*:.*@/\/\//g')
GITLAB_URL=`echo $REPO_URL | grep -o 'https\?://[^/]\+/'`
GITLAB_API_URL="$GITLAB_URL/api/v4"

APP_NAME=${REPO_URL##*/}
PREVIOUS_TAG=$(git-semver-tags | sed '1 ! d')
if [ $PREVIOUS_TAG ]; then TAG_RANGE="$PREVIOUS_TAG.."; else TAG_RANGE=""; fi
NB_NEW_COMMITS=`git log $TAG_RANGE --oneline | wc -l`

printinfo "PREVIOUS_TAG   : $PREVIOUS_TAG"
printinfo "NB_NEW_COMMITS : $NB_NEW_COMMITS"
printinfo "TAG_RANGE      : $TAG_RANGE"

if [[ $NB_NEW_COMMITS = 0 ]]; then 
    printinfo "Aucun nouveau commit depuis la dernière version, release inutile."
else 
    PREVIOUS_TAG=${PREVIOUS_TAG:-"0.0.0"}
    INCREMENT=$(conventional-recommended-bump -p angular)
    NEXT_TAG=`semver $PREVIOUS_TAG -i $INCREMENT`
    
    git-changelog -a $APP_NAME -n $NEXT_TAG -r $REPO_URL --template "/template.md"
    CHANGELOG=$(cat CHANGELOG.md)
    CHANGELOG=$(head -n 28 CHANGELOG.md)
    echo "release_description=$CHANGELOG"
    msee CHANGELOG.md

    PROJECT_ID=`curl -s --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects?search=$APP_NAME" | jq .[0].id`
    LAST_COMMIT_ID=$(git log --format="%H" -n 1)
    
    printinfo "INCREMENT       : $INCREMENT"
    printinfo "NEXT_TAG        : $NEXT_TAG"
    printinfo "LAST_COMMIT_ID  : $LAST_COMMIT_ID"
    printinfo "GITLAB_API_URL  : $GITLAB_API_URL"
    printinfo "PROJECT_ID      : $PROJECT_ID"
    
    DATE=`(date)`
    case $(curl -s -w "%{http_code}" --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" -XPOST "$GITLAB_API_URL/projects/$PROJECT_ID/repository/tags" -d "id=$PROJECT_ID" -d "tag_name=$NEXT_TAG" -d "ref=$LAST_COMMIT_ID" -d "release_description=$CHANGELOG") in
        200) return 0;;
        *) printerror "Erreur lors de la création de la release Gitlab"
    esac    
    # curl --noproxy '*' --header "PRIVATE-TOKEN: $GITLAB_TOKEN" "$GITLAB_API_URL/projects/$PROJECT_ID/repository/tags" | jq .[0].name
fi
