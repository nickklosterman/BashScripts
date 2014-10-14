#!/bin/bash
if [ $# -ne 2 ]
then
    echo "This script will log into our rpi and pull down the images for a day and create an animated gif."
    echo "Usage: $0 dateYYYY-MM-DD delay_in_hundredths_of_a_second"
    echo "e.g.: $0 2014-08-08 30"
else
    inputDate=${1}
    delay=${2}

HOST=10.20.99.174
USER="rpi"
PASSWORD="rpi"
sftp $USER@$HOST <<EOF
mget "${inputDate}"*.jpg
quit
EOF

if [[ 1 -eq 1 ]]
then
    #convert images to gifs and place the name of the gif on the bottom
    for img in ${inputDate}*.jpg
    do convert $img -resize 50% -gravity South -annotate 0 '%f' $img.gif
    done

    #create animated gif with $delay between frames
    inputFilename="${inputDate}"_*.gif
    outputFilename="${inputDate}"-anim_${delay}.gif
    #delete images smaller than 20kB
    find "./${inputfilename}" -type f -size -20k -print0 | xargs  -0 rm
    gifsicle --delay ${delay} --loopcount  ${inputDate}_*.gif > "${inputDate}-anim_${delay}.gif"
    #gifsicle --delay ${delay} --loopcount  $inputFilename > $outputFilename
fi
fi
