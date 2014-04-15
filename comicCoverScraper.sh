#!/bin/bash

function determineArchiveType()
{
    flag=2 #0 for zip, 1 for rar, 2 for unknown
    filename="${1}"
    file_output=$( file -b "${filename}" | awk '{print $1}' )
    #flag=$file_output
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
    mytext="${1}"-"${2}"
    echo $mytext
#    convert "${1}" -background White -fill Black -font Courier -pointsize 24 label:"${mytext}" -gravity South -append comiccovers"${1}"
    convert "${1}" -background White -fill Black -font Courier -pointsize 24 label:"${2}" -gravity South -append _comiccovers"${1}"
}

function checkFilenameDoesntExist() {

imageToExtract="${1}"
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
echo "${imageToExtract}" #for a better way to return values to callers http://www.linuxjournal.com/content/return-values-bash-functions
}

function extractFirstImageFromArchive() 
{
#we need to check if the file we are about to extract to all ready exists and if so to rename it.
    if [ $1 -eq 0 ]
    then #Zip 
	imageToExtract=$( unzip -Z -1 "${2}" | sed '1!d' )
#	checkFilenameDoesntExist "${imageToExtract}"  fuck since we 'return' things from this function, the 'return' eats  the dialog....damnit.
	b=$( unzip "${2}" "${imageToExtract}" )
    fi
    if [ $1 -eq 1 ] 
    then #Rar
	imageToExtract=$( unrar lb "${2}" | sed '1!d' )
#	checkFilenameDoesntExist "${imageToExtract}"
	b=$( unrar e "${2}" "${imageToExtract}" )
    fi
    echo "${imageToExtract}"
}

# filelist=$( find . -name "*.[Cc][Bb][RrZz]" -print0 | split  )
# for ((i=0;i<${#filelist[@]};i++))
# do
#     echo $i
#     echo ${filelist[${i}]} 
#     #archiveType=$( determineArchiveType ${filelist[${i}]} )
#     #echo $archiveType
#     #imageName=$( extractFirstImageFromArchive ${archiveType}  ${filelist[${i}]} )
#     #mv "${imageName}"  comiccovers_"${imageName}" 
# done

if [ 1 -eq 0 ]
then
    #for i in `find . -type f -name "*.[Cc][Bb][RrZz]" ` #-print0` #*.cbz
    for i in *.cbz
    do 
	echo "${i}"
	archiveType=$( determineArchiveType "${i}" )
	echo $archiveType
	imageName=$( extractFirstImageFromArchive ${archiveType}  "${i}" )
	echo ${imageName}
	addArchiveLabelToImage "${imageName}" "${i}" 
	#    mv "${imageName}"  comiccovers_"${imageName}" 
    done

    zip ComicCovers _comiccovers*.*
    mv ComicCovers.zip ComicCovers.cbz
    evince ComicCovers.cbz
    # rar wtf rar is only in the AUR
fi


#from: http://stackoverflow.com/questions/1116992/capturing-output-of-find-print0-into-a-bash-array
unset a i
while IFS= read -r -d $'\0' file; do
    echo "$file"        # or however you want to process each file
	archiveType=$( determineArchiveType "${file}" )
	echo $archiveType
	imageName=$( extractFirstImageFromArchive ${archiveType}  "${file}" )
	echo ${imageName}
	addArchiveLabelToImage "${imageName}" "${file}" 

done < <(find . -type f -name "*.[Cc][Bb][RrZz]" -print0)
