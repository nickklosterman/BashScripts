#!/usr/bin/python


#---------------------------------
#this part downloads all the images
#---------------------------------
#from :http://www.java2s.com/Tutorial/Python/0420__Network/RetrievingImagesfromHTMLDocuments.htm
import HTMLParser
import urllib
import sys

urlString = "http://www.comicsalliance.com/2011/03/11/best-art-ever-this-week-3-10-11/"

def getImage(addr):
    print(addr)
    u = urllib.urlopen(addr)
    data = u.read()

    splitPath = addr.split('/')
    fName = splitPath.pop()
    #print fName

    f = open(fName, 'wb')
    f.write(data)
    f.close()

class parseImages(HTMLParser.HTMLParser):
    def handle_starttag(self, tag, attrs):
        if tag == 'img':
            for name,value in attrs:
                if name == 'src':
#                    getImage(urlString + "/" + value)
                    getImage(value)

lParser = parseImages()

u = urllib.urlopen(urlString)
#print u.info()

lParser.feed(u.read())
lParser.close()

#---------------------------------
#this part displays all the links
#---------------------------------

import urllib
urllib.urlretrieve( 'http://www.comicsalliance.com/2011/03/11/best-art-ever-this-week-3-10-11/', '/tmp/CAmain.htm' )
from htmllib import HTMLParser #htmllib has been deprecated in favor or HTMLParser, HTMLParser has been renamed html.parser
from formatter import NullFormatter
parser= HTMLParser( NullFormatter( ) )
parser.feed( open( '/tmp/CAmain.htm' ).read( ) )


#import urlparse

linecounter=0
for a in parser.anchorlist:
#    print urlparse.urljoin( 'http://python.org/', a )
    if linecounter>105 and linecounter<145:
        print(a)
    linecounter+=1



"""
general resource: http://docs.python.org/library/htmlparser.html
use beautiful soup : http://stackoverflow.com/questions/6790770/look-for-img-and-id-tag-store-url-in-variable-if-both-are-true  http://www.crummy.com/software/BeautifulSoup/
http://berrytutorials.blogspot.com/2010/03/simple-web-crawler-in-python-using.html

http://www.comicsalliance.com/tag/BestComicBookCovers/
http://www.comicsalliance.com/tag/best+comic+book+covers/

http://www.comicsalliance.com/tag/BestArtEver/
http://www.comicsalliance.com/tag/best+art+ever/
http://www.comicsalliance.com/tag/bestartever/page/5/ #this is highets page I've found
http://www.comicsalliance.com/2011/03/11/best-art-ever-this-week-3-10-11/ #<-- brute force as all urls look like this and are posted new on friday

http://www.comicsalliance.com/tag/best%20art%20ever/page/5/ #this is highets page I've found
http://www.comicsalliance.com/tag/best+art+ever/

import re

def NoMorePages(line):
    result=line.find("No posts with tag bestartever found!") #this shows on the index page when we've reached the end.
    return results
#    <div class="hub"><h1>bestartever</h1><div class="dgnlBdr"> </div><ul><div class="noCatTags">No posts with tag <b>bestartever</b> found!</div></ul></div><div class="asylumHubSLinks"><script type="text/javascript">adsonar_placementId=1486169;adsonar_pid=1757767;adsonar_ps=-1;adsonar_zw=584;adsonar_zh=280;adsonar_jv='ads.tw.adsonar.com';</script><script language="JavaScript" src="http://js.adsonar.com/js/tw_dfp_adsonar.js"></script></div><!-- @Show-Post -->




def GetSeparateLinks(data):
#split passed variable on <h4> and use regex to strip stuff
    links=data.split('<h4') #or split on a href=" ?

#all shows up on one line

#<div class="hub"><h1>bestartever</h1><div class="dgnlBdr"> </div><ul><div id="p19858678"><li><h4><a href="http://www.comicsalliance.com/2011/03/11/best-art-ever-this-week-3-10-11/"><span id="pt19858678">Best Art Ever (This Week) - 3.10.11</span></a></h4><p class="dateAuthor">Friday 11 March By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/03/11/best-art-ever-this-week-3-10-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/02/bestart3-1298622296_thumbnail.jpg" /></a></div></li></div><div id="p19858551"><li><h4><a href="http://www.comicsalliance.com/2011/03/04/best-art-ever-this-week-03-03-11/"><span id="pt19858551">Best Art Ever (This Week) - 03.04.11</span></a></h4><p class="dateAuthor">Friday 04 March By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/03/04/best-art-ever-this-week-03-03-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/02/bestart2_thumbnail.jpg" /></a></div></li></div><div id="p19839519"><li><h4><a href="http://www.comicsalliance.com/2011/02/18/best-art-ever-this-week-02-18-11/"><span id="pt19839519">Best Art Ever (This Week) - 02.18.11</span></a></h4><p class="dateAuthor">Friday 18 February By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/02/18/best-art-ever-this-week-02-18-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2010/11/freshinkad_thumbnail.jpg" /></a></div></li></div><div id="p19839433"><li><h4><a href="http://www.comicsalliance.com/2011/02/11/best-art-ever-this-week-02-10-11/"><span id="pt19839433">Best Art Ever (This Week) - 02.10.11</span></a></h4><p class="dateAuthor">Friday 11 February By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/02/11/best-art-ever-this-week-02-10-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/02/bestart1_thumbnail.jpg" /></a></div></li></div><div id="p19827862"><li><h4><a href="http://www.comicsalliance.com/2011/02/04/best-art-ever-this-week-02-04-11/"><span id="pt19827862">Best Art Ever (This Week) - 02.04.11</span></a></h4><p class="dateAuthor">Friday 04 February By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/02/04/best-art-ever-this-week-02-04-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/02/bestart_thumbnail.jpg" /></a></div></li></div><div id="p19818941"><li><h4><a href="http://www.comicsalliance.com/2011/01/28/best-art-ever-this-week-01-28-11/"><span id="pt19818941">Best Art Ever (This Week) - 01.28.11</span></a></h4><p class="dateAuthor">Friday 28 January By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/01/28/best-art-ever-this-week-01-28-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/01/bestart-1296193568_thumbnail.jpg" /></a></div></li></div><div id="p19810490"><li><h4><a href="http://www.comicsalliance.com/2011/01/21/best-art-ever-this-week-01-21-11/"><span id="pt19810490">Best Art Ever (This Week) - 01.21.11</span></a></h4><p class="dateAuthor">Friday 21 January By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/01/21/best-art-ever-this-week-01-21-11/"><img src="http://www.blogcdn.com/www.comicsalliance.com/media/2011/01/untitled-1-1295638701_thumbnail.jpg" /></a></div></li></div><div id="p19795226"><li><h4><a href="http://www.comicsalliance.com/2011/01/17/best-art-ever-this-week-01-17-11/"><span id="pt19795226">Best Art Ever (This Week) - 01.17.11</span></a></h4><p class="dateAuthor">Monday 17 January By: <a href="/bloggers/andy-khouri/">Andy Khouri</a></p><div class="imageHolder"><a href="http://www.comicsalliance.com/2011/01/17/best-art-ever-this-week-01-17-11/"><img src="http://www.blogcdn.com
"""
