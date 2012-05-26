#!/bin/bash
wget -q http://www.theyetee.com -O /tmp/theyetee.com
filelist=$( grep shirt_images /tmp/theyetee.txt | sed 's/.*\/shirt/http:\/\/theyetee.com\/shirt/;s/".*//;s/\x27.*//' )
feh ${filelist}