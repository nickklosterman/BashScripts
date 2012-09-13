#!/bin/bash
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then
    echo "Usage: ReplaceFileWithEmptyFilePlaceholder file <file> ..."
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments                                                                      
    do
	echo "Removing " "${1}"
	rm "${1}"
	echo "Touching " "${1}"
	touch "${1}"
	shift
    done
fi
