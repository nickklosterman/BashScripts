#!/bin/bash
echo "Obtaining parameters: mplayer ${1} -vo null -ao null -frames 0 2>&1 /dev/null | egrep \"(AUDIO)\" )"

#echo "WARNING: THIS DOESN'T SEEM TO WORK ON NAMES WITH SPACES EVEN WHEN QUOTING."
#this seemed to work just fine on a mp3 file that had a space in it. 
#nicolae@nicolae-desktop:~/Shared$ bash ../Git/BashScripts/Audio/StripAudioFromVideo.sh Fefe\ Dobson\ -\ Ghost.mp3 

# could I mv/cp the file to a temp filename if it has spaces in it and then work on that temp file which doesn't have spaces.

params=$(mplayer "${1}" -vo null -ao null -frames 0 2>&1 /dev/null | egrep "(AUDIO)" )

sampling_freq=$( echo ${params} | sed 's/AUDIO: //' | cut -d ',' -f 1 | sed 's/ Hz//' )
num_channels=$( echo ${params} | sed 's/AUDIO: //'  | cut -d ',' -f 2 | sed 's/ ch//' )
bit_rate=$( echo ${params} | sed 's/AUDIO: //'  | cut -d ',' -f 4 | sed 's/ kbit.*//' ) #or sed 's/AUDIO: //' | cut -d ',' -f 4 | sed 's/\..*//'

#echo $sampling_freq $num_channels $bit_rate

#grab sampling freq, num channels, and bit rate 
outputfilename=${1%.*}.mp3  #"audio.mp3"
if [ -e ${outputfilename} ]
then
while [ -e $outputfilename ]
do 
    echo "$outputfilename exists. Please enter an alternate output filename:"
    read outputfilename
done
fi

echo "Stripping Audio: ffmpeg -i ${1} -ab ${bit_rate}k -ac ${num_channels} -ar ${sampling_freq} -vn ${outputfilename}"
ffmpeg -i "${1}" -ab ${bit_rate}k -ac ${num_channels} -ar ${sampling_freq} -vn ${outputfilename}


#IDENTIFY VIDEO AUDIO PARAMS
# http://savvyadmin.com/quickly-identify-video-file-attributes/
#http://superuser.com/questions/55780/linux-command-line-tool-to-get-bitrate-of-divx-xvid
#yahoo/google: linux identify audio bitrate video

# STRIP AUDIO FROM VIDEO
# http://linuxpoison.blogspot.com/2010/04/how-to-extract-audio-from-video-file.html
# google/yahoo linux ffmpeg strip audio from video

#mplayer *can* strip audio but it isn't as forgiving on inputs as ffmpeg is
