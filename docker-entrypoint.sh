#!/bin/bash
set -e

echo $(git-semver-tags)
echo $(conventional-recommended-bump)
git-changelog
cat CHANGELOG.md
semver
