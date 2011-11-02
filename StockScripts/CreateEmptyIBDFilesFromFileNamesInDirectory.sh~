#!/bin/bash

NumberOfExpectedArguments=1
NumberOfImages=$(( $1-1 ))

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number empty files to create."
    echo "They will be created from todays date and go back the specified number of days."
else 
    TodaysDate=`date +%F`
    StartFromBack=`date --date "$TodaysDate $NumberOfImages days ago" +%F`
    counter=$NumberOfImages
    while [ $counter -ge 0 ]; do
	StartFromBack=`date --date "$TodaysDate $counter days ago" +%m%d%y`
	filename=ibdearnings$StartFromBack.txt
	echo $filename
	touch $filename
	let "counter-=1"
    done
fi


