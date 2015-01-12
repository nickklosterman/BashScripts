#!/bin/bash

function getUrlOfLastPage() {
wget http://www.collectedcurios.com/sequentialart.php?s=1 -O /tmp/sequentialartcollectedcurios
lastpage=$( grep 'title="Last"' /tmp/sequentialartcollectedcurios | sed 's/title="Forward ten"//;s/.*s=//;s/".*//' )
echo ${lastpage}
}

counter=1
lastpage=$( getUrlOfLastPage )


# while [ $counter -le ${lastpage} ]
# do 
# fileNumber=$( printf "%04d" ${counter} )
# wget -nv -U "Mozilla" http://www.collectedcurios.com/SA_${fileNumber}_small.jpg 
# let 'counter+=1'

# done

zip Sequentialartcollectedcurios SA_*.jpg
mv Sequentialartcollectedcurios.zip Sequentialartcollectedcurios.cbz
evince Sequentialartcollectedcurios.cbz  &


