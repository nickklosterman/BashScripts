#!/bin/bash
# this script is meant to loop over Git repos all stored in a 'master' directory and check the status
for item in `ls -d */`
do cd $item
   echo "$item"
   if [ -n "$(git status --porcelain)" ]; then
       echo "-- has files that aren't tracked or need to be committed."
       git status --porcelain
   else
       echo "-- clean; no tracked or untracked files in need of attention."
   fi
   
   git diff --exit-code 1>/dev/null
   if [ $? -ne 0 ]
   then
       echo "-- has tracked files with changes to be committed."      
   else
       echo "-- all tracked files have been committed." 
   fi
   cd .. 
done

#http://stackoverflow.com/questions/5139290/how-to-check-if-theres-nothing-to-be-committed-in-the-current-branch
#https://www.kernel.org/pub/software/scm/git/docs/git-status.html
