#!/bin/bash
function makestuff()
{
    imagesPerPage=$1
    echo "${2}"
	i="${2}"
	echo "inmakestuff=$i" # why aren't we getting anything
	IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
	newfilename="blank"

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
	foldernamept2=${i%.*}	#the name was screwing stuff up cause the following commands weren't cutting the filename correctly.
	foldernamept1=${foldernamept2%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace
	    foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.
	    

	    echo "-$foldername-$foldernamept1-$foldernamept2"
	    mkdir "$foldername"
	    counter=1
	    HTMLpage="$foldername.html"
	    page=0
	    countermod=1
	    echo "<html><body><title>$foldername</title>" > $HTMLpage
	    for image in *.[jJ][Pp][Gg]
	    do
		let "countermod = $counter % $imagesPerPage"
		if  [ $countermod -eq 0 ]
		then
		    let 'pageplusone=page+1'
		    if [ $page -eq 0 ]
		    then
			echo "<a href=\"$foldername/$foldername-$pageplusone.html\">Next Page</a>" >> "$HTMLpage" #spec case since first html page is at root,others inside image directory
		    else
			echo "<a href=\"$foldername-$pageplusone.html\">Next Page</a>" >> "$HTMLpage"
		    fi

		    echo "</body></html>" >> "$HTMLpage" #close out last page
		    if [ $page -gt 0 ]
		    then
#dont' move the first page, but move all the others.
			mv "$HTMLpage" "$foldername" #--target-directory="$foldername"
		    fi
		    let 'page+=1'
		    HTMLpage="$foldername-$page.html"
		    echo "<html><body><title>$foldername pg $page</title>" > $HTMLpage #start new page
		fi
#		echo "$image"
		echo "<hr>$counter<br>" >> "$HTMLpage"
##		mogrify -resize 800x800 -type Grayscale -dither None $image #resize without changing formats
#		mogrify -resize 1200x1200 -type Optimize -dither None $image #resize without changing formats
		mogrify -resize 1200x1200 -type Optimize -dither None $image #resize without changing formats
		mv "$image" "$foldername/$foldername-$counter.jpg"
		if [ $page -eq 0 ]
		then
		    echo "<img src=\"$foldername/$foldername-$counter.jpg\"><br>" >> "$HTMLpage"
		else
		    echo "<img src=\"$foldername-$counter.jpg\"><br>" >> "$HTMLpage"
		fi
		
#		echo "$foldername-$counter.jpg"
		let 'counter+=1'
		echo $counter

	    done
	    echo "<a href=\"..\">Back to Main Dir</a>" >> $HTMLpage #close out last page
	    echo "</body></html>" >> "$HTMLpage" #close out last page
	    mv "$HTMLpage" "$foldername" #move the last page created.
	    HTMLpage="$foldername.html" #recreate the base webpage file so it gets uploaded
	    uploadfiles "$foldername" "$HTMLpage"
}
function decompressfile()
{
    echo "$1"
}

function uploadfiles()
{
directory="$1"
html="$2"
echo "uploading dir=$directory; html=$html;"
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

numberOfImagesPerPage=5
while getopts ":n:" OPTIONS 
do
    case ${OPTIONS} in 
	n|-numberofimagesperpage) echo "numperpage ${OPTARG}"
	    numberOfImagesPerPage=${OPTARG};;
    esac
done
#echo $numberOfImagesPerPage
shift $(($OPTIND - 1)) 
# Decrements the argument pointer so it points to next argument.
# $1 now references the first non-option item supplied on the command-line
#+ if one exists.

Number_Of_Expected_Args=1
if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: script archive archive ...."
    echo "acting on all cbr/cbz files in this directory"
#    for item in *.[Cc][Bb][RrZz]
    for item in *.[Cc][Bb][Rr]
    do
	echo "--$item--"
	makestuff $numberOfImagesPerPage "${item}"
#	decompressfile "$item"
    done
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do
	echo $1
	makestuff $numberOfImagesPerPage "${1}"
#	decompressfile "$1"
	shift
    done
fi