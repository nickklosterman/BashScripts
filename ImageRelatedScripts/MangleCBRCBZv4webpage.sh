#!/bin/bash

function convertArchivesIntoWebpageDirectory()
{
    imagesPerPage=$1
    echo "${2}"
    i="${2}"
    echo "inmakestuff=$i" # why aren't we getting anything
    IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
    extension1=${i##*.}
    extension=${extension1,,} #convert to all lower case
    ###
    foldernamept2=${i%.*}       #the name was screwing stuff up cause the following commands weren't cutting the filename correctly. 
    foldernamept1=${foldernamept2%%(*} #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace                     
        #foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace                                    
	foldername=${foldernamept1//[[:space:]]} #<-- this removes the all whitespace                                    
	foldernamenospace=${foldername//[[:punct:]]} # echo "$foldername" | tr '[:punct:]' '_' }
        echo "Foldernames:-$foldername-$foldernamept1-$foldernamept2-$foldernamenospace"
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html                                               
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.                            
	
	
######
        if [ !  -e "$foldernamenospace" ]
        then
            echo "creating $foldername directory--only do this for the zip case?? yes bc we create the directory we want with the unrar cmd" 
            mkdir "$foldernamenospace" #create folder if doesn't exist                      
        fi
######## 
	echo "$extension"	
	if [ "$extension" = "cbr" ]
	then
	    echo "CBR file"
#	    unrar x "$i"  -d "$foldername" 1>>/dev/null #this will extract w full path
#	    unrar x "$i"  -d 1>>/dev/null #this will extract w full path
	    unrar e "$i" -d "$foldernamenospace" # if the directory doesn't exist unrar will skip extracting the files
#	    mv  *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg] "$foldername"
	else #assume that its cbz
	    olddir=$( pwd )
	    echo "$pwd"

	    echo "CBZ file"
#	    unzip "$i"  -d "$foldername" 1>>/dev/null #send stdoutput to null
#	    unzip "$i"  1>>/dev/null #send stdoutput to null


	    unzip "$i" -d /tmp/Comic 1>>/dev/null #send stdoutput to null
	    olddir=$( pwd )
	    echo "$olddir"
	    for i in /tmp/Comic/*
	    do
		if [ -d "$i" ] 
		then  
		    echo "$i" 
		    cd "$i" 
		    ls 
		    mv *.* "$olddir/$foldernamenospace" 
		fi 
	    done
	    cd "$olddir"

	    rm /tmp/Comic  -rf
	fi
#mv extracted images to directory 
}

function createHtml()
{

	for decompressdir in * #"$foldername"
	do 
	    echo "in  decompress dir"
	    pwd
	    if [ -d "$decompressdir" ]
	    then

		echo "Moving into directory $decompressdir"
		cd "$decompressdir"

		echo "creating webpage"
		HTMLpage="0000Webpage.html" #use this filename so it will be close to the top
		echo "<html><body><title>$foldername</title>" > $HTMLpage
		for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
		do 
		    if [ -f "$image" ] #prevents output when isn't a file; ie. catches when no images of one of the categories
		    then
#could mogrify here as well.
			imagenospaces=${image//[[:space:]]} 
			if [ "$image" != "$imagenospaces" ]
			then
			    mv "$image" "$imagenospaces" #otherwise mv complains
			fi
#check width/height etc
#		    mogrify -resize 800x800 "$imagenospaces"
#		    mogrify -resize 1200x1200 "$imagenospaces"
			width=$( identify -format "%w" "${imagenospace}" )
			height=$( identify -format "%h" "${imagenospace}" )
			if [ $width -gt $height ]
			then
#double page
			    mogrify -resize 1200x1200 "$imagenospaces"
			else
			    mogrify -resize 800x800 "$imagenospaces"
			fi

#need to figure out how to only output stuff about images if there are any. 
			
			echo "<hr><img src=\"$image\"><br>" >> "$HTMLpage"
		    fi
		done
		echo "</body></html>" >> "$HTMLpage" #close out last page                           
	

		echo "Leaving directory $decompressdir"
		cd ..
	    else
		echo "not a dir $decompressdir"	    
	    fi
	done
#	    uploadfiles "$foldername" "$HTMLpage"
	   # cd ../
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
    for item in *.[Cc][Bb][RrZz]
    do
	echo "--$item--"
	convertArchivesIntoWebpageDirectory $numberOfImagesPerPage "${item}"
    done
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do
	echo $1
	convertArchivesIntoWebpageDirectory $numberOfImagesPerPage "${1}"
	shift
    done
fi
createHtml