#!/usr/bin/python

def getEmailAlias(data):
    import re
    p = re.compile(r'\(.*')
    return p.sub('', data)

def getUsernamePassword(file):
    import linecache 
    username=linecache.getline(file,1) #username on 1st line
    password=linecache.getline(file,2) #password on 2nd line
    return username.strip(),password.strip()  #remove the CRLF

def fill(text, width):
    '''A custom method to assist in pretty printing'''
    if len(text) < width:
        return text + ' '*(width-len(text))
    else:
        return text
def ObtainEmailFeed(user,password):
    string = bytes("%s:%s" % (user,password), 'utf-8')
    b64bytes = base64.encodebytes(string)
    b64auth = b64bytes.decode('ascii')
    auth = "Basic " + b64auth
# Build the request
    req = urllib.request.Request("https://mail.google.com/mail/feed/atom/")
    req.add_header("Authorization", auth)
    try:
        handle = urllib.request.urlopen(req)
        atom=feedparser.parse( handle) 
        return atom
    except urllib.error.URLError as e:
        if hasattr(e, 'reason'):
            print('We failed to reach a server.')
            print('Reason: ', e.reason )
 
        elif hasattr(e, 'code'):
            print('The server couldn\'t fulfill the request.')
            print('Error code: ', e.code)
    return 0    



#to get around the url coding/decoding and   TypeError: expected bytes, bytearray or buffer compatible object I had to read this and even then I dont' think it worked the first time for me : http://stackoverflow.com/questions/15772498/how-to-make-new-line-commands-work-in-a-txt-file-opened-from-the-internet
def PrintFeed(atom):
    for i in range(len(atom.entries)):
        author=getEmailAlias(atom.entries[i].author).encode('ascii','ignore') #encode('utf-8') #ascii','ignore')
        type(author)
        title=atom.entries[i].title.encode('ascii','ignore') #utf-8')
        if len(author)<1:# <-- need to check for empty strings or the wrap barfs , tried to find 
            author=("<unknown>").encode('utf-8') #have to encode otherwise we cause errors when we try to decode when we print.
        if len(title)<1:
            title=("<None>").encode('utf-8')
#        print("| %s| %s| %s|" % (
#            fill(str(i), 3),
        print("| %s| %s|" % (
#            fill(wrap(atom.entries[i].title, 50)[0], 55), #was title, summary
            fill(wrap(title.decode('utf-8'), 50)[0], 55), #wrap outputs a list?
#            fill(title.decode('utf-8'), 75), #wrap outputs a list?
#            fill(wrap(getEmailAlias(atom.entries[i].author), 15)[0], 21))) #author
#            fill(wrap(author.decode('utf-8'), 15)[0], 21))) 
            fill(author.decode('utf-8'), 21))) 
    
# some useful predefined tags: title summary author
#there is a predefined set of accessible tags for the feedparser. They can be seen here: http://packages.python.org/feedparser/
#to access the rest of the XML we'll need to set up a custom dom parser
#I don't see a huge need for the other info
#See Resources.txt
#http://www.blog.pythonlibrary.org/2010/11/12/python-parsing-xml-with-minidom/ <--this seems to be a simple and good example    
#-----------------===============-----------------
import sys,urllib.request,urllib.error,urllib.parse,base64
from textwrap import wrap
import feedparser  #sudo pacman -Syu python-feedparser
import time

if len(sys.argv)>1 and  sys.argv[1]!="":
    inputfilename=sys.argv[1]
    user,password=getUsernamePassword(inputfilename)
    feed=ObtainEmailFeed(user,password)
    # while (feed==0): #retry obtaining the feed
    #     print('retry')
    #     time.sleep(0.2500) #sadly this doesn't seem to really work to reestablish a connection
    #     feed=ObtainEmailFeed(user,password)

    if(feed!=0):
        PrintFeed(feed)

else:
    print("No Login File Specified: gmailcheckparseconky.py loginfile.txt")
