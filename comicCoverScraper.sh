#!/bin/bash
#This is a script to crawl and extract the first image from all found .cbr .cbz files and to create an index cbr of all the extracted cover images

function determineArchiveType()
{
    flag=-1 #0 for zip, 1 for rar, 2 for ace
    filename="${1}"
    file_output=$( file -b "${filename}" | awk '{print $1}' )
    flag=$file_output
    case  "${file_output}" in
	"Zip")
	    flag=0
	    ;;
	"RAR")
	    flag=1
	    ;;

	"ACE")
	    flag=-2 #I've seen ACE as cbrs. and I don't know how to handle them since their list isn't easily parseable.
	    ;;
    esac

    echo "${flag}"
}

function addArchiveLabelToImage() {
    #1=filename 2=archive
    mytext="${1}"-"${2}"
    outputfile=_comic"${2##*/}".jpg #this was using the filename, now use the archive as that is a better filename, file extensions are for humans and less for the machine so having an image filename as X.cb{r|z} doesn't really matter since it will be hidden in the resultant cb[rz] file....errr it seems evince doesn't like it without proper image filenames
    
    echo "addArchiveLabelToImage:" $mytext " -filename:" "${1}" " -archive" "${2}"

#deal with asshats who name files starting with a dash. Fucktards.
    if [[ ${str:0:1} == "-" ]] 
    then 
	echo "c here"
	convert "./${1}" -resize 1600x1200 -background White -fill Black -font Courier -pointsize 24 label:"${2}" -gravity South -append "${outputfile}" 2>> errorlog.txt
	rm "./${1}" #hmm performing rm seems risk, yet is needed.
    else
	echo "c no here"
	convert "${1}" -resize 1600x1200 -background White -fill Black -font Courier -pointsize 24 label:"${2}" -gravity South -append "${outputfile}" 2>> errorlog.txt
	rm "${1}" #hmm performing rm seems risk, yet is needed.
	
    fi
}


####
##  Currently not used
####
function checkFilenameDoesntExist() {

    imageToExtract=_comic"${1}" #since we are converting the image
    if [ -e "${imageToExtract}" ]
    then
	echo "uh oh, file all ready exists"
	read key
    fi
    counter=1
    temp="${imageToExtract}"
    while [ -e "${imageToExtract}" ]
    do 
	extension=${imageToExtract##*.}
	filename=${imageToExtract%.*}
	number=$( printf "%03d" $counter )
	imageToExtract="${filename}${number}.${extension}"
	let 'counter+=1'
    done
    mv "${1}" "${imageToExtract}"
    #echo "${imageToExtract}" #for a better way to return values to callers http://www.linuxjournal.com/content/return-values-bash-functions
}


function extractImageFromArchive() 
{
    imageToExtract="${3}"
    echo "extractImageFromArchive:${3}"

#we use the `b` variable to caputre output.  I imagine I should be piping stdout and stderr to someplace useful instead of doing this. 
    case  "$1" in
	0)
	    #Zip 
	    b=$( unzip -o -j "${2}" "${imageToExtract}" ) #-o to overwrite so we aren't prompted; -j junk the path so all contents are dumped locally
	    ;;
	1)
	    
	    #Rar
	    #b=$( unrar -o+ e "${2}" "${imageToExtract}" )#force overwriting of exisitng files

#deal with those asshats that name files with an initial dash. May they all rot in hell. 
	    if [[ ${str:0:1} == "-" ]]  # http://stackoverflow.com/questions/18488270/how-to-check-the-first-character-in-a-string-in-unix
	    then 
#http://stackoverflow.com/questions/29572756/unrar-file-from-archive-that-starts-with-a-dash/29572757#29572757
		b=$( unrar e -y "${2}" -- "${imageToExtract}" ) 
#		 unrar e  "${2}" -- "${imageToExtract}" 
	    else 
		b=$( unrar e -y "${2}" -- "${imageToExtract}" ) #assume yes on questions (overwrites...and who knows what else)
	    fi
	    ;;
	2)
	    b=$( unace e "${2}" "${imageToExtract}" )
	    ;;
	*)
	    ;;
    esac
}

function getImageName()
{
    counter=1 #used to determine which image to grab. Here we assume the cover is the first image. 
    imageToExtract=""
    while [ "${imageToExtract}" == "" ] 
    do
	#	echo "${counter}"
	case "$1" in
	    0)
		#Zip 
#archiveListing=$( unzip -Z -1 "${2}" | sort )
		unzip -t -qq "${2}" > /dev/null 2>& 1 # test the archive # there was a problem where the archive was identified but failed this test. The error was sent to stdout which was caught by the function imageName=( ) which was breaking my check for UnZipTestFailure
		exitCode=$?

		if [ $exitCode -eq 0 ] #if the test ran and exited fine, proceed
		then 
#echo "hereyo"
#for performance I should save off the sorted file list
		    imageToExtract=$( unzip -Z -1 "${2}" | grep -i 'jpg\|png\|gif\|jpeg' | sort | sed "${counter}!d" ) #run the filelist through 'sort' to put the files in order. Use the fact that the scanner image is typically the last image if present.
	#	    imageToExtract=$( echo ${archiveListing} | sed "${counter}!d" ) #run the filelist through 'sort' to put the files in order. Use the fact that the scanner image is typically the last image if present.
		    unzip -Z -1 "${2}" >> filelist.txt
		    # echo "${2} : $imageToExtract" >> imageExtract.txt 
		else
		    imageToExtract="UnZipTestFailure"
		    echo "${2} :${imageToExtract}: $exitCode" >> imageExtractFail.txt
		    # return $imageToExtract
#echo "fail extract"
		    echo -n "$imageToExtract"  #echo our value....
		    return 0 #.. and fire off our return code
		fi
		;;
	    1) #Rar
#rar is shitty in that it doesn't nicely list the full path with the file to be extracted. 
#we use the verbose listing, just grab the lines with image extensions, ignoring case, sort, use sed to only print one line and due to unrar's shitty output we have to strip the leading space otherwise when we pass the string in as the filename it will fail bc the leading space will be respected as if it was part of the filename
		imageToExtract=$( unrar v "${2}" | grep -i 'jpg\|png\|gif\|jpeg' | sort | sed "${counter}!d;s/^[[:space:]]//" ) #run the filelist through 'sort' to put the files in order. Use the fact that the scanner image is typically the last image if present.
#echo ${imageToExtract}
#		imageToExtract=$( unrar lb "${2}" | sort | sed "${counter}!d" ) #run the filelist through 'sort' to put the files in order. Use the fact that the scanner image is typically the last image if present.
		unrar lb "${2}" >> filelist.txt
		;;
	    2) #Ace
		imageToExtract=$( unace l "${2}" | awk '{print $6}'|  sort | sed "${counter}!d" )
		;;
	    *)
		bill="bob" #unknown case
		;;
	esac
	extension_=${imageToExtract##*.} #get the extension
	extension=${extension_^^} #make it uppercase

	#if we found an "image" (really just a filename for extraction) then check to make sure it was an image; if it wasn't an image incrememnt the coutner and go round again
	if [ "${imageToExtract}" != "UnZipTestFailure" ]
	then 
	    if [ "${extension}" == "JPG" ] ||  [ "${extension}" == "PNG" ] || [ "${extension}" == "GIF" ] || [ "${extension}" == "JPEG" ]
	    then
		echo "${2} : $imageToExtract" >> imageExtract.txt 
		
	    else
		echo "fail: ${imageToExtract} ext:${extension}"
		imageToExtract="" # reset this so we stay in the loop
		let 'counter+=1'
	    fi

	    #this is used to prevent us from being stuck in an inf loop when the archive is bad 
	    # if [ $counter -gt 4 ]
	    # then
	    # 	imageToExtract="UnZipTestFailure"
	    # fi
	fi
    done	

    #if we use return, we can't call this function inside a foo=( ); we need to call it on its own and just examine the exit code $?
    # return "UnZipTestFailure" return values must be numeric!!

    #previously not suppressing the newline was I believe screwing up the comparison of the rturned value to a string bc teh strin gdidn't have the \n in it, so it was failing.
    echo  -n "${imageToExtract}"  #despite above comment, not sure suppressing newline needed
}

####
##  MAIN
####

#check if specified a output filename on command line

if [ -e CoverImages.cbz  ]
then
    echo "A CoverImages.cbz already exists."
    echo "Would you like to overwrite it? (y/n)"
#http://www.tldp.org/LDP/Bash-Beginners-Guide/html/sect_08_02.html
    read -n 1 response
    while [ "$response" != "y" ] && [ "$response" != "n" ] 
    do
	echo "please enter y/n"
	read -n 1 response
    done
    if [ "$response" == 'n' ] 
    then 
	exit 1
    else 
	rm CoverImages.cbz
    fi
fi

OIFS="$IFS" #needed for the processing of files with spaces in them
IFS=$'\n'

#from: http://stackoverflow.com/questions/1116992/capturing-output-of-find-print0-into-a-bash-array
unset a i
while IFS= read -r -d $'\0' file; do
    echo "$file"   #file is the archive file we are operating on      # or however you want to process each file
    archiveType=$( determineArchiveType "${file}" )
    echo "$file archive Type: $archiveType"

    re='^[0-9]+$'
    if [[ $archiveType =~ $re ]] 
    then #make sure the archiveType returned a number otherwise throw error
	if [ $archiveType -gt -1 ] 
	then
	    getImageName ${archiveType}  "${file}" #run it just to see the echo
	    imageName=$( getImageName ${archiveType}  "${file}" ) #old method using echo to return stuff
	    #echo "-----${file}:${imageName}=================="
	    if [[ "${imageName}" != "UnZipTestFailure" ]] 
	    then 
		echo  "ImageName to extract: ${imageName}"
		extractImageFromArchive ${archiveType}  "${file}" "${imageName}" 
		echo "${imageToExtract}"

		addArchiveLabelToImage "${imageName##*/}" "${file}" #pass in the filename that is stripped of the path. needed since we extract the files without path; I suppose if I didn't extract wo path then I wouldn't need to do this. 
	    else 
		echo "$file archive type identified but extraction failed"
	    fi
	fi
    else
	echo "Invalid archive type. Type was ${archiveType}"
    fi
    echo "------"
done < <(find . -type f -name "*.[Cc][Bb][RrZz]" -print0)

#having a known prefix helps us to prevent including unwanted images in our archive and in our rm'ing
zip CoverImages _comic*
rm _comic*
mv CoverImages.zip CoverImages.cbz

IFS="$OIFS"

echo "In Evince, have the image highlighted in the left sidebar and use the arrow keys. This will keep the image scrolling nicely such that it is always at the top and on screen"

#switch to turn off IM convert/mogrify calls
#switch to progressively zip (i.e. zip after each extraction vs zip after all extractions, i.e. for disk space limited systems.
#perform du check