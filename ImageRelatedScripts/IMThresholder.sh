#!/bin/bash

inputfilename=${1}
numberOfSteps=${2}

#Will this break if the file has the full path or mutliple periods in the name?
_tempfile=${1##*/}
tempoutputfilename=${_tempfile%.*} 
fileExtension=".png"

thirds=( 33 66 )
fourths=( 25 50 75 )
fifths=( 20 40 60 80 )

case $numberOfSteps in
    3) array=( 33 66 );; #${thirds[@]};;  for some reason I couldn't copy the array. I did what  http://www.thegeekstuff.com/2010/06/bash-array-tutorial/ stated to no avail.
    4) array=( 25 50 75 );;#"${fourths[@]}";;
    5) array=( 20 40 60 80 ) ;;#${fifths[@]};;
esac

for num in "${array[@]}"
do
    echo $num  ${inputfilename} ${tempoutputfilename}_${num}${fileExtension}
    #you may want to turn off the blur http://www.imagemagick.org/Usage/blur/
    convert ${inputfilename} -blur 1x2 -threshold $num% ${tempoutputfilename}_${num}${fileExtension} 
done

