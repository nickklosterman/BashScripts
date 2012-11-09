#!/usr/bin/python

#This script is used to grab the images in rss feeds. Feeds are read from a file. The file specifies the url and the temp file to use.
#The description tag of each post is used as the unique identifier.

#compare two lists of images and output the newest images not in the older set(from file)
# if imagelist=[ a b ] and imagelistfromfile = [b c d e] then outputlist=[a] , we use the break to prevent d,e from being in outputlist
def CompareImageLists(imagelist,imagelistfromfile):
    outputlist=[]
    if imagelist and imagelistfromfile:
        for item in imagelist:
            if item not in imagelistfromfile:
                outputlist.append(item)
            else:
                break 
    else:
        outputlist=imagelistfromfile
    return outputlist

# here we grab all the images, preventing duplicates such as icons and avatars, and write them to the temp file for the rss feed , but with _images appended to the filename 
def WriteImageListToFileFromDescription(descriptionfile,descriptionlist):
    imagelist=[]
    if descriptionlist or not descriptionlist==None:
        imagefile=os.path.dirname(os.path.expanduser(descriptionfile))+"/"+os.path.splitext(os.path.basename(os.path.expanduser(descriptionfile)))[0]+"_images"
        print('Writing %s' % imagefile)
        filehandle=open(imagefile,"w")
        for item in descriptionlist:
            soup = BeautifulSoup(item) #when I was passing the items to a function for the images to be stripped, things weren't working
            images=soup.find_all("img")
            for image in images:
                if image.get("src") not in imagelist: #prevent duplicates from being added to our list
                    imagelist.append(image.get("src"))
        for img in imagelist: # output:
            filehandle.write(img+'\n')
        filehandle.close

# Write out the descriptions to file
def WriteDescriptionListToFile(file,list):
    if list or not list==None:
        print('Writing %s' % os.path.expanduser(file))
        filehandle=open(os.path.expanduser(file),"w")
        for item in list:
            filehandle.write(item+'\n')
        filehandle.close

#Compare the description tags from the file and from the recently obtained feed.
def CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlist,descriptionfile):
    outputdescriptionlist=[]
    if os.path.isfile(descriptionfile):
        filehandle=open(descriptionfile,'r')
        descriptionlistfromfile=[]
        for line in filehandle:
            line_=line.strip(' \t\r\n') #strip whitespace
            if len(line_)>1 and line_[0]!='#': #skip comment lines
                descriptionlistfromfile.append(line_)
        outputdescriptionlist=CompareImageLists(descriptionlist,descriptionlistfromfile)
    #if there isn't a file to read we output the list from the rss feed 
    if not outputdescriptionlist:
        outputdescriptionlist=descriptionlist
    WriteDescriptionListToFile(descriptionfile,outputdescriptionlist)
    WriteImageListToFileFromDescription(descriptionfile,outputdescriptionlist)

def GetDescriptionListFromFeed(feed):
    d=feedparser.parse(feed)
    descriptionlist=[]
    if (len(d.entries) > 0):
        for index in range(len(d.entries)):
            rss_post_description=d.entries[index].get('description','uh oh no descrip')
            descriptionlist.append(rss_post_description)
    return descriptionlist

# used to create a long string instead of newline separated images for input to feh
def FileToString(imagefile):
    imagelistfromfile=""
    if os.path.isfile(imagefile):
        filehandle=open(imagefile,'r')
        for line in filehandle:
            line_=line.strip(' \t\r\n') #strip whitespace
            if len(line_)>1 and line_[0]!='#': #skip comment lines
                imagelistfromfile=imagelistfromfile+" "+line_
    print(imagelistfromfile)
    return imagelistfromfile        

#for removing duplicates:
# http://docs.python.org/2/faq/programming.html#how-do-you-remove-duplicates-from-a-list
#
# CheckFeedFileForDuplicates(feedList): Parse a file and look for duplicate temporary filenames. This is a sanity check to make sure that two RSS feeds aren't trying to write to the same file and therefore causing problems. 
def CheckFeedFileForDuplicates(feedList):
    uniqueList = []
    uniqueListTempFiles = []
    duplicateList = []
    for value in feedList:
        if value[1] not in uniqueListTempFiles:
            uniqueList.append(value)
            uniqueListTempFiles.append(value[1])
        else:
            duplicateList.append(value)
    if len(duplicateList)>0:
        print("You are using a temp file more than once. Here is a list of the second occurrence with its url.")
        print(duplicateList)
    return uniqueList #duplicateList

#read our rss feed file and create a list with the contents.
def ParseFeedFile(feedfile):
    filehandle=open(feedfile,'r')
    feedtmpfilelist=[]
    for line in filehandle:
        line_=line.strip(' \t\r\n') #strip whitespace
        if len(line_)>1 and line_[0]!='#': #skip comment lines
            feedtmpfilelist.append(line_.split(',')) 
    return feedtmpfilelist

#check the feed list for existence of files. 
def CheckFeedList(feedlist):
    for item in feedlist:
        if os.path.isfile(item[1]):
            print("This file exists:%s" % (item[1]))
        else:
            print("This file DOESN'T exist:%s" % (item[1]))
                      
import os.path,sys
import subprocess

import feedparser
from bs4 import BeautifulSoup


if len(sys.argv)>1 and  sys.argv[1]!="":
    feedfile=sys.argv[1]
    feedandtempfilelist=ParseFeedFile(feedfile)
    nonDupList=CheckFeedFileForDuplicates(feedandtempfilelist)
    print(nonDupList)
    for feed in nonDupList:
        print('--------%s-------' % (feed[0]))
        descriptionlist=GetDescriptionListFromFeed(feed[0])
        outputimagelist=CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlist,os.path.expanduser(feed[1]))




