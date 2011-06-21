#!/bin/bash
ls *_by_* > DeviantArtistHandleList.txt

sed 's/^.*_by_//;s/-.*//;s/\..*//' DeviantArtistHandleList.txt > Handles.txt

sort -d Handles.txt | uniq -c | sort > DeviantArtHandlesCount.txt

FilesArray=( DeviantArtistHandleList.txt Handles.txt )
for item in "${FilesArray[@]}"
do
    if [ -e "$item"]
    then
	rm $item
    fi
done
cat DeviantArtHandlesCount.txt