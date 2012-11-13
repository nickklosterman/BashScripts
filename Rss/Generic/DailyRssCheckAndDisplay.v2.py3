#!/usr/bin/python

#This script is used to grab the images in rss feeds. Feeds are read from a file. The file specifies the url and the temp file to use.
#The description tag of each post is used as the unique identifier.

#compare two lists of images and output the newest images not in the older set(from file)
# if imagelist=[ a b ] and imagelistfromfile = [b c d e] then outputlist=[a] , we use the break to prevent d,e from being in outputlist
def CompareImageLists(imagelist,imagelistfromfile):
#this method seems to break with long strings causing the "in" method to fail. Nope. it was a newline in a post that was being saved in my temp description file. so instead of keying off the whole description I am now keying off the title
    outputlist=[]
    if imagelist and imagelistfromfile:
#        print("imagelist: %s ; imagelistfromfile: %s" % (imagelist,imagelistfromfile))
        for item in imagelist:
            if item not in imagelistfromfile:
                print(" adding item:%s" % item)
                outputlist.append(item)
            else:
                print("%i new images" % len(outputlist)) 
                break  #break out of for statement
    else: # stuff
        print("no new images")
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
            soup = BeautifulSoup(item) #when I was passing the items to a function for the images to be stripped via BeautifulSoup, things weren't working
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
            filehandle.write(item+'\n') # this causes problems when the 'item' has newlines in it
        filehandle.close

#Compare the description tags from the file and from the recently obtained feed.
def CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlist,descriptionfile):
    outputdescriptionlist=[]
    if os.path.isfile(descriptionfile):
        filehandle=open(descriptionfile,'r')
        descriptionlistfromfile=[]
        for line in filehandle:
            descriptionlistfromfile.append(line.strip('\n\t\r'))
        outputdescriptionlist=CompareImageLists(descriptionlist,descriptionlistfromfile)
    else:
        print("os.path.isfile(%s) is false" % descriptionfile)
        print("Initial write of %s." % descriptionfile)

   #if there isn't a file to read we output the list from the rss feed 
    if not outputdescriptionlist:
        outputdescriptionlist=descriptionlist #copy items from rss to output list
    WriteDescriptionListToFile(descriptionfile,outputdescriptionlist)
    WriteImageListToFileFromDescription(descriptionfile,outputdescriptionlist)

def GetDescriptionListFromFeed(feed):
    d=feedparser.parse(feed)
    descriptionlist=[]
    if (len(d.entries) > 0):
        for index in range(len(d.entries)):
            rss_post_title=d.entries[index].get('title','no title') #'description','uh oh no descrip') # SEE Note 1:
            rss_post_description=d.entries[index].get('description','no description') #'description','uh oh no descrip') # SEE Note 1:
            rss_post_media_content=d.entries[index].get('media_content','') 
            media_list=[]
            for media in rss_post_media_content:
                media_list.append(media.get('url',''))
            descriptionlist.append(rss_post_description.strip('\n\r'))
            titlelist.append(rss_post_title)
            if media_list: #make sure its not empty
                for media_list_item in media_list: #append the individual items to our list, otherwise it seems we append a list to our list
                    descriptionlist.append(media_list_item)
    return descriptionlist,titlelist

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

def CreateTempFileFromURL(url):
    if url[0:7]=="http://":#check to see if the url starts with http://
        url=url[7:] #lop off http://
    print(url.replace('.','-').replace('/','_')) #replace periods and slashes with hyphens and underscores

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




#Note 1:
# it appears that jeremyfish uses a diff format. 
#the <content:encoded> tag has more info than <description> and the images are specified in a <media:content> tag 
#
#<media:content url="http://2.gravatar.com/avatar/b5c680ae65ef8f86e2836149e5a9ca49?s=96&#38;d=identicon&#38;r=G" medium="image">
#        <media:title type="html">jeremyfish</media:title>
#</media:content>
#
#--> http://stackoverflow.com/questions/2461853/how-to-parse-the-mediagroup-using-feedparser

#kahnehteh.blogspot.com: I need to prevent getting googleusercontent tracking images <img alt="" height="1" src="https://blogger.googleusercontent.com/tracker/17896366-6108934090819161882?l=kahnehteh.blogspot.com" width="1" /> These are in the footer
# blogspot also seems to have a weird format due to google namespace
