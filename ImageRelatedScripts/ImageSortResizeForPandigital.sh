#!/bin/bash

echo "This script will traverse a directory (like DAScrapes) and step into each directory resizing the images for an 800x600 resolution and moving the images into a _landscape or _portrait folder in the base directory based on the image dimensions."
echo "This script shouold only be run from a copy of a directory of images as it overwrites the originals and `rm`s the directory."

#for item in  */; do echo $item; cd $item ; bash ~/Git/BashScripts/ImageRelatedScripts/ImageSortResizeForPandigital.sh ; cd .. ; done;

#Run this script from a copy of the DA scrapes directory

mkdir _portrait _landscape

for item in */ #`ls -d */` 
do
    cd ${item} 

    echo $item

    for image in *.jpg *.png *.gif
    do
#	echo "$image"
	width=$( identify -format "%w" "$image" )
	height=$( identify -format "%h" "$image" )

#pandigital novel resolution is 800x600
	mogrify -resize 800x800 $image

	if [ $height -gt $width ]
	then 
	    mv $image ../_portrait/$image
	else
	    mv $image ../_landscape/$image
	fi


    done
    cd ..
    rm -r ${item} 
done