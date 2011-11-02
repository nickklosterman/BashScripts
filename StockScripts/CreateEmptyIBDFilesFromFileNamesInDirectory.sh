#!/bin/bash

NumberOfExpectedArguments=0

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number empty files to create."
    echo ""
else 
    for file in IBD*.pdf
    do 
#	echo $file
#	filename=$(basename "$file" ) #this gets the full filename
#	filename=${file%.*}
#	filenameextension=${file#*.}
#	echo $filenameextension
	filename=$(echo $file |  sed -e 's/IBD/ibdearnings/;s/.pdf/.txt/' )
	echo $filename
	touch $filename
    done

fi


