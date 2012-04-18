#!/bin/bash
#TODO:
#work on collections that are rared or zipped. Then need to make sure unzip and unrar teh cbr/cbz files that were extracted.
#append W or H identifier to the directory for which style they are
#recurse directories (CLI switch to activate)
#error logging -> broken archives, empty directories
#exclude scanner images. Have filenames listed in a file, or listed in a variable/array inside 
ScannerFileNames="zGGtagT.jpg zGGtag.jpg" #need for way to captures these like did with ibd industry names

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
#        echo "Foldernames:-$foldername-$foldernamept1-$foldernamept2-$foldernamenospace"
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html                                               
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.                            
	
	
######
        if [ !  -e "$foldernamenospace" ]
        then
            echo "creating $foldername directory" 
            mkdir "$foldernamenospace" #create folder if doesn't exist                      
        fi
######## 
	echo "$extension"	
	if [ "$extension" = "cbr" ]
	then
	    echo "CBR file"
#	    unrar x "$i"  -d "$foldername" 1>>/dev/null #this will extract w full path
#	    unrar x "$i"  -d 1>>/dev/null #this will extract w full path
	    unrar e "$i" -d "$foldernamenospace" 2>> /tmp/DecompressErrorLog.txt # if the directory doesn't exist unrar will skip extracting the files
#	    mv  *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg] "$foldername"
	else #assume that its cbz
	    olddir=$( pwd )
	    echo "$pwd"

	    echo "CBZ file"
#	    unzip "$i"  -d "$foldername" 1>>/dev/null #send stdoutput to null
#	    unzip "$i"  1>>/dev/null #send stdoutput to null


#	    unzip "$i" -d /tmp/Comic 1>>/dev/null #send stdoutput to null
	    unzip "$i" -d /tmp/Comic 2>> /tmp/DecompressErrorLog.txt  #send stderr to log
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

    function createHtmlAndImages()
    {
	pageformat=$1
	echo "pageformat $pageformat"
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
		echo "<html><body><title>$decompressdir</title>" > $HTMLpage
		for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
		do 
#		    echo "$image"
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
			width=$( identify -format "%w" "${imagenospaces}" )
			height=$( identify -format "%h" "${imagenospaces}" )
#output dot so shows we are progressing
			echo -n "."
			if [ $width -gt $height ]
			then
#double page
			    echo "double page"
			    extension=${imagenospaces##*.}
			    filename=${imagenospaces%.*}
			    if [ 1 == $pageformat ] #variable can't be first???
			    then 
				mogrify -resize 1600x2560 "$imagenospaces"
#there is a limitation to the Android Browser/Gallery application. Images > ~1200px in any dimension are displayed with reduced resolution (almost as if it was a progressive jpg that they stopped decoding before the last quantization level)
#the 3x1@-> make 3 horizontal by 1 vertical tile of the source image. 3x1->make 3px wide by 1 px tall tiles from the source image
				convert "$imagenospaces" -crop 1x3@ +repage +adjoin "$filename-%d.$extension"
			    else
				mogrify -resize 1200x1900 "$imagenospaces"
				convert "$imagenospaces" -crop 1x3@ +repage +adjoin "$filename-%d.$extension"
			    fi
#			    mogrify -resize 1200x1900 "$imagenospaces"
			else
			    if [ 1 == $pageformat ]
			    then 
				mogrify -resize 800x1280 "$imagenospaces" #this crops a bit of width so it meets the height
			    else
				mogrify -resize 600x950 "$imagenospaces" #crop so full width and height just a smidge over.
			    fi
			fi

#need to figure out how to only output stuff about images if there are any. 
			
			echo "<hr><img src=\"$image\"><br>" >> "$HTMLpage"
		    fi
		done
		if [ 0 == $pageformat ]
		then
		    echo "<br><br><br>" >> "$HTMLPage" #add EOF padding as it seems that due to the back-home-option softkeys that the last bit of the page isn't viewable. this isn't a problem when using the wide view
		fi
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
    
    function createHtml()
    {
	pageformat=$1
	echo "pageformat $pageformat"
	for decompressdir in * #"$foldername"
	do 
	    echo "in  decompress dir"
	    pwd
	    if [ -d "$decompressdir" ]
	    then
		
		echo "Moving into $decompressdir"
		cd "$decompressdir"
		
		echo "creating webpage"
		HTMLpage="0000Webpage.html" #use this filename so it will be close to the top
		echo "<html><body><title>$decompressdir</title>" > $HTMLpage
		echo "<h5>$decompressdir</h5>" >> $HTMLpage
		for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
		do 
		    if [ -f "$image" ] #prevents output when isn't a file; ie. catches when no images of one of the categories
		    then
			#imagenospaces=${image//[[:space:]]}  #the browsers available for android appear to not be able to handle spaces in filenames
			#echo "<hr><img src=\"$imagenospaces\"><br>" >> "$HTMLpage"
#the above shouldn't be needed since we split the html and convert into separate pieces
			filenamecheck=${image%-*} #cut filename for comparison. cook-0.jpg -> cook; cook.jpg -> cook; this should work since it only captures the last hyphen and there shouldn't be any file names with hyphens since we strip that out for the images with the [:punct:]
# image -> filenamecheck -> filenamecheck.jpg
#cook-1.jpg -> cook -> cook.jpg which will exist so we know we have a slice of a dbl page image; cook.jpg -> cook.jpg -> cook.jpg.jpg which means it is a single page image
			if [ -f "$filenamecheck.jpg" ] #this is a roundabout way of looking for the split images since they are "image-#.jpg" where # is the slice of the image
			then 
			    echo "<img src=\"$image\" alt=\"$image\">" >> "$HTMLpage" #if it is a sliced image then don't output the hr and br
			else
			    echo "<hr><img src=\"$image\" alt=\"$image\"><br>" >> "$HTMLpage"
			fi
		    fi
		done
		echo "<br><br><br>" >> "$HTMLpage" #add EOF padding as it seems that due to the back-home-option softkeys that the last bit of the page isn't viewable.
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

    function convertImages()
    {
	pageformat=$1
	echo "pageformat $pageformat"
	for decompressdir in * #"$foldername"
	do 
	    echo "in  decompress dir"
	    pwd
	    if [ -d "$decompressdir" ]
	    then
		echo "Moving into directory $decompressdir"
		cd "$decompressdir"
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
			width=$( identify -format "%w" "${imagenospaces}" )
			height=$( identify -format "%h" "${imagenospaces}" )
#output dot so shows we are progressing
			echo -n "."
			if [ $width -gt $height ]  #if page is wider than it is long we consider it to be a double page
			then
#double page
			    echo "double page"
			    extension=${imagenospaces##*.}
			    filename=${imagenospaces%.*}
			    if [ 1 == $pageformat ] #variable can't be first??? alternative method is to place it in [[ expr ]] this works 
			    then 
				mogrify -resize 1600x2560 "$imagenospaces"
#there is a limitation to the Android Browser/Gallery application. Images > ~1200px in any dimension are displayed with reduced resolution (almost as if it was a progressive jpg that they stopped decoding before the last quantization level)
#the 3x1@-> make 3 horizontal by 1 vertical tile of the source image. 3x1->make 3px wide by 1 px tall tiles from the source image
				convert "$imagenospaces" -crop 1x3@ +repage +adjoin "$filename-%d.$extension"
			    else
				mogrify -resize 1200x1900 "$imagenospaces"
				convert "$imagenospaces" -crop 1x3@ +repage +adjoin "$filename-%d.$extension"
			    fi
#create a smaller image so can see the whole dbl page spread nicely -kinda like the overview of the context+overview paradigm
			    mogrify -resize 800x800 "$imagenospaces"
			else
			    if [ 1 == $pageformat ]
			    then 
#these dimensions were chosen as the BPDN (black pandigital Nove) has a 800x600 screen resolution
				mogrify -resize 800x1280 "$imagenospaces" #this crops a bit of width so it meets the height
			    else
				mogrify -resize 600x950 "$imagenospaces" #crop so full width and height just a smidge over.
			    fi
			fi

#need to figure out how to only output stuff about images if there are any. 

		    fi
		done

		echo "Leaving directory $decompressdir"
		cd ..
	    else
		echo "not a dir $decompressdir"	    
	    fi
	done

    }



######################
##Begin Script
######################
    echo "This is a simple script to automate the Mangle  (Manga-Kindle) app."

    numberOfImagesPerPage=5
    wideformat=0
    deletearchives=0
    while getopts ":n:whd" OPTIONS 
    do
	case ${OPTIONS} in 
	    n|-numberofimagesperpage) echo "numperpage ${OPTARG}"
		numberOfImagesPerPage=${OPTARG};;
	    w|-fullwidth) echo "fullwidth" #on the BPDN we'd flip it on side as the min dimension will be 800
		wideformat=1;;
	    h|-fullheight) echo "fullheight" #on the BPDN we'd flip it on side as the min dimension will be 600
		wideformat=0;;
	    d|-deletearchives) echo "delete archives" #on the BPDN we'd flip it on side as the min dimension will be 800
		deletearchives=1;;
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
#if don't want it to recurse 1 directory depth then need to take that bit of code out from these two functinos
    convertImages $wideformat 
    createHtml $wideformat