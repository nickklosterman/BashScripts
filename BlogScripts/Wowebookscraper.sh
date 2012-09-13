#!/bin/bash

outputIntermediaryfile=/tmp/wowAllFrontPageLinks.html
outputIntermediaryImagefile=/tmp/wowAllFrontPageImages.html

wowtemp=/tmp/wowtemp.html
indexfile=/tmp/wow.html

wget -q http://www.wowebook.be -O $indexfile

#create file & output headers:
echo "<html><body>" > $outputIntermediaryfile
echo "<html><body>" > $outputIntermediaryImagefile

#NOTE: removed bc starting at www.wowebookc.om/page/1 redirects to www.wowebook.com/ 
#output first page to file
#grep "rel=\"bookmark\"" $indexfile >> $outputIntermediaryfile
#grep "img.wowebook.com" $indexfile >> $outputIntermediaryImagefile


lastpage=$( grep ">\.\.\.<" $indexfile | sed 's/.*page\///g;s/\/.*//' )
echo "last page is $lastpage"

counter=1

#let 'lastpage+=1'
#debug lastpage=3

while [ $counter -le $lastpage ]
do 
echo -n "$counter "
wget -q http://www.wowebook.be/page/$counter -O $wowtemp
grep "rel=\"bookmark\"" $wowtemp >> $outputIntermediaryfile
grep "img.wowebook.com" $wowtemp | sed 's/<p>//;s/<\/p>//' >> $outputIntermediaryImagefile
let 'counter+=1'

done

echo "</body></html>" >> $outputIntermediaryfile
echo "</body></html>" >> $outputIntermediaryImagefile
