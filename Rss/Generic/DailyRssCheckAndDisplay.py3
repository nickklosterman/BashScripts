#!/usr/bin/python

def ObtainFeed(url):
    handle = urllib.request.urlopen(url)
    atom=feedparser.parse( handle) 
    return atom

def SaveFeedFile(): #fuck well I'll need to reread the saved rss feed and then compare the structures. how do I do this?
    filehandle=open("/tmp/JPrss",'r')
    atom=feedparser.parse( filehandle) 
    PrintFeed(atom)

#from http://www.techniqal.com/blog/2008/07/31/python-file-read-write-with-urllib2/
def stealStuff(file_name,file_mode,base_url):
    from urllib2 import Request, urlopen, URLError, HTTPError
    
    #create the url and the request
    url = base_url + file_name
    req = Request(url)
    
    # Open the url
    try:
        f = urlopen(req)
        print( "downloading " + url)

# Open our local file for writing
        local_file = open(file_name, "w" + file_mode)
#Write to our local file
        local_file.write(f.read())
        local_file.close()

#handle errors
    except urllib.error.HTTPError as err:
        print ("HTTP Error:",err.code , url)
    except urllib.error.HTTPError as err:
        print ("URL Error:",err.reason , url)
        
def PrintFeed(atom):
    for i in range(len(atom.entries)):
        #print(("%s|%s" % (atom.entries[i].title,atom.entries[i].summary))) #summary links link title title_detail published summary_detaili title id guidislink published_parsed
        #print(("%s|%s" % (atom.entries[i].item["date"],atom.entries[i].item["link"])))
        print(("%s\n" % (atom.entries[i].summary)))
        print(("%s\n" % (atom.entries[i].links)))
        print(("%s\n" % (atom.entries[i].link)))
        print(("%s\n" % (atom.entries[i].title)))
        print(("%s\n" % (atom.entries[i].title_detail)))
        print(("%s\n" % (atom.entries[i].published)))
        print(("%s\n" % (atom.entries[i].summary_detail)))
        print(("%s\n" % (atom.entries[i].title)))
        print(("%s\n" % (atom.entries[i].id)))
        print(("%s\n" % (atom.entries[i].guidislink)))
#        print(("%s\n" % (atom.entries[i].published_parsed)))


#for removing duplicates:
# http://docs.python.org/2/faq/programming.html#how-do-you-remove-duplicates-from-a-list
#
def CheckFeedForDuplicates(feedList):
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
                      
    
# some useful predefined tags: title summary author
#there is a predefined set of accessible tags for the feedparser. They can be seen here: http://packages.python.org/feedparser/
#to access the rest of the XML we'll need to set up a custom dom parser
#I don't see a huge need for the other info
#See Resources.txt
#http://www.blog.pythonlibrary.org/2010/11/12/python-parsing-xml-with-minidom/ <--this seems to be a simple and good example    
#-----------------===============-----------------
import sys,urllib.request,urllib.error,urllib.parse,base64
from textwrap import wrap
import feedparser 
import getopt
import os.path # for os.path.isfile()

if len(sys.argv)>1 and  sys.argv[1]!="":
    feedfile=sys.argv[1]
    feedandtempfilelist=ParseFeedFile(feedfile)
    SaveFeedFile()

    # print(feedandtempfilelist)
    # CheckFeedList(feedandtempfilelist)
    # nonDupList=CheckFeedForDuplicates(feedandtempfilelist)
    # print(nonDupList)
    # for item in nonDupList:
    #     print(item[0])
    #     feed=ObtainFeed(item[0])
    #     PrintFeed(feed)
#    feed=ObtainFeed(url)
#    PrintFeed(feed)
else:
    print("No Login File Specified: gmailcheckparseconky.py loginfile.txt")

# input file will be csv file of url and tmp file path/filename
# www.djinnius.com/rss,.Rss/djinnius
#read input file and place contents in a list
# loop over list
# if tmp file exists
# read and parse file
# download and parse file from web
# if the two parsed lists are equal do nothing
# if the two parsed lists aren't equal then 
# create list of the new postings
# parse new postings for images
# download and display new images
