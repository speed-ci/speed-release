#!/bin/bash
set -e

echo "git-semver-tags"
TAGS=$(git-semver-tags)
echo $TAGS

echo "conventional-recommended-bump"
echo $(conventional-recommended-bump)

echo "git-changelog"
git-changelog
cat CHANGELOG.md

echo "semver"
semver
