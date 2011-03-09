1;2305;0c#!/bin/bash
ctr=1
while [ $ctr -lt 16 ]
do 
number=$(printf "%02d" $ctr);
     #http://www.luba-archives.com/gallery/galleries/Hegre/Victoria_Secret_Lingerie/12.jpg
#wget http://www.luba-archives.com/gallery/galleries/Hegre/Victoria_Secret_Lingerie/$number.jpg #it was being identified as a robot and being redirected with code 302 to google.com

#http://www.cs.sunysb.edu/documentation/curl/index.html
#curl --url http://www.luba-archives.com/gallery/galleries/Hegre/Victoria_Secret_Lingerie/$number.jpg
curl -O http://www.luba-archives.com/gallery/galleries/Hegre/Victoria_Secret_Lingerie/$number.jpg
let ctr+=1
mv $number.jpg Luba_Victoria_Secret_Lingerie_$number.jpg
done