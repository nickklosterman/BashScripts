#!/bin/bash

GetFullSizeImages=0
GetLargeImages=0

function downloadIndividualPages ()
{
#http://www.faqs.org/docs/abs/HTML/assortedtips.html look at the passing and returning arrays section.
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} #1
    do 
	echo "Downloading $x"
	wget -nc -U Mozilla "$x"
    done
}

function removeIndividualPages ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]}
    do 
	echo "Removing  $x"
	rm "$x"
    done
}

function downloadFullImageFromFile ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} #1
    do 
	echo "Searching $x for 'Download Image' "
	DownloadImage=$( grep "Download Image" "$x" | sed 's/.*download-button" href="//' | sed 's/" onclick.*//' )
	if [ "$DownloadImage" != "" ]
	then 
#we don't want our variable to be quoted otherwise we'll get a Scheme missing error from wget
	    wget -nc -U Mozilla $DownloadImage
	fi
    done
}

function downloadallowingclobber ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} 
    do 
	echo "$x"
	wget -U Mozilla "$x"
    done

}


function downloadnoclobber ()
{
    passed_array=( `echo "$1"` )
    for x in ${passed_array[@]} 
    do 
	echo "$x"
	wget -U Mozilla -nc "$x"
    done
}


Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: DeviantArtGalleryScraper deviantID <deviantID> ..."
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do 

	offsetcounter=0

#create a directory with the deviantID and move into it for saving of images
	echo "Making directory ${1} and moving into it"
	mkdir "$1"
	cd "$1"
	
#get gallery index
	echo "Getting gallery index file"
#without the trailing / it saves the file as gallery instead of index.html
	wget -U Mozilla http://${1}.deviantart.com/gallery/ #-O $OutputFile
#check if the gallery index has additional pages.
	NextPageCheck=$(grep "gallery/?offset=" index.html | grep "Next Page</a>" )
	
#grab all pages of the gallery
	while [ "$NextPageCheck" != "" ]
	do 
	    
	    let 'offsetcounter+=1'
	    let "offset=${offsetcounter} * 24"
	    echo "Getting gallery index with offset of ${offset}"
	    wget -U Mozilla http://${1}.deviantart.com/gallery/?offset=${offset} 
	    NextPageCheck=$(grep "gallery/?offset=" index.html?offset=${offset}  | grep "Next Page</a>" )
	    cat index.html?offset=${offset} >> index.html
	done
	echo "Done getting all gallery pages."

#compile arrays of the links to the fullimg, img, address of webpage, webpage file	
	Super_FullImg=$( grep super_fullimg index.html | sed 's/.*super_fullimg="//' | sed 's/" .*//' )
	Super_Img=$( grep super_img index.html | sed 's/.*super_img="//' | sed 's/" .*//' )

if [ $GetFullSizeImages -eq 1 ]
then 

	HrefAddress=$( grep "deviantart.com/art/"  index.html | sed 's/.*<a href="//' | sed 's/" class=.*//' )
	HrefPageName=$( grep "deviantart.com/art/"  index.html | sed 's/.*<a href="//' | sed 's/" class=.*//' | sed 's/.*art\"///' )
	DeletePageList=${HrefPageName}
#first download the pages of each image, then attempt to download the full image.  There is no other way that I know of to guarantee getting the fullsize image without visiting the individual webpage and checking if there is a "Download Image" button present. Otherwise simply going off the gallery webpage might only get you the "super_fullimg" when there is a larger version available.	

	downloadIndividualPages "$HrefAddress" #need the quotes otherwise only the first element is sent
	downloadFullImageFromFile "$HrefPageName"	
	echo "Begin deleting files:"
	echo $DeletePageList
	removeIndividualPages "$DeletePageList"
	echo "End deleting Files"
	echo "Done compiling fullimg and img lists."
fi
#Since the full images are first priority, we now try to get the fullimg then img listed in the gallery index file (as they are of lower res)	
if [ $GetLargeImages -eq 1 ]
then 
	if [ "$Super_FullImg" != "" ]
	then
#	    downloadallowingclobber "$Super_FullImg" 
	    downloadnoclobber "$Super_FullImg" 
	fi
fi	

	if [ "$Super_Img" != "" ]
	then 
		downloadnoclobber "$Super_Img" 
	fi
	rm `ls | grep -v '\.'` #use this to rm files since my above comd wasn't working
	cd ..
	shift 
#this shifts the input parameters over one position.  pg 38 of bash guide. http://tldp.org/LDP/LG/issue25/dearman.html
    done
fi