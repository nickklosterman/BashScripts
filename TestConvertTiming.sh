#!/bin/bash
for var in "$@"
do
file=$var
date
echo working on ${file}
#mencoder $file -nosound -vf pp=ci -ovc x264 -x264encopts qp=30:trellis=1:nr=500:pass=1:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid:weight_b -o /dev/null && mencoder $file -oac copy -vf pp=ci -ovc x264 -x264encopts qp=30:trellis=1:nr=500:pass=2:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:b_pyramid:weight_b -o ${file}.avi
mencoder $file -nosound -vf pp=ci -ovc x264 -x264encopts qp=30:trellis=1:nr=500:pass=1:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:weight_b -o /dev/null && mencoder $file -oac copy -vf pp=ci -ovc x264 -x264encopts qp=30:trellis=1:nr=500:pass=2:subq=6:partitions=all:8x8dct:me=umh:frameref=5:bframes=3:weight_b -o ${file}.avi
date
done