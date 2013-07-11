#!/bin/bash

inputfilename=${1}
numberOfColors=${2}

#reduce number of colors
convert ${inputfilename} -dither none -colors ${numberOfColors} ${tempoutputfilename}
#obtain pallette / colormap
#we need to capture this output, ideally we want to use cut? to grab just the column of hex characters
convert ${tempoutputfilename} -format %c histogram:info:-
     37494: (  0, 85, 25) #005519 srgb(0,85,25)
      6986: (  8,130, 18) #088212 srgb(8,130,18)
    318322: ( 21,165, 60) #15A53C srgb(21,165,60)

#we need to replace all but 1 color for each stencil , the color that remains should be turned to black
#loop over the colors and replace with white FFFFFF/ black 000000
# the fill is the replacement color, the opaque is the color to replace
mogrify -fill "#FF00FF" -opaque "#15A5C3" ${tempfilename_loop} #fuzz option allows for greater coverage
convert ${rempoutputfilename} -fill "#FF00FF" -opaque "#15A5C3" -fuzz 20% ${tempfilename loop} #not sure this works.

#mogrify -fill "#5F005F" -opaque "#15A53C" -fuzz 20% pokemonTemp2.gif can use fuzz for imprecise colors


#ALTERNATE METHOD USING INKSCAPE 
#write script to loop over the image and clear out all but one path node and output the files sequentially
