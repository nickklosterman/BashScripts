i=0
for vob in /tmp/mntpoint/VIDEO_TS/*.VOB
do
    ffmpeg -i $vob -c:v libx264 -crf 20 -c:a libmp3lame -ac 2 -ab 192k KingIFR_2_$i.avi
    let "i+=1"
    echo $i
    done
