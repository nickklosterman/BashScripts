#!/bin/bash

outputIntermediaryfile=/tmp/magfreakAllFrontPageLinks.html
outputIntermediaryImagefile=/tmp/magfreakAllFrontPageImages.html

temp=/tmp/mftemp.html

wget -q http://www.magazinefreak.com -O $temp

#create file & output headers:
echo "<html><body>" > $outputIntermediaryfile
echo "<html><body>" > $outputIntermediaryImagefile

#NOTE: removed bc starting at www.wowebookc.om/page/1 redirects to www.wowebook.com/ 
#output first page to file
#grep "rel=\"bookmark\"" $indexfile >> $outputIntermediaryfile
#grep "img.wowebook.com" $indexfile >> $outputIntermediaryImagefile


lastpage=$( grep ">\.\.\.<" $temp | sed 's/.*page\///g;s/".*//' )
echo "last page is $lastpage"

counter=1

#let 'lastpage+=1'
#debug lastpage=3

while [ $counter -le $lastpage ]
do 
echo -n "$counter "
wget -q http://www.magazinefreak.com/page/$counter -O $temp
grep "h2" $temp | grep magazinefreak >> $outputIntermediaryfile
grep "img src" $temp | grep "class" |  sed 's/.*<img/<img/;s/<\/a><\/p>//;s/\/images/http:\/\/www.magazinefreak.com\/images/' >> $outputIntermediaryImagefile
let 'counter+=1'

done

echo "</body></html>" >> $outputIntermediaryfile
echo "</body></html>" >> $outputIntermediaryImagefile
