#!/bin/bash
for dir in *
do 
    if [ -d "$dir" ]
    then
	cd "$dir"
	rm 000[A-Z]*.html
	cd .. 
    fi 
done