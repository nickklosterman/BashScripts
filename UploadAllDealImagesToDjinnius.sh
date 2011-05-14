#!/bin/bash
HOST='djinnius.com'
USER='djinnius'
PASSWORD=$1

ftp -i -n $HOST <<EOF

user ${USER} ${PASSWORD}

binary
cd Deals
put SteepandCheap.jpg
put WhiskeyMilitia.jpg
put Bonktown.jpg
put Chainlove.jpg
quit

EOF