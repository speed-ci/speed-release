#!/bin/sh
set -e

git-semver-tags
conventional-recommended-bump
git-changelog
semver
