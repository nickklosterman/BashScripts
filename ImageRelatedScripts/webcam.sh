#!/bin/bash
# This will take multiple images from a webcam and save off the largest image 

#http://www.raspberrypi.org/learning/webcam-timelapse-setup/
#or
#http://www.raspberrypi.org/documentation/installation/installing-images/linux.md

DATE=$(date +"%Y-%m-%d_%H%M")

#fswebcam -r 1280x720 --no-banner /home/camera/$DATE.jpg

#http://www.raspberrypi.org/forums/viewtopic.php?f=45&t=60076
#I was receiving this error : fswebcam - gd-jpeg: JPEG library reports unrecoverable error
#adding the -S 2 seemed to help
#fswebcam -r 1280x1024 -S 2  /home/camera/$DATE.jpg
#fswebcam -r 1280x1024 -S 2  /home/camera/$DATE.jpg
#fswebcam -r 1280x1024 -S 2  /home/camera/$DATE.gif
#fswebcam -p YUYV -d /dev/video0 /home/camera/$DATE.jpg
# I never got this shit to work with this damn HP Webcam 2100


# I did get ffmpeg to work just fine with it.
#http://askubuntu.com/questions/102755/how-do-i-use-ffmpeg-to-take-pictures-with-my-web-camera
touch /tmp/cronHeartbeat
#touch /home/camera/$DATE.jpg
echo "$DATE" >> /home/camera/cronHeartbeat.txt

killall ffmpeg #make sure that there isn't a zombie process preventing us from working; should proly ps aux grep for an ffmpeg process for a more elegant approach
#ffmpeg -f video4linux2 -i /dev/v4l/by-id/usb-_HP_Webcam_2100-video-index0 -vframes 2 test%1d.jpeg -loglevel quiet -v quiet
ffmpeg -f video4linux2 -i /dev/v4l/by-id/usb-_HP_Webcam_2100-video-index0 -s 1024x768 -vframes 15 /tmp/test%1d.jpeg -loglevel quiet -v quiet  #try getting 15 frames and pray/hope that one of them is good.
#rm /home/camera/test1.jpeg
#mv /tmp/test3.jpeg /home/camera/$DATE.jpg

#get list of jpegs sorted by size one per line , print just the first entry (i.e. get the filename of the largest file we generated)
#ls /tmp/*.jpeg -S1c | head -1
largestfile=$( ls /tmp/*.jpeg -S1c | head -1 )
#mv /tmp/test3.jpeg /home/rpi/$DATE.jpg
mv $largestfile /home/rpi/$DATE.jpg
