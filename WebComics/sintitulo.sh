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
	rm /tmp/sintitulo*
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
	wget $LINE -nv -O - >> /tmp/sintitulo & #without this backgroudn we only get one image.
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
    wget http://gingerhaze.com/sintitulo/archive -O /tmp/sintituloarchive
    lastpage=$(grep "Go to last page" /tmp/sintituloarchive | sed 's/.*page=//;s/".*//')

    echo "http://gingerhaze.com/sintitulo/archive" > /tmp/sintituloarchive

    echo "lastpage ${lastpage}"
    counter=${lastpage}
    while [ $counter -gt 0 ]; do
	echo "http://gingerhaze.com/sintitulo/archive?page=${counter}/ "  >> /tmp/sintituloarchive
	let "counter-=1"
    done
    performWgetOnFileGeneric /tmp/sintituloarchive /tmp/sintitulosinglepagelinks

}

function SortUniqFile() {
    sort "${1}" | uniq > /tmp/89724587439.txt
    mv /tmp/89724587439.txt "${1}"
}

function getIndividualPages() {
    grep '<a href="/sintitulo/comic/' /tmp/sintitulosinglepagelinks | sed 's/.*a href="\/sintitulo\/comic\//http:\/\/www.gingerhaze.com\/sintitulo\/comic\//;s/".*//' >> /tmp/sintitulosinglepagelinksabsolute
#    grep 'foaf:Image' /tmp/sintitulosinglepagelinks | sed 's/.*a href="\/sintitulo\/comic\//http:\/\/www.gingerhaze.com\/sintitulo\/comic\//;s/".*//' >> /tmp/sintitulosinglepagelinksabsolute

    performWgetOnFileGeneric  /tmp/sintitulosinglepagelinksabsolute  /tmp/sintituloallinone
}

function getIndividualImages()  {
#    grep foaf:Image /tmp/sintituloallinone | sed 's/.*src="//;s/".*//' >> /tmp/sintituloimages
    grep foaf:Image /tmp/sintituloallinone | sed 's/.*foaf:Image" src="//;s/".*//' >> /tmp/sintituloimages
    SortUniqFile /tmp/sintituloimages 

    performWgetOnImages /tmp/sintituloimages
}

function getImageFromPage()  {
    image=$(  grep "sintitulocomic.com/comics/" ${1} | sed 's/.*img src="//;s/".*//' )
    fileNumber=$( printf "%03d" ${imagefilecounter} )
    echo "${image}"
    echo "${image}" >> sintituloImages.txt
    echo "sintitulo_${fileNumber}.$fileExtension"
    wget ${image} -nv -nc -O sintitulo_${fileNumber}.$fileExtension &
    let "imagefilecounter+=1"
}

function getHTMLPages () {
    echo "getHTMLPages"
    counter=${1}
    while [ $counter -gt 0 ]; do
	echo "http://sintitulo.enenkay.com/comic/${counter}/ " >> /tmp/sintitulopages
	#echo ${counter}
	let "counter-=1"
    done

    performWgetOnFile /tmp/sintitulopages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/sintitulo
}

function getNextUrlFromPage() {
#<li><a href="/sintitulo/comic/page-2"><img src="http://gingerhaze.com/sites/default/files/comicdrop/comicdrop_next_label_file.png"></a></li>
#nextURL=$( grep "link rel='next'" "${1}" | uniq | sed "s/.*a href='//;s/'.*//" )

nextURL=$( grep "link rel='next'" "${1}" | uniq | sed "s/.*http/http/;s/'.*//" )
echo ${nextURL} >> sintitulolog.txt
echo "--${nextURL}--"
wget "${nextURL}" -O /tmp/sintitulosinglepage
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
	
	wget http://www.sintitulocomic.com/2007/06/17/page-01/ -U "Mozilla" -O /tmp/sintitulosinglepage
	oldNextUrl="blank"
	nextUrl="empty"
	while [ "${nextUrl}" != "${oldNextUrl}" ]  # you need the quotes for it to work
	do
	    oldNextUrl=${nextUrl}	    
	    getImageFromPage /tmp/sintitulosinglepage
	    nextUrl=$( getNextUrlFromPage /tmp/sintitulosinglepage )
#	    getNextUrlFromPage /tmp/sintitulosinglepage >> sintituloAllUrls #if you call it here, then you will be skipping every other page.
	    echo "new: ${nexUrl} old: ${oldNextUrl}"
	done
	    echo "new: -${nexUrl}- old: ${oldNextUrl}"
	# #	getArchivePages
# #	getIndividualPages
# 	SortUniqFile /tmp/sintituloallinone
# 	getIndividualImages
	sleep 0.5s

	# getHTMLPages $NumberOfImages

	# # wait for /tmp/sintitulo to be populated
	# sleep 5s	

	# grep "<img src=" /tmp/sintitulo |  sed 's/.*<img src="\/img\/comic\//wget -nc  http:\/\/sintitulo.enenkay.com\/img\/comic\//;s/".*//' | sort | uniq  > /tmp/sintitulocomicimages

	# performExecOnFile /tmp/sintitulocomicimages

	# #wait for all downloads to complete. vary this depending on the size of the images and download speeds.
	# sleep 10s


	zip Sintitulo *.${fileExtension}
	mv Sintitulo.zip Sintitulo.cbz
	evince Sintitulo.cbz  &
    fi 
fi


