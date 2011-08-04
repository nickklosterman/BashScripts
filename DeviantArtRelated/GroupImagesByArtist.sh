#!/bin/bash
#this script sorts the images downloaded from Deviantart according to artist and displays them according to artist and not by filename

ls *_by_* > List1.txt
sed 's/^.*_by_//;s/-.*//;s/\..*//' List1.txt > List1ArtistHandles.txt
#add line numbers so we can join on that field since the two files will have the same line numbers for the appropriate fields
sed = List1.txt | sed 'N;s/\n/\t/' > List1.linesnumbered.txt
sed = List1ArtistHandles.txt | sed 'N;s/\n/\t/' > List1ArtistHandles.linesnumbered.txt
join List1.linesnumbered.txt List1ArtistHandles.linesnumbered.txt > List1.joined.txt
#sort on the third field (the artist handle)
sort -k3 List1.joined.txt > List1.sorted.txt
   #remove the numbering; not needed if we use the cut as we do below
   #sed 's/^[0-9]* //' List1.joined.txt
#remove all but the file name
cut -d' ' -f2 List1.sorted.txt > ImagesSortedByArtist.txt
uniq -d -f2 List1.sorted.txt | cut -d' ' -f3 > ArtistsWithMultipleImages.txt
uniq -D -f2 List1.sorted.txt | cut -d' ' -f2 > ImagesByArtistsWithMultipleImages.txt
#rm List1.txt List1ArtistHandles.txt List1.linesnumbered.txt List1ArtistHandles.linesnumbered.txt List1.joined.txt List1.sorted.txt 

#feh --geometry 1024x768 -f ImagesSortedByArtist.txt &
feh --geometry 1024x768 -f ImagesByArtistsWithMultipleImages.txt &
less ArtistsWithMultipleImages.txt

#for just the files wher eyou have more than one image by that 