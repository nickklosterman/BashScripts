#!/bin/bash
#
#  Author: Finnbarr P. Murphy
#    Date: July 27th, 2010
#
#  Copyright (c) Finnbarr P. Murphy 2010
#
 if [[ $# -lt 2 ]]
then 
echo  -n "Enter the YouTube ID to copy: "
read ID
[[ -z $ID ]] && exit 1
else
ID=$1
 fi

TMP=/var/tmp/yt.$$
#QUIET="-q"             
QUIET="--progress=bar"
 
WGET=/usr/bin/wget
SED=/bin/sed
TR=/usr/bin/tr
 
$WGET ${QUIET} -O ${TMP} "http://www.youtube.com/watch?v=${ID}"
[[ $? > 0 ]] && exit 2
 
VIDEOFILE=$($SED -n "/fmt_url_map/{s/[\'\"\|]/\n/g;p}" ${TMP} | \
            $SED -n '/^fmt_url_map/,/videoplayback/p' | \
            $SED -e :a -e '$q;N;5,$D;ba' | $TR -d '\n' | \
            $SED -e 's/\(.*\),\(.\)\{1,3\}/\1/')
 echo -n "--" 
echo ${VIDEOFILE}
 echo -n "--" 
  #rm -f $TMP
echo -n "Downloading video ...."
 
# download video to file named "downfile". Change as necessary
$WGET ${QUIET} -O downfile "${VIDEOFILE}"
[[ $? > 0 ]] &&  {
   echo "ERROR: Download failed"
   exit 3
}
echo " Done"
 
# play the video using totem. Change as necessary
vlc downfile &
 
exit 0
