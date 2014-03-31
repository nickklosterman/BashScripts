#!/bin/bash
#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward

#this version goes through page by page and gets teh image and names it before going on to the next page. this tidies things up since the file nameing isn't sequential


fileExtension=jpg
imagefilecounter=1

function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/cucumberquest*
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
	wget $LINE -nv -O - >> /tmp/cucumberquest & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnFileGeneric () {
    while read LINE
    do
	wget $LINE -nv -O - >> "${2}" & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}

function performWgetOnImages () {
    while read LINE
    do
	wget $LINE -nv -U "Mozilla" -nc  & #without this backgroudn we only get one image.
	sleep 0.20     # slow the http requests down a bit so we don't get blocked from the server
    done < ${1}
}



function fileCheck () {
    for cnter in {1..481}
    do
	filename=$(printf "%03d" ${cnter} )
	if [ ! -e ${filename}.jpg ] || [ ! -e ${cnter}.jpg ]
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

function getArchivePages() {
    echo "getArchivePages"
    wget http://gingerhaze.com/cucumberquest/archive -O /tmp/cucumberquestarchive
    lastpage=$(grep "Go to last page" /tmp/cucumberquestarchive | sed 's/.*page=//;s/".*//')

    echo "http://gingerhaze.com/cucumberquest/archive" > /tmp/cucumberquestarchive

    echo "lastpage ${lastpage}"
    counter=${lastpage}
    while [ $counter -gt 0 ]; do
	echo "http://gingerhaze.com/cucumberquest/archive?page=${counter}/ "  >> /tmp/cucumberquestarchive
	let "counter-=1"
    done
    performWgetOnFileGeneric /tmp/cucumberquestarchive /tmp/cucumberquestsinglepagelinks

}

function SortUniqFile() {
    sort "${1}" | uniq > /tmp/89724587439.txt
    mv /tmp/89724587439.txt "${1}"
}

function getIndividualPages() {
    grep '<a href="/cucumberquest/comic/' /tmp/cucumberquestsinglepagelinks | sed 's/.*a href="\/cucumberquest\/comic\//http:\/\/www.gingerhaze.com\/cucumberquest\/comic\//;s/".*//' >> /tmp/cucumberquestsinglepagelinksabsolute
#    grep 'foaf:Image' /tmp/cucumberquestsinglepagelinks | sed 's/.*a href="\/cucumberquest\/comic\//http:\/\/www.gingerhaze.com\/cucumberquest\/comic\//;s/".*//' >> /tmp/cucumberquestsinglepagelinksabsolute

    performWgetOnFileGeneric  /tmp/cucumberquestsinglepagelinksabsolute  /tmp/cucumberquestallinone
}

function getIndividualImages()  {
#    grep foaf:Image /tmp/cucumberquestallinone | sed 's/.*src="//;s/".*//' >> /tmp/cucumberquestimages
    grep foaf:Image /tmp/cucumberquestallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/cucumberquestimages
    SortUniqFile /tmp/cucumberquestimages 

    performWgetOnImages /tmp/cucumberquestimages
}

function getImageFromPage()  {
    image=$(  grep "webcomic-image" ${1} | sed 's/.* src="//;s/".*//' )
    fileNumber=$( printf "%03d" ${imagefilecounter} )
    echo "${image}"
    echo "${image}" >> cucumberquestImages.txt
    echo "cucumberquest_${fileNumber}.$fileExtension"
    wget ${image} -nv -nc -O cucumberquest_${fileNumber}.$fileExtension &
    let "imagefilecounter+=1"
}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
    while [ $counter -gt 0 ]; do
	echo "http://cucumberquest.enenkay.com/comic/${counter}/ " >> /tmp/cucumberquestpages
	#echo ${counter}
	let "counter-=1"
    done

    performWgetOnFile /tmp/cucumberquestpages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/cucumberquest
}

function getNextUrlFromPage() {
#<li><a href="/cucumberquest/comic/page-2"><img src="http://gingerhaze.com/sites/default/files/comicdrop/comicdrop_next_label_file.png"></a></li>
#nextURL=$( grep "link rel='next'" "${1}" | uniq | sed "s/.*a href='//;s/'.*//" )

nextURL=$( grep "link rel='next'" "${1}" | uniq | sed "s/.*http/http/;s/'.*//" )
echo ${nextURL} >> cucumberquestlog.txt
echo "--${nextURL}--"
if [ "${nextURL}" != "" ]
then
    wget "${nextURL}" -O /tmp/cucumberquestsinglepage
fi
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
	
#this is the start page to begin scraping from
	wget http://cucumber.gigidigi.com/cq/page-1/ -U "Mozilla" -O /tmp/cucumberquestsinglepage
	oldNextUrl="blank"
	nextUrl="empty"
	while [ "${nextUrl}" != "${oldNextUrl}" ] && [ "${nextUrl}" != "" ]  # you need the quotes for it to work
	do
	    oldNextUrl=${nextUrl}	    
	    getImageFromPage /tmp/cucumberquestsinglepage
	    nextUrl=$( getNextUrlFromPage /tmp/cucumberquestsinglepage )
#	    getNextUrlFromPage /tmp/cucumberquestsinglepage >> cucumberquestAllUrls #if you call it here, then you will be skipping every other page.
	    echo "new: ${nexUrl} old: ${oldNextUrl}"
	done
	    echo "new: -${nexUrl}- old: ${oldNextUrl}"
	# #	getArchivePages
# #	getIndividualPages
# 	SortUniqFile /tmp/cucumberquestallinone
# 	getIndividualImages
	sleep 0.5s

	# getHTMLPages $NumberOfImages

	# # wait for /tmp/cucumberquest to be populated
	# sleep 5s	

	# grep "<img src=" /tmp/cucumberquest |  sed 's/.*<img src="\/img\/comic\//wget -nc  http:\/\/cucumberquest.enenkay.com\/img\/comic\//;s/".*//' | sort | uniq  > /tmp/cucumberquestcomicimages

	# performExecOnFile /tmp/cucumberquestcomicimages

	# #wait for all downloads to complete. vary this depending on the size of the images and download speeds.
	# sleep 10s


	zip Cucumberquest *.${fileExtension}
	mv Cucumberquest.zip Cucumberquest.cbz
	evince Cucumberquest.cbz  &
    fi 
fi



