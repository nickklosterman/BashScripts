#!/bin/bash
if [ $# -lt 2 ] 
then
echo "Not enough args bitch: script PID diskspacelimit(in megabytes)" 
echo "This script only checks your home directory. change as necessary"
else
    PID=$1
    diskspacelimit=$2
#echo $PID

#df -h is diff tha df -H
#df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read
    
    while [ 1 ] #continue looping until we hit our minute pausing 2minutes between loops
    do 
	
	HomeDiskSpace=$(df -h | grep 'home' | awk '{ print $4  }' )
#echo $HomeDiskSpace
	digits=$(df -h | grep 'home' | awk '{ print $4  }'| sed 's/.$//' )
#echo $digits
	BytesLetter=$(df -h | grep 'home' | awk '{ print $4  }'| sed 's/[0-9]//g' )
#echo $BytesLetter
	
	if [ $BytesLetter = "K" ] 
	then
	    kill $PID
	else
	    if [ $BytesLetter = "M" ]
	    then
		echo "$digits Megabytes Left!!"
		if [ $digits -lt  $diskspacelimit ]
		then 
		    echo "Sorry too little disk space (${digits}${BytesLetter}). Killling process $PID"
		    kill $PID
		    exit
		fi
	    fi
	fi
	sleep 2m
    done
fi