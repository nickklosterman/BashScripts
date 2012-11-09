#!/usr/bin/python

try:
    import xml.etree.cElementTree as ET #this module is much faster and consumes less memory
except ImportError:
    import xml.etree.ElementTree as ET

class FeedEntry:
    def __init__(self,entries):
        self.summary=entries.summary
        self.links=entries.links
        self.link=entries.link
        self.title=entries.title
        self.title_detail=entries.title_detail
        self.published=entries.published
        self.summary_detail=entries.summary_detail
        self.title=entries.title
        try:
            self.id=entries.id
        except AttributeError:
            self.id=None
        try:
            self.guidslink=entries.guidislink
        except AttributeError:
            self.guidslink=None
#        print(("%s\n" % (atom.entries[i].published_parsed)))


class FeedParserTreeURL:
    def __init__(self,url):
        self.ImageList=[]
        self.FeedEntryList=[]
        handle = urllib.request.urlopen(url)
        atom=feedparser.parse( handle) 
        #print(atom.etag)
        for i in range(len(atom.entries)):
            self.FeedEntryList.append(FeedEntry(atom.entries[i]))
    def CreateImagelist(self):
        for item in self.FeedEntryList:
            soup = BeautifulSoup(item.get('description',None))
            images=soup.find_all("img")
            for imageitem in images:
                self.ImageList.append(imageitem.get("src"))
    def WriteImageListToFile(self,filename):
        filehandle=open(filename,'w')
        filehandle.write(self.ImageList)
        filehandle.close()
    
    
class FeedParserTreeFile:
    def __init__(self,file):
        self.FeedEntryList=[]
        file=os.path.expanduser(file) #expand tilde's into user's path
        atom=feedparser.parse(file,'r')#(r'/tmp/JPrss') # using feedparser on a file http://packages.python.org/feedparser/introduction.html
        print(atom.etag)
        for i in range(len(atom.entries)):
            self.FeedEntryList.append(FeedEntry(atom.entries[i]))

class ImageListFromFile:
    def __init__(self,file):
        self.ImageList=[]
        if os.path.isfile(file):
            filehandle=open(feedfile,'r')
            for line in filehandle:
                line_=line.strip(' \t\r\n') #strip whitespace
                if len(line_)>1 and line_[0]!='#': #skip comment lines
                    self.ImageList.append(line_) 

        

class FeedParserCompareTree:
    def __init__(self,item):
        self.Tree=[] # I think I really want dicts and not lists....esp of FeedParserTreeURL adn FeedParserTreeFile
        self.Tree.append(FeedParserTreeURL(item[0]))
#        self.Tree.append(FeedParserTreeFile(item[1]))
        self.Tree.append(ImageListFromFile(item[1]))
    def CompareTrees(self):
        uniqueList = []
        duplicateList = []
        #print(self.Tree[0],self.Tree[1])
        
        # for value in self.Tree[0]:
        #     if value[1] not in uniqueListTempFiles:
        #         uniqueList.append(value)
        #     else:
        #         duplicateList.append(value)
        # if len(duplicateList)>0:
        #     print("You are using a temp file more than once. Here is a list of the second occurrence with its url.")
        #     print(duplicateList)
        # return uniqueList #duplicateList
        
        
    
def ObtainFeed(url):
    handle = urllib.request.urlopen(url)
    atom=feedparser.parse( handle) 
    return atom

def ObtainFeedFile(file): 
    file=os.path.expanduser(file) #expand tilde's
    atom=feedparser.parse(file,'r')#(r'/tmp/JPrss') # using feedparser on a file http://packages.python.org/feedparser/introduction.html
    #PrintFeed2(atom) #since some fields are missing I need to build a class and objects such that missing fields are filled with appropriate values etc. 
    return atom

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

def PrintFeed2(atom):
    for i in range(len(atom.entries)):
        print("------New Record-----------")
        print(("summary:%s\n" % (atom.entries[i].summary)))
        print(("links:%s\n" % (atom.entries[i].links)))
        print(("link:%s\n" % (atom.entries[i].link)))
        print(("title:%s\n" % (atom.entries[i].title)))
        print(("title_detail:%s\n" % (atom.entries[i].title_detail)))
        print(("published:%s\n" % (atom.entries[i].published)))
        print(("summary_detail:%s\n" % (atom.entries[i].summary_detail)))
        print(("title:%s\n" % (atom.entries[i].title)))
        try:
            print(("id:%s\n" % (atom.entries[i].id)))
        except AttributeError:
            print("no id, %s"  % AttributeError)
        try:
            print(("guidslink:%s\n" % (atom.entries[i].guidislink)))
        except AttributeError:
            print("no guidslink, %s"  % AttributeError)



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
#    SaveFeedFile()
    print(feedandtempfilelist)
    CheckFeedList(feedandtempfilelist)
    nonDupList=CheckFeedFileForDuplicates(feedandtempfilelist)
    print(nonDupList)
    for item in nonDupList:
        Billy=FeedParserCompareTree(item)
        Billy.CompareTrees()
#        print(item[0])
#        feedurl=ObtainFeed(item[0])
#        feedfromfile=ObtainFeedFile(item[1]) #I foudn that you had to compare the two parseed trees bc the file may have timestamps that change when you retrieve the xml/rss file. I found this out by grabbing http://widget.stagram.com/rss/n/jakeparker/ and grabbing it a bit later and performing a diff on the two and finding differences in the file. 
#        if feedurl==feedfromfile:
#            print("They are equal")
#        else:
#            print("they ain't equal")
        #PrintFeed2(feedurl)
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
