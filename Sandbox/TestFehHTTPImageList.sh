#!/bin/bash
Jim="http://th07.deviantart.net/fs10/150/i/2006/075/d/0/inkblot_by_redredundance.jpg http://th08.deviantart.net/fs26/150/f/2009/250/d/8/Holly_and_Molly_by_redredundance.png http://th01.deviantart.net/fs24/150/i/2009/244/4/3/Dave_by_redredundance.jpg "
feh ${Jim}
echo "${Jim}" > /tmp/fehtempimagelist
#feh -f /tmp/fehtempimagelist "${Jim}"
bob=`ls *4.jpg`
bobo="1291395354.jpg
16d34cd53ab993e5111978f882d58380-d3gu4r4.jpg
1a20df5e89200d26c63ebdebc490c9c1-d3j42w4.jpg
216546354.jpg
5c8d5070a4605071586b5b388e97a4e4.jpg
6fd281f47f1f888dd89c7aab4ea22923-d2u8h74.jpg
8d25f13b8888448dbbd83acfa8581ae4-d3b0z64.jpg
9ca40150b62dc130e642391b95cb9523-d2zziu4.jpg
below_by_obsessedkitten-d3h26s4.jpg
ddc85c0d643205b68579af1c19800f72-d3gtsx4.jpg
"
boboo="1291395354.jpg 16d34cd53ab993e5111978f882d58380-d3gu4r4.jpg 1a20df5e89200d26c63ebdebc490c9c1-d3j42w4.jpg 216546354.jpg 5c8d5070a4605071586b5b388e97a4e4.jpg"

#feh "${bobo}"
#feh *4.jpg this works
feh ${boboo}  # this works , quoting makes feh treat that argument (even though there are spaces in it ) all as one file name! duhh.
#feh *4.jpg this works