#!/bin/bash

fileExtension=png

#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/avasdemons*
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
	wget $LINE -nv -O - >> /tmp/avasdemons & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnFileForImages () {
    while read LINE
    do
	#	    echo $LINE
	wget $LINE -nv -nc
	#sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
# 236.png doesn't exist. the webpage even skips it
#124 same
#110 same
}



function fileCheck () {
START=1
STOP="${1}"
    for (( cnter=START; cnter<=STOP; cnter++))
    do
	filename=$(printf "%04d" ${cnter} );
	if [ ! -e ${filename}.${fileExtension} ] #|| [ ! -e ${cnter}.${fileExtension} ]
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
#http://www.avasdemon.com/pages/0892.png
	filename=$(printf "%04d" ${counter} );
	echo "http://www.avasdemon.com/pages/${filename}.${fileExtension} " #>> /tmp/avasdemonspages
	#echo ${counter}
	let "counter-=1"
    done

 #   performWgetOnFileForImages /tmp/avasdemonspages
wget http://www.avasdemon.com/0762.png -nc
wget http://www.avasdemon.com/0655.png -nc
#wget http://www.avasdemon.com/370.gif -nc -O 0370.gif
#wget http://www.avasdemon.com/369.gif -nc -O 0369.gif
echo "urls for ava's demons video's: http://vimeo.com/88974714 http://vimeo.com/59886505  http://vimeo.com/52363516 http://vimeo.com/45483354"
echo "warning: there are animated gifs we are converting to pngs so they display in order"
read somekey
wget http://www.avasdemon.com/368.gif -nc -O 0371.png #from page 371
wget http://www.avasdemon.com/367.gif -nc -O 0370.png #from page 370
wget http://www.avasdemon.com/366.gif -nc -O 0369.png #from page 369
wget http://www.avasdemon.com/365.gif -nc -O 0368.png #from page 368

wget http://www.avasdemon.com/titanglow.gif -nc -O 0367.png #this is from page 367


#wget http://www.avasdemon.com/353.gif -nc #link to vimeo
#wget http://www.avasdemon.com/222.gif -nc #link to vimeo 
#wget http://www.avasdemon.com/0061.gif -nc #link to vimeo

arrayOfDiffURLFiles=(0061 0222 0353 0367 0368 0369 0370 0371 0655 0762 )

}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/avasdemons
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

	# wait for /tmp/avasdemons to be populated

#	zeroPadNumericFileNames 
	sleep 3s	

	fileCheck $NumberOfImages

	zip Avasdemons *.png 
	mv Avasdemons.zip Avasdemons.cbz
	evince Avasdemons.cbz  &
    fi 
fi


