#!/bin/bash
if [ $# -lt 1 ]
then 
echo "Enter datecode like '20110224' "
else

index=1
while [ $index -lt 60 ]
do 
wget http://www.orsm.net/shite/update${1}/rs$(printf "%03d" $index).jpg
let "index+=1"
done
fehh rs0*.jpg
fi