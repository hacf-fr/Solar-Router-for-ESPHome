#!/bin/bash
GIT_BRANCH=$(git branch --show-current)
for iloop in $(ls *.yaml | grep -v secrets | grep -v local); do
   echo
   echo "#########################################"
   echo Verifying $iloop
   esphome -s github_branch ${GIT_BRANCH} config $iloop || exit 1
done

for iloop in $(ls *.yaml | grep -v secrets | grep -v local); do
   echo
   echo "#########################################"
   echo Compiling $iloop
   esphome -s github_branch ${GIT_BRANCH} compile $iloop || exit 1
done
   