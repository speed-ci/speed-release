#!/bin/bash
set -e

git-semver-tags
conventional-recommended-bump
git-changelog
semver
