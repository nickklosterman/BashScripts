#!/bin/bash

inputfilename=${1}
numberOfColors=${2}

#Will this break if the file has the full path or mutliple periods in the name?
_tempfile=${1##*/}
tempoutputfilename=${_tempfile%.*} 
fileExtension=".png"

#reduce number of colors
#http://www.imagemagick.org/Usage/quantize/#colors
convert ${inputfilename} -dither none -colors ${numberOfColors} ${tempoutputfilename}.${fileExtension} #NOTE: to get the number of desired output colors you must specify an output that uses indexed colors.  JPG will muck things up as it will do its DCT for compression

#http://www.imagemagick.org/Usage/quantize/#extract
#the sed command gives us the hex representation of the color. we also use sed to strip the blank lines.
convert ${tempoutputfilename}.${fileExtension} -format %c histogram:info:- |  sed 's/^.*#/#/;s/ .*//;/^ *$/d' > ${tempoutputfilename}_colormap.txt 

#http://stackoverflow.com/questions/11393817/bash-read-lines-in-file-into-an-array
IFS=$'\r\n' GLOBIGNORE='*' :; colorArray=($(cat ${tempoutputfilename}_colormap.txt ))

loopCounter=1
#read the histogram output and create a separate image for each of the separate colors.
#For each color we blank out the non-target colors as white and set our target color as black.
while read LINE
do 
    colorReplaceString=""
    colorArrayCounter=1
    for i in "${colorArray[@]}"
    do
	if [ $colorArrayCounter != $loopCounter ]
	then 
	    colorReplaceString+="-fill #FFFFFF -opaque $i " #replace our non target colors with white
	else 
	    colorReplaceString+="-fill #000000 -opaque $i " #make our target color black
	fi
	let 'colorArrayCounter+=1'
    done

#http://www.imagemagick.org/Usage/color_basics/#replace
#we don't need to use the -fuzz since we are in indexed color space so we know we are replacing the color fully
    convert ${tempoutputfilename}.${fileExtension} $colorReplaceString ${tempoutputfilename}_${loopCounter}.${fileExtension} 
    let 'loopCounter+=1'
done <  ${tempoutputfilename}_colormap.txt

#if three colors are given, I feel like I should skin it like a Shepard Fairey poster.

#ALTERNATE METHOD USING INKSCAPE 
#write script to loop over the image and clear out all but one path node and output the files sequentially
 