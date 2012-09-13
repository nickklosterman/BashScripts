#!/bin/bash
function RecurseDirs()
{
    echo "1:==$1"
#    if [ "${1}" -eq "" ]
    if [ "" != "$1" ]
    then
	depth=0
    fi
    depth=$1
    let 'depth+=1'
    echo "$depth"
    for dir in *
    do 
	if [ -d "$dir" ]
	then 
	    cd "$dir"
	    echo -n "entered:"
	    pwd
	    RecurseDirs $depth
	    echo -n "exiting:"
	    pwd
	    cd ..
	fi
    done
#    echo "Do stuff here $depth"
}

###
#begin
####
RecurseDirs 0
