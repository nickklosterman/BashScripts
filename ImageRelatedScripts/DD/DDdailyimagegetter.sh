#!/bin/bash
#The pictures are updated about 0200 EST
cd /home/nicolae/Documents/Artwork/DD/
todaysdate=`date +%F`
filename=DD$todaysdate.jpg
echo $filename
echo $todaysdate
if [ -e $filename ]
then
    echo "File $filename  all ready exists!"
    echo "if this were to run in a cron job we'd append this to a log file of some sort"
else 

#    wget http://www.digitaldesire.com/glamour-tour/common/dailyphoto/image.php
#    mv image.php $filename
    wget -q http://www.digitaldesire.com/tour/potd
    eval "`grep idx potd | sed -n 's/.*src="//p'  | sed -n -e 's/^\([^<]*\)".*/\1/p' | sed 's/http/wget http/'` "
#    wget http://cdn.digitaldesire.com/digitaldesire/bp-content/tour/dailyphoto/908/idx-1024-jpg.jpg
    pwd
    rm potd
    mv idx-1024-jpg.jpg $filename
fi
#eog $filename &
#gthumb $filename &
display $filename &

#todaysdate=`date +%F`
filename=DDGirls$todaysdate.jpg
echo $filename
echo $todaysdate
if [ -e $filename ]
then
    echo "File $filename  all ready exists!"
    echo "if this were to run in a cron job we'd append this to a log file of some sort"
else 
    wget -q http://www.hicksphoto.com/cgi-bin/picoday/current-full.jpg
    mv current-full.jpg $filename
fi
#eog $filename &    if there isn't an image this will cause things to screw up for all open EOGs
todaysdate=`date +%F`
filename=DDGirls2-$todaysdate.jpg
echo $filename
echo $todaysdate
if [ -e $filename ]
then
    echo "File $filename  all ready exists!"
    echo "if this were to run in a cron job we'd append this to a log file of some sort"
else 
    wget -q http://www.hicksphoto.com/rotating/daily_photo/getpic.php?res=1024
#http://www.hicksphoto.com/rotating/daily_photo/full_pic_of_the_day.html?x=1
    mv getpic.php?res=1024 $filename
fi
#eog $filename &
#gthumb $filename &
feh $filename &

if [ -e /tmp/BlogImages ] 
then
    rm /tmp/BlogImages
fi

#http://www.digitaldesire.com/blog.xml <- uses html codes for < i.e. &lt;
wget -q http://www.digitaldesire.com/blog/newest_post -O /tmp/DDnewpost
#grep cdn /tmp/DDnewpost | sed 's/^.*http/http/;s/[Jj][Pp][Gg].*/jpg/'>> /tmp/BlogImages
grep cdn /tmp/DDnewpost | grep auto |  sed 's/^.*http/http/;s/\x27.*//' >> /tmp/BlogImages #key off single quote on backend
grep cdn /tmp/DDnewpost | grep auto | sed 's/^.*http/"http/;s/\x27.*/"/' >> /tmp/BlogImages #key off single quote on backend

#I am trying to preload so there isn't the stutter as it goes and gets the next image but it isn't working
#cd /home/nicolae/Documents/Artwork/DD/BlogImgs
#wget -nc -i /tmp/BlogImages
cat /tmp/BlogImages

#feh is changing the contents of /tmp/BlogImages. it overwrites the links with the tmp filenames it creates/uses

feh -f /tmp/BlogImages &
#cat /tmp/BlogImages


cd /home/nicolae/Documents/Artwork/DD/
#fdupes -r -d . #<- I think this wasn't showing up since I backgrounded the op
