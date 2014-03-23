#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/lackadaisy*
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
	wget $LINE -nv -O - >> /tmp/lackadaisy & #without this backgroudn we only get one image.
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

function zeroPadNumericFileNames () {
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
	echo "http://lackadaisy.foxprints.com/comic.php?comicid=${counter}/ " >> /tmp/lackadaisypages
	#echo ${counter}
	let "counter-=1"
    done

    #	getPagesInFile /tmp/lackadaisypages
    performWgetOnFile /tmp/lackadaisypages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/lackadaisy
}

function renameFilesToSequentialNumbers() {
    #the image names don't easily translate into the correct order
    #luckily there is a nav bar that lets you go to any page.
    #it is autogenerated and has the title of each page in it.
    #this title corresponds to the alt= naming of the image. 
    #now I just need to map the renaming. 
    grep "<img src=" /tmp/lackadaisy | sed 's/.*img src=//;s/alt=/,/;s/\/>//;s/ ,/,/' > /tmp/lackadaisycomicimageurlsPart1


    grep "option value" /tmp/lackadaisy | sed 's/ selected="selected"//;s/option value="/\^/g;s/<\/option></"/g;s/">/,"/g'| tr '^' '\n' |  sort | uniq  >  /tmp/lackadaisycomicimageurlsPart2

    sort -k2 -t, /tmp/lackadaisycomicimageurlsPart1 | grep "jpg"  > /tmp/part1.txt
    sort -k2 -t, /tmp/lackadaisycomicimageurlsPart2 | grep "Lackadaisy" | sed 's/"".*/"/' > /tmp/part2.txt
    join -j2 -t ',' <(sed 's/\s\+$//'  /tmp/part1.txt) /tmp/part2.txt > /tmp/renamemap.txt #according to my SO post's answer it was the trailing whitespace screwing stuff up. 

    echo "read comments in file"
    read somekey
    #I tried to join these files using the 'join' command but didn't have any luck
    #as it was there were a couple fields missing from one of the files that other had :(
    #I therefore went in and removed the missing entries
    #I then opened libreoffice spreadsheet and merged so that I had a renaming map. 
    #field 1 was the original filename of the jpg from the website, fields 2,3 were the matching alt names, field 4 was the number
    #I named the file combined.csv
    #cut -f1,4 -d, combined.csv > cutcombined.csv

    #I then needed to remove the url and just get the txt and insert .jpg at the end, add my 'mv' command and remove the csv comma
    sed 's/.*http:\/\/www.lackadaisycats.com\/comic\//mv /;s/$/.jpg/;s/",/ /' /tmp/renamemap.txt > /tmp/renaming.txt
    #bash /tmp/renaming.txt
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
	
	getHTMLPages $NumberOfImages

	# wait for /tmp/lackadaisy to be populated
	sleep 5s	

	#<img src="http://www.lackadaisycats.com/comic/
	grep "<img src=" /tmp/lackadaisy |  sed 's/.*src="http:\/\/www.lackadaisycats.com\/comic\//wget -nc  http:\/\/www.lackadaisycats.com\/comic\//;s/".*//' | sort | uniq  > /tmp/lackadaisycomicimages

	renameFilesToSequentialNumbers
	#we now need to run renameFiles so that they are in correct order for zipping up. 


	performExecOnFile /tmp/lackadaisycomicimages

	#wait for all downloads to complete. vary this depending on the size of the images and download speeds.
	sleep 5s

	zeroPadNumericFileNames
	#	fileCheck

	zip Lackadaisy *.jpg
	mv Lackadaisy.zip Lackadaisy.cbz
	evince Lackadaisy.cbz  &
    fi 
fi


