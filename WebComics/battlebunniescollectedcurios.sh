#!/bin/bash

function getUrlOfLastPage() {
#http://www.collectedcurios.com/battlebunnies.php?s=38
wget http://www.collectedcurios.com/battlebunnies.php?s=1 -O /tmp/battlebunniescollectedcurios
lastpage=$( grep 'title="Last"' /tmp/battlebunniescollectedcurios | sed 's/title="Forward ten"//;s/.*s=//;s/".*//' )
echo ${lastpage}
}

counter=1
lastpage=$( getUrlOfLastPage )


while [ $counter -le ${lastpage} ]
do 
fileNumber=$( printf "%03d" ${counter} )
wget -nv -U "Mozilla" http://www.collectedcurios.com/BBTSN_${fileNumber}_Small.jpg 
let 'counter+=1'

done

zip Battlebunniescollectedcurios BBTSN*.jpg
mv Battlebunniescollectedcurios.zip Battlebunniescollectedcurios.cbz
evince Battlebunniescollectedcurios.cbz  &


