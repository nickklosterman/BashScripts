#!/bin/bash
for i in *; 
do 
    if [ -d $i ]
    then 
	cd $i
	git status
	cd ..
    fi 
done
