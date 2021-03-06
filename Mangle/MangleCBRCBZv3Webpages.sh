#!/bin/bash

function convertimagesCBR()
{
#pass in foldername and imagesPerPage
foldername="${1}"
imagesPerPage=$2

counter=1
HTMLpage="$foldername.html"
page=0
countermod=1
echo "<html><body><title>$foldername</title>" > $HTMLpage
for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
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
    imagenum=$(printf "%03d" $counter ) 
    mv "$image" "$foldername/$foldername-$imagenum.jpg"
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
}

function convertimagesCBR()
{
#pass in foldername and imagesPerPage
foldername="${1}"
imagesPerPage=$2

counter=1
HTMLpage="$foldername.html"
page=0
countermod=1
echo "<html><body><title>$foldername</title>" > $HTMLpage
for image in *.[jJ][Pp][Gg] #*.[Gg][Ii][fF] *.[Pp][Nn][Gg]
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
    imagenum=$(printf "%03d" $counter ) 
    mv "$image" "$foldername/$foldername-$imagenum.jpg"
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
}
function convertArchivesIntoWebpageDirectory()
{
    imagesPerPage=$1
    echo "${2}"
    i="${2}"
    echo "inmakestuff=$i" # why aren't we getting anything
    IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
    newfilename="blank"
    extension=${i##*.}
    
    foldernamept2=${i%.*}	#the name was screwing stuff up cause the following commands weren't cutting the filename correctly.
    foldernamept1=${foldernamept2%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace
	foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace
	echo "Foldernames:-$foldername-$foldernamept1-$foldernamept2"
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.
	
	if [ !  -e "$foldername" ]
	then
	    echo "creating $foldername directory"
	    mkdir "$foldername" #create folder if doesn't exist
	fi

	
	if [ "$extension" = "cbr" ]
	then
	    echo "CBR file"
	    #pwd
	    unrar e "$i" #2>>/dev/null #send errors to null...or could send to a temp file for error logging
#	    unrar x "$i"  #this will extract w full path
#unrar e "$i" "$foldername" #extract into folder wo preserving full path
	fi
	if [ "$extension" = "cbz" ]
	then
	    echo "CBZ file"
	    #pwd
	    unzip "$i"  -d "$foldername" #21>>/dev/null #send stdoutput to null
	fi

	cd "$foldername"

	for decompressdir in * #"$foldername"
	do 
	    echo "in  decompress dir"
	    pwd
	    if [ -d "$decompressdir" ]
	    then
		echo "its a directory $decompressdir"
		ls "$decompressdir"
		cd "$decompressdir"
		mv *.* ..
		cd ..
		rm "$decompressdir"
	    else
		echo "not a dir $decompressdir"	    
	    fi
	done
#	    uploadfiles "$foldername" "$HTMLpage"
	   # cd ../
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
echo "###I never finished this script bc I thoughto f a simpler way of decmopressing these files for viewing on teh andriod##"
echo "###########WARNING due to the above the script may not work 100%#"
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
    for item in *.[Cc][Bb][RrZz]
#    for item in *.[Cc][Bb][Rr]
    do
	echo "--$item--"
	convertArchivesIntoWebpageDirectory $numberOfImagesPerPage "${item}"
#	decompressfile "$item"
    done
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do
	echo $1
	convertArchivesIntoWebpageDirectory $numberOfImagesPerPage "${1}"
#	decompressfile "$1"
	shift
    done
fi