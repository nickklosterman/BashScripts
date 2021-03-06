#!/bin/bash
function makestuff()
{

	IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
	newfilename="blank"
	i="$1"
	extension=${i##*.}
	if [ "$extension" = "cbr" ]
	then
	    echo "CBR file"
	    unrar e "$i"
	fi
	if [ "$extension" = "cbz" ]
	then
	    echo "CBZ file"
	    unzip "$i"
	fi
	
	foldernamept1=${i%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace
	    foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.
	    

	    echo "-$foldername-$foldernamept1-"
	    mkdir "$foldername"
	    counter=0
	    echo "<html><body><title>$foldername</title>" > "$foldername.html"
	    for image in *.[jJ][Pp][Gg]
	    do
		echo "$image"
		echo "<hr>$counter<br>" >> "$foldername.html"
#		mogrify -resize 800x800 -type Grayscale -dither None $image #resize without changing formats
		mogrify -resize 1200x1200 -type Optimize -dither None $image #resize without changing formats
		mv "$image" "$foldername/$foldername-$counter.jpg"
		echo "<img src=\"$foldername/$foldername-$counter.jpg\"><br>" >> "$foldername.html"

		echo "$foldername-$counter.jpg"
		let 'counter+=1'
		echo $counter
	    done
	    echo "</body></html>" >> "$foldername.html"
#	    uploadfiles "$foldername" "$foldername.html" 
}
function decompressfile()
{
    echo "$1"

}
function uploadfiles()
{
directory="$1"
html="$2"
echo "uploading $directory $html"
HOST='djinnius.com'
USER="Comic"
PASSWORD="shiarLilandraXavier"

ftp -in $HOST <<EOF
user $USER $PASSWORD
binary 
put "${html}"
mkdir "${directory}"
cd "${directory}"
lcd "${directory}"
mput *.*
quit
EOF
}
######################
##Begin Script
######################
echo "This is a simple script to automate the Mangle  (Manga-Kindle) app."

Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: script archive archive ...."
    echo "acting on all cbr/cbz files in this directory"
    for item in *.cb[rz]
    do
	makestuff "$item"
#	decompressfile "$item"
    done
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do
	makestuff "$1"
#	decompressfile "$1"

	
	shift
    done
fi