#!/bin/bash
ls *_by_* > DeviantArtistHandleList.txt
#cat DeviantArtistHandleList.txt
#echo  "0099"
sed 's/^.*_by_//' DeviantArtistHandleList.txt | sed 's/-.*//' | sed 's/\..*//' > Handles.txt
sort -d Handles.txt | uniq > DeviantArtHandles.txt
rm DeviantArtistHandleList.txt Handles.txt

#uniq OutputHandle.txt
#echo "00999"
cat DeviantArtHandles.txt