#!/bin/bash
df
echo
#df /tmp | cut -f 4
#echo
#df /home | cut -f 1
#echo
df /tmp | grep -v Filesystem | awk '{ print $4 }'
echo
df /home | grep -v Filesystem | awk '{ print $4 }'
echo
du -k .
echo
du -k . | cut -f 1
