#!/bin/bash
#requires that two directories be provided.
#will then remove any file from directory X that isn't also in directory Y
#Originally written for a image directory and a thumbnail directory (as a child directory for simplicity). Allowed quickly going through the thumbnail directory and selecting files for deletion. Then having the deleted files from the thumbnail direcotry mirrored in the parent directory as well.
#the files in both directories should be named the same  for this to work. So create a thumbnail directory. copy all files into the thumbnail directory, then run mogrify on the files to create thumbnails.

if [ $# -lt 2 ]
then
    echo "Two directories are needed for execution of this script."
    echo "Files from TargetPath that aren't in ThumbnailPath will be deleted."
    echo "scriptname.sh TargetPath ThumbnailPath"
else
    TargetPath=${1}
    ThumbnailPath=${2}
    TargetPathList=`mktemp`
    ThumbnailPathList=`mktemp`
    FilesToDelete=`mktemp`
    echo ${TargetPathList} ${ThumbnailPathList} ${FilesToDelete}
    
    ls $1 > ${TargetPathList}
    ls $2 > ${ThumbnailPathList}
    
    grep -v -f ${ThumbnailPathList} ${TargetPathList} > ${FilesToDelete}
    echo "These are the files to be deleted:"
    #cat ${FilesToDelete}
    while read Line 
    do 
	FilenameWithPath=${TargetPath}${Line} #add path to file just in case the script isn't executed from image directory 
#BE CAREFUL: we only have as much of the path that is provided. We might get in trouble if the full path is needed or we leave out a slash
	if [ -f ${FilenameWithPath} ] 
	then 
	    if [ ! -d ${FilenameWithPath} ] #suppress trying to delete directories
	    then 
		echo ${Line} ${FilenameWithPath}
		rm ${FilenameWithPath}
	    fi
	fi
    done < ${FilesToDelete}
fi