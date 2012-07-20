#!/bin/bash
if [ $# -lt 1 ]
then 
echo "Enter datecode like '20110224' sometimes there are two RS in a post so just append a 1 or 2 to the date "
echo "I wanto allow for specifiying number of weeks back to go as well; itd def be easier with python"
else

index=1
while [ $index -lt 51 ]
do 
wget http://www.orsm.net/shite/update${1}/rs$(printf "%03d" $index).jpg
let "index+=1"
done
feh rs0*.jpg
fi