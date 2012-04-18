#!/bin/bash
NumberOfExpectedArguments=1

echo "This script will output a list of the newest X files."
if [ $# -ne ${NumberOfExpectedArguments} ]
then 
    echo "Please specify the number of items you want displayed."
else
    numitems=${1}
    counter=0
    for item in `ls -t *.sh` #[Mm][Pp]3`
    do 

	if  [ "$counter" -lt "$numitems" ]
	then
	echo "${item}"
	else 
	    exit
	fi
	let 'counter+=1'

    done
fi 