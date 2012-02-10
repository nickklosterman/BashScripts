#!/bin/bash
#this just creates successively smaller files from a large image using IM. Attempted to use to find size limit of Android browser/gallery. In the end i got around the limitation by cutting large images into strips.
for image in *.jpg
do
    echo "$image"
    width=$( identify -format "%w" "$image" )
    height=$( identify -format "%h" "$image" )
    newwidth=1700
    newheight=1700
    counter=1
    flag=1
    echo "$widthx$height"
    while [ $flag ]
    do 
	let 'newwidth-=50'
	let 'newheight-=50'
	echo "$newwidth" "$newheight"
	filename="$newwidthx$newheight.jpg"
	convert -resize "$newwidth"x"$newheight" "$image" "$filename"
	if [ $newwidth -lt 800 ]
	then
	    flag=0
	fi
    done 
done