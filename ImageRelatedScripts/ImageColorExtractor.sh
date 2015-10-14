#!/bin/bash

inputfilename=${1}
numberOfColors=${2}
flipColors=${3}

echo "Usage: $0 filename.ext (numberOfColors)"
echo "This script will extract an image based solely on one color."
echo "Declaring 'numberOfColors' will restrict the image palette to that many colors before extracting the separate images."
echo "If the optional argument numberOfColors was omitted then it will use the number of colors already present in the image."

#Will this break if the file has the full path or mutliple periods in the name?
_tempfile=${1##*/}
tempoutputfilename=${_tempfile%.*} 
fileExtension="png"

#reduce number of colors
#http://www.imagemagick.org/Usage/quantize/#colors
#echo $#
if [ $# -eq 2 ]
then
    convert ${inputfilename} -dither none -colors ${numberOfColors} ${tempoutputfilename}.${fileExtension} #NOTE: to get the number of desired output colors you must specify an output that uses indexed colors.  JPG will muck things up as it will do its DCT for compression
fi

#http://www.imagemagick.org/Usage/quantize/#extract
#the sed command gives us the hex representation of the color. we also use sed to strip the blank lines.
convert ${tempoutputfilename}.${fileExtension} -format %c histogram:info:- |  sed 's/^.*#/#/;s/ .*//;/^ *$/d' > ${tempoutputfilename}_colormap.txt 

#http://stackoverflow.com/questions/11393817/bash-read-lines-in-file-into-an-array
IFS=$'\r\n' GLOBIGNORE='*' :; colorArray=($(cat ${tempoutputfilename}_colormap.txt ))

loopCounter=1
#read the histogram output and create a separate image for each of the separate colors.
#For each color we blank out the non-target colors as white and set our target color as black.

#create blocks from all of the previous colors

#FIXME: we don't need to read in teh file since we have the colors in the colorArray
colorArray2=( "${colorArray[@]}" )

#According to IM documentation: Remember "black" in a mask is transparent, while white is opaque, so all we need to do is draw black over anything we don't want visible.  from http://www.imagemagick.org/Usage/masking/

nonTargetColor="#FFFFFF"
targetColor="#000000"
if [ $# -eq 3 ]
then
    if [ $flipColors == "yes" ]
    then
	nonTargetColor="#000000"
	targetColor="#FFFFFF"
    fi
fi


#wc -l ${tempoutputfilename}_colormap.txt
for j in "${colorArray2[@]}"
do

    colorReplaceString=""
    colorArrayCounter=1
    for i in "${colorArray[@]}"
    do
	if [ $colorArrayCounter != $loopCounter ]
	then 
	    colorReplaceString+="-fill ${nonTargetColor} -opaque $i " #replace our non target colors with $nonTargetColor
	else 
	    colorReplaceString+="-fill ${targetColor} -opaque $i " #make our target color black
	fi
	let 'colorArrayCounter+=1'
    done

    # #http://www.imagemagick.org/Usage/color_basics/#replace
    # #we don't need to use the -fuzz since we are in indexed color space so we know we are replacing the color fully
    convert ${tempoutputfilename}.${fileExtension} $colorReplaceString ${tempoutputfilename}_${j}.${fileExtension} 
    let 'loopCounter+=1'
done

#if three colors are given, I feel like I should skin it like a Shepard Fairey poster.

#ALTERNATE METHOD USING INKSCAPE 
#write script to loop over the image and clear out all but one path node and output the files sequentially
 
