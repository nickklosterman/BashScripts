#!/bin/bash
#This is a script to crawl and extract the first image from all found .cbr .cbz files and to create an index cbr of all the extracted cover images

function determineArchiveType()
{
    flag=2 #0 for zip, 1 for rar, 2 for unknown
    filename="${1}"
    file_output=$( file -b "${filename}" | awk '{print $1}' )
    flag=$file_output
    if [ "${file_output}" == "Zip" ]
    then
	flag=0
    elif [ "${file_output}" == "RAR" ]
    then 
	flag=1
    fi
    echo "${flag}"
}

function addArchiveLabelToImage() {
#1=filename 2=archive
    mytext="${1}"-"${2}"
    outputfile=_comic"${1}"
    echo $mytext
#    convert "${1}" -background White -fill Black -font Courier -pointsize 24 label:"${mytext}" -gravity South -append comiccovers"${1}"
#    convert "${1}" -background White -fill Black -font Courier -pointsize 24 label:"${2}" -gravity South -append _comiccovers"${1}"
    convert "${1}" -background White -fill Black -font Courier -pointsize 24 label:"${2}" -gravity South -append "${outputfile}" 2>> errorlog.txt
    #rm "${1}" hmm performing rm seems risk, yet is needed.
}

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
    if [ $1 -eq 0 ]
    then #Zip 
	b=$( unzip "${2}" "${imageToExtract}" )
    fi
    if [ $1 -eq 1 ] 
    then #Rar
	b=$( unrar e "${2}" "${imageToExtract}" )
    fi
}

function getImageName()
{
    counter=1
    imageToExtract=""
    while [ "${imageToExtract}" = "" ]
    do
#	echo "${counter}"
	if [ $1 -eq 0 ]
	then #Zip 
	    imageToExtract=$( unzip -Z -1 "${2}" | sed "${counter}!d" )
	    unzip -Z -1 "${2}" >> filelist.txt
	fi
	if [ $1 -eq 1 ] 
	then #Rar
	    imageToExtract=$( unrar lb "${2}" | sed "${counter}!d" )
	    unrar lb "${2}" >> filelist.txt
	fi
	extension_=${imageToExtract##*.}
	extension=${extension_^^}
	
	if [ "${extension}" = "JPG" ] ||  [ "${extension}" = "PNG" ] || [ "${extension}" = "GIF" ] || [ "${extension}" = "JPEG" ]
	then
	    bill="bob"
	else
#	    echo "fail: ${imageToExtract} ext:${extension}"
	    imageToExtract=""
	    let 'counter+=1'
	fi
   done	
#	echo "fail: ${imageToExtract} ext:${extension}"
    echo "${imageToExtract}"
}


#from: http://stackoverflow.com/questions/1116992/capturing-output-of-find-print0-into-a-bash-array
unset a i
while IFS= read -r -d $'\0' file; do
    echo "$file"        # or however you want to process each file
	archiveType=$( determineArchiveType "${file}" )
	echo $archiveType
	if [ $archiveType -eq 1 ] || [ $archiveType -eq 0 ] 
	then
#	imageName=$( extractFirstImageFromArchive ${archiveType}  "${file}" )
	imageName=$( getImageName ${archiveType}  "${file}" )
#	echo ${imageName}
#	extractImageFromArchive ${archiveType}  "${file}" "${imageName}" 
#	addArchiveLabelToImage "${imageName}" "${file}" 
	else 
	    echo "$file not identifed as rar or zip: ${archiveType}"
	fi
done < <(find . -type f -name "*.[Cc][Bb][RrZz]" -print0)
#zip CoverImages *.png #*.jpg *.png *.gif *.JPG *.PNG *.GIF *.JPEG
zip CoverImages _comic*
#rm *.jpg *.png *.gif *.JPG *.PNG *.GIF *.JPEG We don't want to do this unless we know we are working in a temp directory or we could blow away images we want
mv CoverImages.zip CoverImages.cbz

