#for item in `find *.meta -ctime -40`; do echo $item ;cp $item redoTorrents/; done
function torrentify()
{
magnetURI=${1}
echo $magnetURI

[[ "$magnetURI" =~ xt=urn:btih:([^&/]+) ]] || exit
echo "d10:magnet-uri${#magnetURI}:${magnetURI}e" > "meta-${BASH_REMATCH[magnetURI]}.torrent"

}

#!/bin/bash
for item in *.meta
do 
filename=${item%%.*}
#echo $filename $item
magnetURI="magnet:?xt=urn:btih:${filename}&tr=udp%3A%2F%2Ftracker.openbittorrent.com%3A80&tr=udp%3A%2F%2Ftracker.publicbt.com%3A80&tr=udp%3A%2F%2Ftracker.istole.it%3A6969&tr=udp%3A%2F%2Ftracker.ccc.de%3A80&tr=udp%3A%2F%2Fopen.demonii.com%3A1337" 
#echo "d10:magnet-uri${#filename}:${magnetURI}e" > "meta-${BASH_REMATCH[filename]}.torrent"

echo $magnetURI > ${filename}.torrent
#torrentify $magnetURI
done


