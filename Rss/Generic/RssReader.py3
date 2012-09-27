#!/usr/bin/python

def fill(text, width):
    '''A custom method to assist in pretty printing'''
    if len(text) < width:
        return text + ' '*(width-len(text))
    else:
        return text

def ObtainFeed(url):
# Build the request
    handle = urllib.request.urlopen(url)
    atom=feedparser.parse( handle) 
    return atom

def PrintFeed(atom):
    for i in range(len(atom.entries)):
#was title, summary
#        print "| %s| %s|" % (    fill(str(i), 3),            fill(wrap(atom.entries[i].title, 50)[0], 55),      )        

#        print(("%s" % (atom.entries[i].title)))
        print(("%s|%s" % (atom.entries[i].title,atom.entries[i].summary)))

    
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


#provide list of choices. Execute based on choices if no command line arg
#command line arg should be url or make Demonoid specific app
if len(sys.argv)>1 and  sys.argv[1]!="":
    url=sys.argv[1]
#    url="http://static.demonoid.me/rss/11.137.xml"
    feed=ObtainFeed(url)
    PrintFeed(feed)
else:
    print("No Login File Specified: gmailcheckparseconky.py loginfile.txt")


#http://demonoid.ph/rss.php
