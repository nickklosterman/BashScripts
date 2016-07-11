#!/bin/bash


#####################
# BEGIN MAIN SCRIPT #
#####################X
Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: ${0} DeviantArtGalleryScraper tumblrID <tumblrID> ..."
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do 
	ID=$( echo "$1" | sed 's/\/$//' ) #strip out the trailing \ when you are updating directories that you have all ready downloaded and are updating.
	echo $ID
	offset=0
	echo "using offset of 1 to start so first page is page 2"
	offset=1

	#create a directory with the deviantID and move into it for saving of images
	echo "Making directory $deviantID and moving into it"
	if [ ! -e "$ID" ]
	then #mkdir if it doesn't exist
	    mkdir "$ID"
	fi
	cd "$ID"

	#debug: disable getting new index pages here
	DebugDontGetIndexPages=0
	if [[ 0 -eq $DebugDontGetIndexPages ]]
	then	
	    if [ -e index.html ]
	    then
		rm index.html
	    fi
	    #get gallery index
	    echo "Getting gallery index file"
	    wget -nv -U Mozilla -O index_${ID}.html http://${ID}.tumblr.com/ 2>>/tmp/wgeterrors.txt   #-O $OutputFile
	    #check if the gallery index has additional pages.
	    #NextPageCheck=$(grep 'data-highres' index_${ID}.html  )
	    NextPageCheck=$(grep 1280 index_${ID}.html  )

	    echo "Sadly not all tumblrs are the same so there, right now, is no standard way to key off where the images are or if there are further pages to process. Uggh"
	    
	    
	    #grab all pages of the gallery
	    while [ "$NextPageCheck" != "" ]
	    do 
		let 'offset+=1'
		echo "Getting gallery index with offset of ${offset}"
		wget -nv -U Mozilla http://${ID}.tumblr.com/page/${offset} 
		#	NextPageCheck=$(grep 'class="post-photo"' ${offset} )
#		NextPageCheck=$(grep 'data-highres' ${offset} )
		NextPageCheck=$(grep 1280 ${offset} ) 
		cat ${offset} >> index_${ID}.html
		rm ${offset}
	    done
	    echo "Done getting all gallery pages."
	else
	    echo "In Debug mode skipping getting gallery index pages"
	fi

	#compile arrays of the links to the fullimg, img, address of webpage, webpage file	

#	highResImage=$(grep 'data-highres' index_${ID}.html | sed 's/^.*highres="//;s/".*//' )
	highResImage=$( grep 1280 index_${ID}.html | grep src | sed 's/^.*src="//;s/".*//' )
	altText=$(grep 'class="post-photo"' index_${ID}.html | sed 's/^.*alt="//;s/".*//')

	echo "${highResImage}" > highResImage.txt
	echo "${altText}" > altText.txt

	wget -nc -i highResImage.txt  #using -nc (no clobber) should prevent needing to rename XXX.jpg.1 to XXX.jpg
	zip -m ${ID}.cbz *.png *.jpg *.gif
	cd ..
	shift 
	
    done
fi
