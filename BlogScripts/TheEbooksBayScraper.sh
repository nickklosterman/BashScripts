#!/bin/bash

outputIntermediaryfile=/tmp/theebooksbayAllFrontPageLinks.html
outputIntermediaryImagefile=/tmp/theebooksbayAllFrontPageImages.html

temp=/tmp/tebtemp.html

wget -q http://theebooksbay.com -O $temp

#create file & output headers:
echo "<html><body>" > $outputIntermediaryfile
echo "<html><body>" > $outputIntermediaryImagefile

lastpage=$( grep ">\.\.\.<" $temp | sed 's/.*page\///g;s/\/".*//' )
echo "last page is $lastpage"

counter=1

#let 'lastpage+=1'
#debug lastpage=3

while [ $counter -le $lastpage ]
do 
echo -n "$counter "

wget -q http://theebooksbay.com/page/$counter/ -O $temp
grep "poststuff" $temp  >> $outputIntermediaryfile
grep "Shared" $temp | sed 's/.*<img src/<img src/;s/\/>.*/\/>/;s/<img src=\"\/images\/default_cover.jpg\"/<img src=\"http:\/\/theebooksbay.com\/images\/default_cover.jpg\"/ '  >> $outputIntermediaryImagefile
let 'counter+=1'

done

echo "</body></html>" >> $outputIntermediaryfile
echo "</body></html>" >> $outputIntermediaryImagefile
