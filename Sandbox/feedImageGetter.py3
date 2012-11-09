#!/usr/bin/python

#compare two lists of images and output the newest images not in the older set(from file)
# if imagelist=[ a b ] and imagelistfromfile = [b c d e] then outputlist=[a] , we use the break to prevent d,e from being in outputlist
def CompareImageLists(imagelist,imagelistfromfile):
    outputlist=[]
    if imagelist:
        print("iamgelist not empty")
    if imagelistfromfile:
        print("imagelistfromfile not empty")
    if imagelist and imagelistfromfile:
        for item in imagelist:
            if item not in imagelistfromfile:
                #print('adding:%s' % item)
                outputlist.append(item)
            else:
#                print('quitting on :%s' % item)
                break #does this break out of the for loop? yeah it should 
    else:
        outputlist=imagelistfromfile
    return outputlist

def CompareImageListFromFeedToImageListFromFile(imagelist,imagefile):
    outputimagelist=[]
    if os.path.isfile(imagefile):
        filehandle=open(imagefile,'r')
        imagelistfromfile=[]
        for line in filehandle:
            line_=line.strip(' \t\r\n') #strip whitespace
            if len(line_)>1 and line_[0]!='#': #skip comment lines
                imagelistfromfile.append(line_)
        outputimagelist=CompareImageLists(imagelist,imagelistfromfile)
        #print(outputimagelist)
    #if there isn't a file to read we output the list from the rss feed 
    if not outputimagelist:
        outputimagelist=imagelist
#    WriteDescriptionListToFile(descriptionfile,outputdescriptionlist)
    WriteImageListToFile(imagefile,outputimagelist)

def WriteImageListToFile(imagefile,imagelist):
    #print("%s-%s-" % (imagelist,imagefile))
    if imagelist or not imagelist==None:
        print('Writing %s' % os.path.expanduser(imagefile))
        filehandle=open(os.path.expanduser(imagefile),"w")
        print(os.path.splitext(os.path.basename(os.path.expanduser(imagefile)))[0])
        for item in imagelist:
            filehandle.write(item+'\n')
        filehandle.close

def WriteImageListToFileFromDescription(descriptionfile,descriptionlist):
    #print("%s-%s-" % (imagelist,imagefile))
    imagelist=[]
    if descriptionlist or not descriptionlist==None:
        imagefile=os.path.dirname(os.path.expanduser(descriptionfile))+"/"+os.path.splitext(os.path.basename(os.path.expanduser(descriptionfile)))[0]+"_images"
        print('Writing %s' % imagefile)
        filehandle=open(imagefile,"w")
#        print("descriptionlist:%s" % descriptionlist)
        for item in descriptionlist:
#            print("item:%s" % item) 
            soup = BeautifulSoup(item) #when I was passing the items to a function for the images to be stripped, things weren't working
            images=soup.find_all("img")
 #           print("images:%s" % images)
            for image in images:
  #              print("itemz:%s" % itemz)
                if image.get("src") not in imagelist: #prevent duplicates from being added to our list
                    imagelist.append(image.get("src"))
        for img in imagelist: # output:
    #            print("image:%s" % img)
            filehandle.write(img+'\n')
        filehandle.close

def WriteDescriptionListToFile(file,list):
    #print("%s-%s-" % (imagelist,imagefile))
    if list or not list==None:
        print('Writing %s' % os.path.expanduser(file))
        filehandle=open(os.path.expanduser(file),"w")
        for item in list:
            filehandle.write(item+'\n')
        filehandle.close


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

def GetImageListFromFeed(feed):
    d=feedparser.parse(feed)
    print('feed length %i' % len(d.entries)) #   print(len(d.entries))
    if (len(d.entries) > 0):
        imagelist=[]
        for index in range(len(d.entries)):
            rss_post_description=d.entries[index].get('description','uh oh no descrip')
#            imagelist.append(rss_post_description)

            soup = BeautifulSoup(rss_post_description)
            images=soup.find_all("img")
            for item in images:
                if item.get("src") not in imagelist:
                    imagelist.append(item.get("src"))
#                print(item.get("src"))
    return imagelist

def GetDescriptionListFromFeed(feed):
    d=feedparser.parse(feed)
    print('feed length %i' % len(d.entries)) #   print(len(d.entries))
    if (len(d.entries) > 0):

        descriptionlist=[]
        for index in range(len(d.entries)):
            rss_post_description=d.entries[index].get('description','uh oh no descrip')
            descriptionlist.append(rss_post_description)
    return descriptionlist

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

def ParseFeedFile(feedfile):
    filehandle=open(feedfile,'r')
    feedtmpfilelist=[]
    for line in filehandle:
        line_=line.strip(' \t\r\n') #strip whitespace
        #print(line,line_t)
        if len(line_)>1 and line_[0]!='#': #skip comment lines
            feedtmpfilelist.append(line_.split(',')) 
#                feedtmpfilelist.append(line[:-1].split(',')) #[:-1] is used to strip off the newline at the end...this is actually redundant now as I didn't realize that you could add arguments to strip() to specify what is to be stripped out
    return feedtmpfilelist

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
rsslist=[ "http://skottieyoung.tumblr.com/rss",
          "http://mrjakeparker.com/feed/",
          "http://mrjakeparker.tumblr.com/rss",
          #"http://mrjakeparker.com/blog/" ],#this feed doesn't work.  
          # "https://twitter.com/mrjakeparker",
          # "http://www.facebook.com/jakeparkerart?ref=tn_tnmn",
          # "http://web.stagram.com/n/jakeparker/",
          "http://widget.stagram.com/rss/n/jakeparker/"]

filelist=["~/.RSS/skottieyoungtumblr",
          "~/.RSS/mrjakeparker",
          "~/.RSS/mrjakeparkertumblr",
          "~/.RSS/jakeparkerinstagram"
]

rssfilelist=[ 
    ["http://skottieyoung.tumblr.com/rss","~/.RSS/skottieyoungtumblr"],
    ["http://mrjakeparker.com/feed/",          "~/.RSS/mrjakeparker"],
    ["http://mrjakeparker.tumblr.com/rss",          "~/.RSS/mrjakeparkertumblr"],
    ["http://widget.stagram.com/rss/n/jakeparker/",          "~/.RSS/jakeparkerinstagram"]
]


if len(sys.argv)>1 and  sys.argv[1]!="":
    feedfile=sys.argv[1]
    feedandtempfilelist=ParseFeedFile(feedfile)
    print(feedandtempfilelist)
    CheckFeedList(feedandtempfilelist)
    nonDupList=CheckFeedFileForDuplicates(feedandtempfilelist)
    print(nonDupList)
    for feed in nonDupList:
        print('--------%s-------' % (feed[0]))
        descriptionlist=GetDescriptionListFromFeed(feed[0])
        outputimagelist=CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlist,os.path.expanduser(feed[1]))

#for some reason I can't get feh to load http from the file. :( it works on CLI but not from here. 
        commandstring="feh"
        optionsstring="-f "+os.path.expanduser(feed[1]) #FileToString(os.path.expanduser(feed[1]))
#    subprocess.call([commandstring, optionsstring])





################ NOT USED ##############


def ExtractImagesFromDescription(descriptionList):
    imagelist=""
    print(descriptionList)
    for item in descriptionList:
        soup = BeautifulSoup(item)
        images=soup.find_all("img")
        print("images:%s" % images)
        for item in images:
            print("item:%s" % item)
            if item.get("src") not in imagelist:
                imagelist.append(item.get("src"))
    print(imagelist)
    return imagelist
