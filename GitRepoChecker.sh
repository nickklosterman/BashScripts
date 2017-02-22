#!/bin/bash
# this script is meant to loop over Git repos all stored in a 'master' directory and check the status
for item in `ls -d */`
do 
    echo "$item"
    cd "${item}"
    if [ $? -eq 0 ]
    then
#check that it is a git directory by checking to see if it has a .git directory
	git status #git will return an error code of 128 if it is called in a directory that isn't a git repo
	if  [ $? -ne 128 ]
	then
	    if  [ -e .git ] 
	    then
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
	    fi 
	fi
    fi 
done

#http://stackoverflow.com/questions/5139290/how-to-check-if-theres-nothing-to-be-committed-in-the-current-branch
#https://www.kernel.org/pub/software/scm/git/docs/git-status.html
