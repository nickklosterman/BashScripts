#!/bin/bash

#TODO: specify horizontal and vertical border widths. specify the interstitial width, specify background color

numberOfRequiredArguments=4

echo "This script takes an image and splits it evenly into sections with a border in between each section"
#echo "$#"
if [ $# -ne $numberOfRequiredArguments ]
then 
    echo "usage: TriptychPlusMaker.sh inputfilename numberOfPanels borderWidth outputfilename"
else 

    inputfile=${1}
    numberOfPanels=${2}
    borderWidth=${3}
    outputfilename=${4}
    rotate=0

    #echo "$inputfile $numberOfPanels $borderWidth"




#create and copy the input file to a temp file so we don't wreck the original, This also makes it easier to handle the vertical case where we simply rotate the image."
    tempfile="/tmp/ImageMagickTriptychPlusMakertemporaryMainFile.png"
    cp "${inputfile}" "${tempfile}"

    #if want it vertical then we rotate image and keep all the instructions the same, and unrotate at the end
    if [ $rotate -eq 1 ]
    then 
#	echo "rotating"
	convert ${tempfile} -rotate 90 $tempfile
    fi

    #need to get the wxh after the rotate otherwise the canvas is oriented horizontally while the panels are oriented vertically
    inputWidth=`identify -format "%w" "${tempfile}"`
    inputHeight=`identify -format "%h" "${tempfile}"`
    #echo "$inputWidth x $inputHeight"


    temp=$(echo "scale=9; (1+$numberOfPanels)*$borderWidth" | bc)

    outputWidth=$(echo "scale=9; ${inputWidth} + (1+$numberOfPanels)*${borderWidth}" | bc)
    outputHeight=$(echo "scale=9; ${inputHeight}+2*${borderWidth}" | bc)
    #echo "$outputWidth:$outputHeight"

#    convert "${inputfile}" -crop ${numberOfPanels}x1@ +repage +adjoin /tmp/ImageMagickTriptychPlusMakertemporary%d.png
    convert "${tempfile}" -crop ${numberOfPanels}x1@ +repage +adjoin /tmp/ImageMagickTriptychPlusMakertemporary%d.png

#We increment the xoffset each go through so we set it 0 here. 
    xoffset=0 
    yoffset=${borderWidth} 

    commandString="convert -size ${outputWidth}x$outputHeight xc:white "
    for ((index=0; index<${numberOfPanels}; index++))
    do 
	#echo "index: $index"
	let xoffset+=${borderWidth}
	commandString+=" /tmp/ImageMagickTriptychPlusMakertemporary${index}.png -geometry +${xoffset}+${yoffset} -composite"
	panelWidth=`identify -format "%w" /tmp/ImageMagickTriptychPlusMakertemporary${index}.png`
	let xoffset+=panelWidth
    done



    #http://stackoverflow.com/questions/2005192/how-to-execute-a-bash-command-stored-as-a-string-with-quotes-and-asterisk
    commandString+=" ${outputfilename}"

    #echo "${commandString}"

    if [ -e "${outputfilename}" ]
    then 
	echo "The outpufile exists. Cancel the operation with ^C or enter a value to proceed."
	read dummy
	echo "Overwriting ${outputfilename}."
    fi

    eval ${commandString}

    if [ $rotate -eq 1 ]
    then 
#	echo "rotating back"
	convert "${outputfilename}" -rotate -90 "${outputfilename}"
    fi

    feh ${outputfilename}

    #file cleanup
    rm /tmp/ImageMagickTriptychPlusMakertemporary*.png
fi 


#ImageMagick Resources 
#http://www.imagemagick.org/Usage/crop/#border adding the border 
#http://www.imagemagick.org/Usage/layers/  compositing the images together
#http://www.imagemagick.org/Usage/warping/ flipping the image 
