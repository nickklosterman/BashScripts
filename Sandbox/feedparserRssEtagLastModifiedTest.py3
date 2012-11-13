#!/usr/bin/python

#help from my SO post: stackoverflow.com/questions/13297077/python-etag-last-modified-not-working-how-to-get-latest-rss

def feed_modified_date(feed):
    # this is the last-modified value in the response header
    # do not confuse this with the time that is in each feed as the server
    # may be using a different timezone for last-resposne headers than it 
    # uses for the publish date

    modified = feed.get('modified')
    if modified is not None:
        return modified

    return None

def max_entry_date(feed):
    entry_pub_dates = (e.get('published_parsed') for e in feed.entries)
    entry_pub_dates = tuple(e for e in entry_pub_dates if e is not None)

    if len(entry_pub_dates) > 0:
        return max(entry_pub_dates)    

    return None

def entries_with_dates_after(feed, date):
    response = []

    for entry in feed.entries:
        if entry.get('published_parsed') > date:
            response.append(entry)

    return response

def GetImageURL(rss_post_description): #or use Beautiful Soup
    re.repl('.*<img src="',rss_post_description) #http://docs.python.org/2/library/re.html 

import feedparser

from bs4 import BeautifulSoup

rsslist=[ "http://skottieyoung.tumblr.com/rss",
          "http://mrjakeparker.com/feed/",
          "http://mrjakeparker.tumblr.com/rss",
          #"http://mrjakeparker.com/blog/" ],#this feed doesn't work.  
          # "https://twitter.com/mrjakeparker",
          # "http://www.facebook.com/jakeparkerart?ref=tn_tnmn",
          # "http://web.stagram.com/n/jakeparker/",
          "http://widget.stagram.com/rss/n/jakeparker/",
          "http://widget.stagram.com/rss/n/jakeparker/",
          "http://jeremyfish.wordpress.com/feed/",
          "http://kahnehteh.blogspot.com/feeds/posts/default"] #I need some type of method to get the full rss url from the main page.

filelist=["~/.Rss/skottieyoungtumblr",
          "~/.Rss/mrjakeparker",
          "~/.Rss/mrjakeparkertumblr",
          "~/.Rss/jakeparkerinstagram"
]
for feed in rsslist:
    print('--------%s-------' % (feed))
    d=feedparser.parse(feed)
    print('feed length %i' % len(d.entries)) #   print(len(d.entries))
    if (len(d.entries) > 0):
        etag=d.feed.get('etag',None)
        modified=d.get('modified',d.get('updated',d.entries[0].get('published','no modified,update or published fields present in rss')))
        modified = feed_modified_date(d)
#        d2=feedparser.parse(feed,modified)
        d2 = feedparser.parse(feed, etag=etag, modified=modified)
        print('second feed length %i' % len(d2.entries))
        if len(d2.entries) > 0:
            print("server does not support etags or there are new entries")
            # perhaps the server does not support etags or last-modified
            # filter entries ourself
            prev_max_date = max_entry_date(d)
            entries = entries_with_dates_after(d2, prev_max_date)
            print('%i new entries' % len(entries))

        for index in range(len(d.entries)):
            rss_post_description=d.entries[index].get('description','uh oh no descrip')
#            print("-----rss post description----")
#            print(rss_post_description) #hmm it appears that diff rss creators sometimes cut off the full post. mrjakeparker.com/feed cuts it short
            soup = BeautifulSoup(rss_post_description)
#            print(soup.find("img")["src"])
            images=soup.find_all("img")
#            print(images)
            for item in images:
                print(item.get("src"))
#            GetImageURL(rss_post_description)
        if (len(d2.entries) > 0):
            etag2=d2.feed.get('etag','')
            modified2=d2.get('updated',d.entries[0].get('published',''))
        if (d2==d): #ideally we would never see this bc etags/last modified would prevent unnecessarily downloading what we all ready have.
            print("Arrg these are the same")
            
#d2.status





#used try,except when I could've handled this with .get and .has_key functions http://packages.python.org/feedparser/basic-existence.html
        # try:
        #     etag=d.feed.get('etag','')
        # except (AttributeError,KeyError) as e1 : #,AttributeError
        #     etag=""
        # print("etag:"+etag)
        # modified=d.get('updated','i')
        # try:
            
        #     modified=d.updated
        #     print(d.updated)
        # except (AttributeError,KeyError) as e1 : #,AttributeError
        #     modified=d.entries[0].published
        #     print(d.entries[0].published)


# try:
#                 modified2=d2.updated
#                 print(d2.updated)
#             except (AttributeError,KeyError) as e1 : #,AttributeError
#                 modified=d2.entries[0].published
#                 print(d2.entries[0].published)
