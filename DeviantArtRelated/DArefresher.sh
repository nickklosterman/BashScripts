#!/bin/bash
list=""
for i in `ls -d */` 
do
list+=$i
list+=" "
#echo "bash ../Git/BashScripts/DeviantArtRelated/DeviantArtGalleryScraperAll4.sh  ${i}"
done
echo "${list}"
bash ../Git/BashScripts/DeviantArtRelated/DeviantArtGalleryScraperAll4.sh  "${list}"