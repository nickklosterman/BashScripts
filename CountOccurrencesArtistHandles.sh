#!/bin/bash
ls *_by_* > DeviantArtistHandleList.txt
#cat DeviantArtistHandleList.txt
#echo  "0099"
sed 's/^.*_by_//' DeviantArtistHandleList.txt | sed 's/-.*//' | sed 's/\..*//' > Handles.txt
sort -d Handles.txt | uniq -c | sort > DeviantArtHandlesCount.txt

#uniq OutputHandle.txt
#echo "00999"c
cat DeviantArtHandlesCount.txt