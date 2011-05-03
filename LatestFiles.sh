#!/bin/bash

numitems=22 #${1}
counter=0
for items in `ls -t *.sh` #[Mm][Pp]3`
do 
echo "${items}"
if  [ $counter -eq $numitems ]
then
    exit
fi
let 'counter+=1'
done