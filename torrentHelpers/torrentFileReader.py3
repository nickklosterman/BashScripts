#!/bin/python2

# http://effbot.org/zone/bencode.htm
# http://stackoverflow.com/questions/406695/reading-the-fileset-from-a-torrent 

# http://www.bittorrent.org/beps/bep_0003.html#metainfo-files-are-bencoded-dictionaries-with-the-following-keys
import re
import sys
import glob 
import os #os.path.getsize
import shutil #docs.python.org/3.3/library/shutil.html

import bencode

def getFileDict():
    fileDict={}    
    try:
        for root, subFolders, files in os.walk("."):
            for file in files:
                fileDict[file]=os.path.getsize(os.path.join(root,file)) 
    except (AttributeError, ValueError, StopIteration):
        raise SyntaxError("syntax error") 
    return fileDict
        
#http://stackoverflow.com/questions/273192/check-if-a-directory-exists-and-create-it-if-necessary
import os
import errno


def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise


if __name__ == "__main__":
    #    fileList= glob.glob('/home/puffjay/Remote/BBB/Remote/SGOne/C3*.meta')

    fileList= glob.glob('*.meta')
    directoryFileDict=getFileDict()    
    completedTorrentFiles="completedTorrentFiles"
    incompleteTorrentFiles="incompleteTorrentFiles"
    make_sure_path_exists(completedTorrentFiles)
    make_sure_path_exists(incompleteTorrentFiles)
    
    for metafilename in fileList:
        #print(metafilename)
        if os.path.getsize(metafilename)>0 and os.path.getsize(metafilename)<2000000: #filter out the bad ones
            data = open(metafilename, "rb").read()
            torrent = bencode.decode(data)
            errorFlag=False
            BadFiles=[]
            #it appears that .meta files don't have the "info" field
            # for k in torrent:
            #     print(k)
            if False:
                if "info" in torrent and "files" in torrent["info"]:
                    for file in torrent["info"]["files"]:
                        print("%r - %d bytes" % ("/".join(file["path"]), file["length"]))
                    else:
                        print(torrent["name"])
            elif True:
                if "files" in torrent[0]: #multi file case
                    for file in torrent[0][b"files"]:
                        #print(file) #two fields path and length
                        #print("%r - %d bytes" % ("/".join(file["path"]), file["length"]))
                        #print(os.path.basename("/".join(file["path"])))
                        filename=os.path.basename("/".join(file["path"]))
                        if filename in directoryFileDict:
                            if directoryFileDict[filename]!=file["length"]:
                                errorFlag=True
                                t=filename,directoryFileDict[filename],file["length"]
                                BadFiles.append(t )
                                #BadFiles.append(filename,directoryFileDict[filename],file["length"])
                        else:
                            errorFlag=True
                            BadFiles.append(filename)
                else: #single file case
                    #print(torrent["name"],torrent["length"])
                    filename=torrent[0][b"name"]
                    if torrent[0][b"name"] in directoryFileDict:
                        if directoryFileDict[torrent[0][b"name"]]!=torrent[0][b"length"]:
                            errorFlag=True
                            t=filename,directoryFileDict[filename],file["length"]
                            BadFiles.append(t )
                    else:
                        errorFlag=True
                        BadFiles.append(filename)

                if errorFlag==False:
                    print("AllGood: %s" % (metafilename))
                    shutil.copy2(metafilename,completedTorrentFiles+"/"+metafilename)
                if errorFlag==True:
                    print(":( : %s " % (metafilename))
                    shutil.copy2(metafilename,incompleteTorrentFiles+"/"+metafilename)
                    for item in BadFiles:
                        print(item)

# build a directory listing of the full path and the file size
# for each metafile 
# badFlag=False 
# for each file
# if file found in 
# check for file size match
# if file size match, remove from directory listing
# if not found or file size mismatch set bad flag to true, output/append list if not found or size mimatch
# if end of metafile and badflag ==False, mark as deletable/complete or actually  move to torrent complete folder

# create a dictionary where the key is the file size. 
