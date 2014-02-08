#!/bin/bash

# This script will go out and pu

file="/tmp/nprtedrsspodcasts"
file2="/tmp/nprtedrsspodcasts_2"

wget http://www.npr.org/rss/podcast.php?id=510298 -O ${file}
#grep "<guid>" ${file} | sed 's/<guid>/wget /;s/<\/guid>//' >  ${file2}
grep "<guid>" ${file} | sed 's/<guid>//;s/<\/guid>//' >  ${file2}
cat ${file2}

# while read LINE 
# do 
# echo $LINE
# wget $LINE
# done < ${file2}

for WORD in `cat ${file2}`  #this evaluates each string, so above I had stuck 'wget' in there, but that was being read separately. It doesn't read line by line.
do
echo $WORD
wget $WORD
done
