#!/bin/bash
#v4: performed all decompression, then all converting of images, then create all webpages
#Difference from v4: to overcome the problem of recursing directories and creating webpages where no archive was extracted we work on 1 archive at a time (decompress X, convert Xs images, create Xs webpage)
#TODO:
#create -h help dialog
#catch ctrl-c and exit gracefully
#only delete if unrar/zip was successful
#add option to specify dimensions of converted files
#add option and functionality to compress the images a bit
#add option and functionality to sharpen the images
#add option to pass imagemagick options
#prevent splitting html across a double page image - catch filename and set flag. clear flag when not dbl (hopefully this will also keep the overview image on same html page as well)
#DONE perform disk space check to ensure have enough space to extract archive and create images
#DONE need to do check and see if multiple files in a directory will write to the same directory and overwrite. If so then append# to the directory. That happened with XMen First Class
#work on collections that are rared or zipped. Then need to make sure unzip and unrar teh cbr/cbz files that were extracted.
#append W or H identifier to the directory for which style they are
#recurse directories (CLI switch to activate)
#DONE error logging -> broken archives, empty directories
#exclude scanner images. Have filenames listed in a file, or listed in a variable/array inside 

ScannerFileNames="zGGtagT.jpg zGGtag.jpg" #need for way to captures these like did with ibd industry names

function splitLargeComicsHTML()
{
dir="${1}"
flag=0 #set to 1 if we split
    ImageThreshold=30 #max number of images we'll allow before creating a set of pages with less images per page                                
    imagesPerPage=28 #could also just set to $ImageThreshold                                                                                    
#crawl through directories and if the number of images is greater than a threshold then we'll create a set of webpages to split the         
#images across several webpages                                                                                                             
#find number of images in the directory                                                                                                     
    numimages=$(  ls -1 *.[Jj][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg] 2>>/dev/null | wc -l )
#-->by redirecting stderr to /dev/null I dont get the "no such file or directory output"                                                            totalimages=$numimages #-subtractnumimages                                                        
#    echo "$totalimages >  $ImageThreshold"
#if the number of images crosses the threshold we'll make separate pages with fewer images per page                                         
    if [[ "totalimages" -gt "$ImageThreshold" ]]
    then
 #       echo "$dir will be split into separate smaller webpages"
        counter=1
        pagenum=$( printf "%02d" $counter )
        HTMLpage="000$dir-$pagenum.html"
        page=1
        countermod=1
        echo "<html><body><title>$dir pg $pagenum</title>" > $HTMLpage
	
        for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
        do
            if [ -f "$image" ] #prevents output when isn't a file; ie. catches when no images of one of the categories                  
                then
		
                let "countermod = $counter % $imagesPerPage"
                if  [ $countermod -eq 0 ] #signal need to create new page                                                               
                then
                    let 'pageplusone=page+1'
                    pagenum=$( printf "%02d" $pageplusone )
                        #place link to next page at end of present html page                                                                
                    echo "<a href=\"000$dir-$pagenum.html\">Next Page</a>" >> "$HTMLpage"
                    echo "</body></html>" >> "$HTMLpage" #close out last page                                                           
                    let 'page+=1'
                    pagenum=$( printf "%02d" $page )
                    HTMLpage="000$dir-$pagenum.html"
  #                  echo "$counter  $pagenum"
                    echo "<html><body><title>$dir pg $pagenum</title>" > $HTMLpage #start new page                                      
                fi
		
                echo "<hr>$counter<br>" >> "$HTMLpage"
                echo "<img src=\"$image\"><br>" >> "$HTMLpage"
                let 'counter+=1'

            fi #end if its' an image                                                                                                    
        done #end processing images in jpg gif png                                                                                      
flag=1 
    fi #end processing if we're past the threshold and need to break into individ pages                                                 
    echo $flag
}

function createDirectoryForWebcomic()
{
    filename="${1}"
    foldernamenospaces=$( convertFoldername "${filename}" ) #put here since would be called recursively in checkForFileNameCollision
    number=0
    foldername="$foldernamenospaces"
    while [[ -e "$foldername" && -d "$foldername" ]] 
    do
	let 'number+=1'
	numberformat=$( printf "%02d" $number )
	foldername=$foldernamenospaces$numberformat
    done
    mkdir "$foldername"
    echo "$foldername"

}

function checkForFileNameCollision()
{ #----not used-----
    foldernamenospaces="${1}"
    number=$2
    numberformat=$( print "%02d" $number )

     if [ -e "${foldernamenospaces}" ]
     then
	 foldernamenumber="$foldernamenospaces$numberformat"
	 #need to recursively
     else 
	 mkdir "${foldernamenospaces}"
     fi
    
}

function getArchiveSize()
{
    size=$( du "${1}" | cut -f 1 )
    echo "$size"
}

function checkFileSpace()
{
    archive="${1}"
    archiveSize=$( getArchiveSize "$archive" )
    fivepercent=$(( $archiveSize / 20 ))
    archiveSizePlus5Percent=$(( $archiveSize + $fivepercent ))
    tempFreeSpaceStatus=$( checkdiskspace /tmp $archiveSizePlus5Percent )
    homeFreeSpaceStatus=$( checkdiskspace /home $archiveSizePlus5Percent )
    Status=1

    if [[ $tempFreeSpaceStatus -eq 0 ]]
    then
	echo "/tmp doesn't have enough free space to extract the archive."
	Status=0
    fi
    if [[ $tempFreeSpaceStatus -eq 0 ]]
    then
	echo "/home doesn't have enough free space to extract the archive."
	Status=0
    fi
    
    echo $Status
}

function checkdiskspace()
{   
#This is a lot easier than the roundabout method I developed in the Backcountry code
    diskspaceneeded=$2
    DiskSpace=$(df  "${1}" | grep -v Filesystem | awk '{ print $4  }' )
    Output=1
    if [[ $DiskSpace -lt  $diskspaceneeded ]]
    then
        Output=0
    fi

    echo ${Output}
}



function convertFoldername()
{
    i="${1}"  #this is the archives name
#    echo "inmakestuff=$i" # why aren't we getting anything
    IFS=$( echo -en "\n\b" )  #this changes the file delimiter which is normally a space to a newline so we can deal with files with spaces in them.
    
#remove extension
    foldernamept2=${i%.*}       #the name was screwing stuff up cause the following commands weren't cutting the filename correctly. 

#strip parens on back-->replaced with just stripping whats in the parens
#    foldernamept1=${foldernamept2%%(*}   #<-- use %% bc want to match longest sequence  but this leaves trailing whitespace              

#remove items in parens (typically the scanner group)
    foldernamept1=${foldernamept2/([^)]*)}


        #foldername=${foldernamept1/%[[:space:]]/} #<-- this removes the trailing whitespace                                    
foldername=${foldernamept1//[[:space:]]} #<-- this removes all the whitespace                                    
#remove any weird punctuation that might cause problems 
	foldernamenospace=${foldername//[[:punct:]]} # echo "$foldername" | tr '[:punct:]' '_' }
	echo $foldernamenospace
    }
function getFileExtension()
{
    extension1=${1##*.}
    extension=${extension1,,} #convert to all lower case
    echo "$extension"
}
function getFileName()
{
    filename=${1%.*}
    echo "$filename"
}
function convertArchivesIntoWebpageDirectory()
{
    imagesPerPage=$1
    archive="${2}"
    foldernamenospace=$3 #( createDirectoryForWebcomic "${2}" )
    
    if [[ 1 -eq 0 ]]
    then
	echo "----------- WTF 1 = 0 ----------------------------------------"
    #echo "variable 2:${2}"
	foldernamenospace=$( convertFoldername "${2}" )
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html                                               
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern which specifies spaces.         
	if [ !  -e "$foldernamenospace" ]
	then
            echo "creating $foldernamenospace directory" 
            mkdir "$foldernamenospace" #create folder if doesn't exist                      
	fi
    fi
    
    extension=$( getFileExtension "${2}" )
    echo "$extension"	
    if [ "$extension" = "cbr" ]
    then
	echo "CBR file"
	unrar e "${2}" -d "$foldernamenospace" 2>> /tmp/DecompressErrorLog.txt # if the directory doesn't exist unrar will skip extracting the files
    else #assume that its cbz
	olddir=$( pwd )
	echo "$pwd"
	echo "CBZ file"
	unzip "${2}" -d /tmp/Comic 2>> /tmp/DecompressErrorLog.txt  #send stderr to log
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
}

function RecurseDirs()
{   
    depth=$1
    numberOfImagesPerPage=$2 
    wideformat=$3
    deletearchives=$4
    unrarunzip=$5
    echo $depth $numberOfImagesPerPage $wideformat $deletearchives $unrarzip 
    echo "1:==$1"
#    if [ "${1}" -eq "" ]
    if [ "" != "$1" ]
    then
        depth=0
    fi
    depth=$1
    let 'depth+=1'
    echo "$depth"


#this is placed before so that the directories it makes are recursed into. otherwise they aren't traveresed.
    if [[ 1 -eq $unrarzip ]]
    then
	UnrarUnzip $deletearchives
    fi

    for dir in *
    do
        if [ -d "$dir" ]
        then
            cd "$dir"
            echo -n "entered:"
            pwd
            RecurseDirs $depth $numberOfImagesPerPage $wideformat $deletearchives $unrarzip 
            echo -n "exiting:"
            pwd
            cd ..
        fi
    done
    


    for item in *.[Cc][Bb][RrZz]
    do
	if [ -f "${item}" ]
	then
	    echo "--$item--"
	    Operations $numberOfImagesPerPage "${item}" $wideformat $deletearchives
	fi
    done
    
#    echo "Do stuff here $depth"
    let 'depth-=1'
}

function decompressRARZIPArchivesIntoDirectory()
{

    foldernamenospace=$( convertFoldername "${1}" )
#https://www.gnu.org/software/bash/manual/html_node/Shell-Parameter-Expansion.html                                                   
# ${parameter/pattern/string} -->then I use the % to match at the end of 'parameter' and since string is empty we remove the pattern\
 which specifies spaces.                                                                                                             

 if [ !  -e "$foldernamenospace" ]
 then
     echo "creating $foldernamenospace directory"
     mkdir "$foldernamenospace" #create folder if doesn't exist                                                               
 fi



 extension=$( getFileExtension "${1}" )
 echo "$extension"   #is there a way we could use mime types to handle the files and the app to launch?
 if [ "$extension" = "rar" ]
 then
     echo "RAR file"
     unrar e "$1" -d "$foldernamenospace" 2>> /tmp/DecompressErrorLog.txt # if the directory doesn't exist unrar will skip extracting the files
 else #assume that its cbz                                                                                                                
     olddir=$( pwd )
     echo "$pwd"
     echo "ZIP file"
     unzip "$1" -d /tmp/Comic 2>> /tmp/DecompressErrorLog.txt  #send stderr to log                                            
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
			    extension=$( getFileExtension "${imagenospaces}" )
			    filename=$( getFileName "${imagenospaces}" )
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
	directory="${2}"
	echo "pageformat $pageformat; directory $directory"
		
	echo "Moving into $directory"
	cd "$directory"
	
	echo "creating webpage"
	HTMLpage="0000Webpage.html" #use this filename so it will be close to the top
	echo "<html><body><title>$directory</title>" > $HTMLpage
	echo "<h5>$directory</h5>" >> $HTMLpage
	for image in *.[jJ][Pp][Gg] *.[Gg][Ii][fF] *.[Pp][Nn][Gg]
	do 
	    if [ -f "$image" ] #prevents output when isn't a file; ie. catches when no images of one of the categories
	    then
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
	
	
	echo "Leaving directory $directory"
	cd ..

    }

    function convertImages()
    {
	pageformat=$1
	directory=$2
	echo "pageformat $pageformat; directory $directory"
	echo "Moving into directory $directory"
	cd "$directory"
	pwd

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

	echo "Leaving directory $directory"
	cd ..
	
    }

function deleteArchive()
{
#remove the archive
    echo "deletearchive:$1--$2--"
    if [[ $1 -eq 1 ]]
    then
	echo "deleting ${2}"
	rm "${2}"
    fi
}

function UnrarUnzip()
{
    deletearchive=$1
    for item in *.[RrZz][IiAa][RrPp]
    do
##uhhh why not just have one function for rars and one for zips? that would be waay better and would remove the need to determine file type by looking at the file extension. for item in *.zip; do if [ -f $item ] then unzip/rar
	
	if [ -f "${item}" ]
	then
	    DiskStatus=$( checkFileSpace "${item}" )
	    if [[ $DiskStatus -eq 1 ]]
	    then
		decompressRARZIPArchivesIntoDirectory  "${item}"  
		echo "unrarzip-$deletearchive-${item}"
		deleteArchive $deletearchive "${item}"
	    fi
	fi
    done
}

function Operations()
{
#perform disk check
numberOfImagesPerPage=$1 
item=$2
wideformat=$3
deletearchive=$4
DiskStatus=$( checkFileSpace "${item}" )
if [[ $DiskStatus -eq 1 ]]
then
    directory=$( createDirectoryForWebcomic "${item}" ) #convertFoldername "${item}" )
    convertArchivesIntoWebpageDirectory $numberOfImagesPerPage "${item}" "$directory"
    convertImages $wideformat $directory
    splitcomic=$( splitLargeComicsHTML $directory )
    if [[ 0 -eq $splitcomic ]]
    then  #only do createHTML if the comic wasnt split
	createHtml $wideformat $directory
    fi
    deleteArchive $deletearchive "${item}"
else
    echo "There is not enough space for extraction and manipulation of ${item}."
fi
}




######################
##Begin Script
######################
echo "This is a simple script to automate the Mangle  (Manga-Kindle) app."

numberOfImagesPerPage=5
wideformat=0
deletearchives=0
unrarzip=0
recursive=0
while getopts ":n:whdur" OPTIONS 
do
    case ${OPTIONS} in 
	n|-numberofimagesperpage) echo "numperpage ${OPTARG}"
	    numberOfImagesPerPage=${OPTARG};;
	w|-fullwidth) echo "fullwidth" #on the BPDN we'd flip it on side as the min dimension will be 800
	    wideformat=1;;
	h|-fullheight) echo "fullheight" #on the BPDN we'd flip it on side as the min dimension will be 600
	    wideformat=0;;
	d|-deletearchives) echo "delete archives after extracting" 
	    deletearchives=1;;
	u|-unrarzip) echo "Extracting Rar and Zip archives" 
	    unrarzip=1;;
	r|-recursive) echo "Running recursively on directories" 
	    recursive=1;; #this negates running only on the files specified
    esac
done
#echo $numberOfImagesPerPage
shift $(($OPTIND - 1)) 
# Decrements the argument pointer so it points to next argument.
# $1 now references the first non-option item supplied on the command-line
#+ if one exists.


if [[ 1 -eq $recursive ]]
then
    RecurseDirs 0 $numberOfImagesPerPage $wideformat $deletearchives $unrarzip 
else

    Number_Of_Expected_Args=1
    if [ $# -lt $Number_Of_Expected_Args ]
then 
    echo "Usage: script archive archive ...."
    echo "acting on all cbr/cbz files in this directory"
    if [[ 1 -eq $unrarzip ]]
    then
	UnrarUnzip $deletearchive
    fi
    for item in *.[Cc][Bb][RrZz]
    do
	if [ -f "${item}" ]
	then
	    echo "--$item--"
	    Operations $numberOfImagesPerPage "${item}" $wideformat $deletearchives
	fi
    done
else
    until [ -z "$1" ] #loop through all arguments using shift to move through arguments
    do
	echo $1
	if [ -f "${1}" ]
	then
	    Operations $numberOfImagesPerPage "${1}" $wideformat $deletearchive
	fi
	shift
    done
fi

fi #end recurse check