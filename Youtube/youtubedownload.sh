#!/bin/bash
bu="http://youtube.com/get_video.php?";mkdir -p ~/YouTube;cd ~/YouTube;read -p "YouTube url? " ur;read -p "Name? " nv
wget ${ur} -O /tmp/y1;uf=${bu}`grep player2.swf /tmp/y1 | cut -d? -f2 | cut -d\" -f1`;wget "${uf}" -O /tmp/y.flv
ffmpeg -i /tmp/y.flv -ab 56 -ar 22050 -b 500 -s 320x240 ${nv}.mpg;rm /tmp/y.flv; rm /tmp/y1;rm gmon.out; exit
