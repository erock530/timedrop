#!/bin/bash
#
# This script will fix the missing .circleci/semver git submodule.
# Run this in the base directory of your git repo.
#
if [ ! -d .circleci ]; then echo "Missing .circleci directory!"; exit 1; fi
git submodule deinit -f .circleci/semver
rm -rf .git/modules/.circleci/semver
rm -rf .circleci/semver
git ls-files --stage .circleci/semver
git rm --cached .circleci/semver
git rm --cached .gitmodules
git submodule add git@github.com:erock530/semver.git .circleci/semver
