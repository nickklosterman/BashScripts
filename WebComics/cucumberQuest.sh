#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/cucumber*
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



function fileCheck () {
	for cnter in {1..481}
	do
	    filename=$(printf "%03d" ${cnter} );
	    if [ ! -e ${filename}.jpg ] || [ ! -e ${cnter}.jpg ]
	    then
		echo ${filename} ${cnter}
	    fi
	done
	echo "288 failing is a misnomer since there is a 288new.jpg"

}

function renameFiles () {
	    for cntr in {1..99}
	    do 
		filename=$(printf "%03d" ${cntr} );
		echo $filename 
		if [ ! -e ${filename}.jpg ]
		then 
		    mv ${cntr}.jpg ${filename}.jpg
#to easily get rid of files run the commands below
#rm [1-9][0-9].jpg
#rm [1-9].jpg
		else
		    echo "not moving ${cntr}.jpg to ${filename}.jpg bc it all ready exists"  
		fi
	    done

}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
	while [ $counter -gt 0 ]; do
	    #wget http://cucumber.gigidigi.com/cq/page-${counter} -O - >> /tmp/cucumberquest
	    #echo "wget http://cucumber.gigidigi.com/cq/page-${counter}/ -O - >> /tmp/cucumberquest" >> /tmp/cucumberquestpages
	    echo "http://cucumber.gigidigi.com/cq/page-${counter}/ " >> /tmp/cucumberquestpages
	    #echo ${counter}
	    let "counter-=1"
	done
	#manually add the oddball page 109 which follows a diff url format 
	echo "wget http://cucumber.gigidigi.com/cq/109/ -O - >> /tmp/cucumberquest" >> /tmp/cucumberquestpages
	#wget http://cucumber.gigidigi.com/cq/109/ -O - >> /tmp/cucumberquest

	#	performExecOnFile  /tmp/cucumberquestpages
	getPagesInFile /tmp/cucumberquestpages
}

function getPagesInFile() {
    echo "getPagesInFile"
    cat $1 | xargs -P 10 -r -n 1 wget -nv -O - >> /tmp/cucumberquest
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
	#	echo $#
    else 
	performCleanup
	counter=$NumberOfImages

	getHTMLPages $counter
	
	grep "webcomic-image" /tmp/cucumberquest |  sed 's/.*src="http:\/\/cucumber.gigidigi.com\/wp-content\/uploads/wget -nc  http:\/\/cucumber.gigidigi.com\/wp-content\/uploads/;s/".*//' | sort | uniq  > /tmp/cucumberquestcomicimages
	#it seems that pages have links to other pages so I need to get sort , uniq and also there is a <div element that is being matched that I need to discard with the 'grep ... ' 
	#cat /tmp/cucumberquestcomicimages | sort | uniq  | grep cucumber.gigidigi > /tmp/cucumberquestcomicimages

	performExecOnFile /tmp/cucumberquestcomicimages

	sleep 10s

	renameFiles
	
	fileCheck

	zip CucumberQuest *.jpg
	mv CucumberQuest.zip CucumberQuest.cbz
	evince CucumberQuest.cbz  &
    fi 
fi


