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

function extractFirstImageFromArchive() 
{
    if [ $1 -eq 0 ]
    then #Zip 
	imageToExtract=$( unzip -Z -1 "${2}" | sed '1!d' )
	b=$( unzip "${2}" "${imageToExtract}" )
    fi
    if [ $1 -eq 1 ] 
    then #Rar
	imageToExtract=$( unrar lb "${2}" | sed '1!d' )
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
