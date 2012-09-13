#!/bin/bash

NumberOfExpectedArguments=1
NumberOfImages=$(( $1-1 ))

if [ $# -ne $NumberOfExpectedArguments ]
then
    echo "Please specify the number of sinfest comics to grab"
else 
    TodaysDate=`date +%F`
    StartFromBack=`date --date "$TodaysDate $NumberOfImages days ago" +%F`
    counter=$NumberOfImages
    while [ $counter -ge 0 ]; do
	StartFromBack=`date --date "$TodaysDate $counter days ago" +%F`
	filename=$StartFromBack.gif
	echo $filename
	feh http://www.sinfest.net/comikaze/comics/$filename	
	let "counter-=1"
    done
fi


