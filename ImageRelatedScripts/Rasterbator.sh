#!/bin/bash
#TODO: specify horizontal and vertical border widths. specify the interstitial width, specify background color
#allow specifiying the desired resultant height/width and center the triptych in that area.
numberOfRequiredArguments=4

echo "This script attempts to emulate the Rasterbator or Posterazor applications."
#echo "$#"
if [ $# -ne $numberOfRequiredArguments ]
then 
    echo "usage: ${0} inputfilename widthInSheets margin paperSize marginWidth printerResolution sheetOrientation"
    echo "margin: 2 = margin on both all sides; 1 = margin on on +x and +y side; 0 = no margin"
    echo "paperSize: 0 = US Letter; 1 = US Legal; 2 = A4;"
    echo "outputfilename requires a valid image extension to work"
else 

    inputfile=${1}
    widthInSheets=${2}
    margin=${3}
    marginWidth=${4}     #Be smart about the margin and only apply that to interior sheets
    paperSize=0
    rotate=1
    printResolution=100
    pageHeight=11 #in inches
    pageWidth=8.5
    #echo "$inputfile $numberOfPanels $borderWidth"



    #create and copy the input file to a temp file so we don't wreck the original, This also makes it easier to handle the vertical case where we simply rotate the image."
    tempfile="/tmp/ImageMagickRasterbatortemmporaryMainFile.png"
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
    echo "$inputWidth x $inputHeight"

    #outputWidth,outputHeight hold the wxh of the final canvas; this includes the margins for overlap
    #    outputWidth=$(echo "scale=9; ${widthInSheets}*(${marginWidth}*${margin}+${printResolution}*${pageWidth})" | bc)
    outputWidth=$(echo "scale=9;( -1*${widthInSheets}*${marginWidth}*${margin}+ ${widthInSheets}*${printResolution}*${pageWidth})" | bc)
    #        outputWidth=$(echo "scale=9; ${widthInSheets}*${printResolution}*${pageWidth}" | bc) #for now for simplicity's sake
    scaleFactor=$(echo "scale=9; ${outputWidth}/${inputWidth}" | bc)
    #    outputHeight=$(echo "scale=9; ${scaleFactor}*(${inputHeight}-${marginWidth}*${margin})" | bc)
        outputHeight=$(echo "scale=9; ${scaleFactor}*(${inputHeight})" | bc) #the scaleFactor has the margin taken into account so we don't need to have that in the calculation here. 
    #    outputHeight=$(echo "scale=9; ${scaleFactor}*${inputHeight}" | bc)

    #outputPageWidth,outputPageHeight hold the wxh of each individual page i.e. the dimensions of each panel
    outputPageWidth=$(echo "scale=9; $printResolution*$pageWidth-$marginWidth*$margin" | bc )
    #outputPageWidth=$(echo "scale=9; $printResolution*$pageWidth" | bc )
    outputPageHeight=$(echo "scale=9; $printResolution*$pageHeight-$marginWidth*$margin" | bc )
    #outputPageHeight=$(echo "scale=9; $printResolution*$pageHeight" | bc )
    
    echo "${outputWidth} $scaleFactor $outputHeight $pageWidth $pageHeight"

    if [ ${inputWidth} -gt ${inputHeight} ]
    then 
	conversionFactor=$outputWidth
    else
	conversionFactor=$outputHeight
    fi
    echo "${outputWidth} ${outputHeight} ${conversionFactor}"
    commandString="mogrify ${tempfile}  -resize ${conversionFactor}x${conversionFactor}"
    #resize the image to the dimensions of our new canvas size
    convert ${tempfile}  -resize ${conversionFactor}x${conversionFactor} ${tempfile}
    #    convert ${tempfile}  -resize ${outputWidth}x${outputHeight} ${tempfile}
    #convert ${tempfile}  -resize ${outputWidth}x${outputHeight} ${tempfile}
    echo "$commandString"
    #    eval $commandString
    
    #    identify -format "%w %h" ${tempfile}
    identify  ${tempfile}

    convert ${tempfile} -crop ${outputPageWidth}x${outputPageHeight} /tmp/output%02d.jpg

    for image in /tmp/output*.jpg
    do
	#NOTE this is for the 1/2 margin case only!! for the margin on all sides case we would need to use -gravity center
	outputPageWidth=$(echo "scale=9; $printResolution*$pageWidth" | bc )
	outputPageHeight=$(echo "scale=9; $printResolution*$pageHeight" | bc )
	convert ${image} -background blue -extent ${outputPageWidth}x${outputPageHeight} ${image}_extent.pdf
#	identify ${image}_extent.jpg
    done
    pdfjoin /tmp/output*.pdf --outfile /tmp/Output.pdf
    
fi
#feh ${tempfile} output*.jpg
evince /tmp/Output.pdf
