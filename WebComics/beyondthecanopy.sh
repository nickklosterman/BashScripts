#!/bin/bash

fileExtension=png

#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/beyondthecanopy*
    else 
	echo "Not removing temporary files"
    fi
}

function performExecOnFile () {
    while read LINE
    do
	echo $LINE
	exec $LINE & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}


function performWgetOnFile () {
    while read LINE
    do
	#	    echo $LINE
	wget $LINE -nv -O - >> /tmp/beyondthecanopy & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnFileForImages () {
    while read LINE
    do
	#	    echo $LINE
	wget $LINE -nv 
	#sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}



function fileCheck () {
START=1
STOP="${1}"
    for (( cnter=START; cnter<=STOP; cnter++))
    do
	filename=$(printf "%03d" ${cnter} );
	if [ ! -e ${filename}.${fileExtension} ] || [ ! -e ${cnter}.${fileExtension} ]
	then
	    echo ${filename} ${cnter}
	fi
    done

}

function zeroPadNumericFileNames () {
    for cntr in {1..99}
    do 
	filename=$(printf "%03d" ${cntr} );
	echo $filename 
	if [ ! -e ${filename}.${fileExtension} ]
	then 
	    mv ${cntr}.${fileExtension} ${filename}.${fileExtension}
	    #to easily get rid of files run the commands below
	    #rm [1-9][0-9].${fileExtension}
	    #rm [1-9].${fileExtension}
	else
	    echo "not moving ${cntr}.${fileExtension} to ${filename}.${fileExtension} bc it all ready exists"  
	fi
    done
}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
    while [ $counter -gt 0 ]; do
	echo "http://beyondthecanopy.com/img/comic/${counter}.${fileExtension} " >> /tmp/beyondthecanopypages
	#echo ${counter}
	let "counter-=1"
    done

#    performWgetOnFileForImages /tmp/beyondthecanopypages


wget http://beyondthecanopy.com/img/comic/367.jpg #this was a guest strip
wget http://beyondthecanopy.com/img/comic/371.jpg 
mogrify 367.jpg 367.png
mogrify 371.jpg 371.png
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/beyondthecanopy
}


##########
##########
##-Main-##
##########
##########

NumberOfExpectedArguments=1
NumberOfImages=${1}
debugswitch=1 #setting to something besides 1 will turn off bits of code
if [ 1 -eq $debugswitch ]
then 
    if [ $# -ne $NumberOfExpectedArguments ]
    then
	echo "Please specify the number of comics to grab"
    else 
	performCleanup
	
	getHTMLPages $NumberOfImages

	# wait for /tmp/beyondthecanopy to be populated
	sleep 3s	
	zeroPadNumericFileNames 

	fileCheck $NumberOfImages

	zip Beyondthecanopy *.png
	mv Beyondthecanopy.zip Beyondthecanopy.cbz
	evince Beyondthecanopy.cbz  &
    fi 
fi


