#!/bin/bash

fileExtension=jpg

#this version improves on the previous version in that it doesn't keep respawning feh and you can navigate forward and backward
function performCleanup () {
    echo "Remove temporary files (y/n)?"
    read inputkey
    if [ "$inputkey" == "y" ] || [ "$inputkey" == "Y" ]
    then 
	echo "Removing temporary files"
	rm /tmp/solstoria*
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
	wget $LINE -nv -U "IE9" -O - >> /tmp/solstoria & #without this backgroudn we only get one image.
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
	if [ ! -e ${filename}.${fileExtension} ] #|| [ ! -e ${cnter}.${fileExtension} ]
	then
	    echo ${filename} ${cnter} ${fileExtension}
	fi
    done

}


function fileRenameToPng () {
START=1
STOP="${1}"
    for (( cnter=START; cnter<=STOP; cnter++))
    do
	filename=$(printf "%03d" ${cnter} );
	if [ ! -e ${filename}.${fileExtension} ] || [ ! -e ${cnter}.${fileExtension} ] && [ -e ${filename}.png ]
	then
	    mv ${filename}.png  ${filename}.${fileExtension}
	fi
    done
echo "a better way is to simply do a for item in *.png...."
read somekey
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
    # while [ $counter -gt 0 ]; do
    # 	#http://solstoria.net/comic/page-083/
    # 	fileName=$(printf "%03d" ${counter})
    # 	echo "http://solstoria.net/comic/page-${fileName}/ " >> /tmp/solstoriapages
    # 	#echo ${counter}
    # 	let "counter-=1"
    # done

#I could just as easily brute force and just add this url to the above even though it accounts for maybe 10% of the cases.
#nvm it seems that the user agent string solved the problem
echo "http://solstoria.net/comic/075/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/page-39/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/page-42/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/590/" >> /tmp/solstoriapages  #page 44

echo "http://solstoria.net/comic/688/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/page-63/" >> /tmp/solstoriapages


#these are the prologue pages
echo "http://solstoria.net/comic/67/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/63/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/60/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/57/" >> /tmp/solstoriapages
echo "http://solstoria.net/comic/54/" >> /tmp/solstoriapages


#    performWgetOnFileForImages /tmp/solstoriapages
    performWgetOnFile /tmp/solstoriapages
}

function getPagesInFile() {
    echo "getPagesInFile"
    numberOfParallelOperations=3 #you may need to lower this number if two files writing to our temp file collide and one write op is cut short 
    cat $1 | xargs -P $numberOfParallelOperations -r -n 1 wget -nv -O - >> /tmp/solstoria
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

#http://solstoria.net/wp-content/uploads/2014/03/083.jpg
#<img width="775" height="1096" src="http://solstoria.net/wp-content/uploads/2014/03/083.jpg" class="attachment-full" alt="083" data-webcomic-parent="825" /></a></div><!-- .webcomic-image -->
	grep "http://solstoria.net/wp-content/uploads/" /tmp/solstoria | sed 's/.*src="http:\/\//wget -nc  -U 'IE9' http:\/\//;s/".*//' | sort | uniq  > /tmp/solstoriacomicimages

	performExecOnFile /tmp/solstoriacomicimages
	wget http://solstoria.net/wp-content/uploads/2012/10/001.png -nc -U 'IE9'
	wget http://solstoria.net/wp-content/uploads/2012/10/0021.png -nc -U 'IE9' -O 002.jpg
	mv ch01_title.png 000.jpg

	# wait for /tmp/solstoria to be populated
	sleep 3s	

	fileRenameToPng $NumberOfImages
	fileCheck $NumberOfImages

	zip Solstoria *.${fileExtension} 
	mv Solstoria.zip Solstoria.cbz
	evince Solstoria.cbz  &
    fi 
fi


