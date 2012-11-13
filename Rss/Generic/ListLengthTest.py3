#!/usr/bin/python

#compare two lists of images and output the newest images not in the older set(from file)
# if imagelist=[ a b ] and imagelistfromfile = [b c d e] then outputlist=[a] , we use the break to prevent d,e from being in outputlist
def CompareImageLists(imagelist,imagelistfromfile):
    outputlist=[]
    if imagelist and imagelistfromfile:
        for item in imagelist:
            temp_item=item #[0:24]
            if temp_item not in imagelistfromfile:
                print("--adding item:\n%s" % item)
                outputlist.append(item)
            else:
                print("%i new images" % len(outputlist)) 
                break  #break out of for statement
    else: # stuff
        print("no new listing")
        outputlist=imagelistfromfile
    return outputlist

def GetDescriptionListFromFeed(feed):
    d=feedparser.parse(feed)
    descriptionlist=[]
    if (len(d.entries) > 0):
        for index in range(len(d.entries)):
            rss_post_description=d.entries[index].get('description','uh oh no descrip') # SEE Note 1:
            descriptionlist.append(rss_post_description)
    return descriptionlist

def GetDescriptionListFromFile(descriptionfile):
    if os.path.isfile(descriptionfile):
        filehandle=open(descriptionfile,'r')
        descriptionlistfromfile=[]
        for line in filehandle:
            descriptionlistfromfile.append(line.strip('\n\t\r'))
    else:		
        print("not a file")
    return descriptionlistfromfile

#Compare the description tags from the file and from the recently obtained feed.
def CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlist,descriptionfile):
    outputdescriptionlist=CompareImageLists(descriptionlist,descriptionlistfromfile)
    return outputdescriptionlist
                      
import os.path,sys
import feedparser

descriptionlistfromfeed=GetDescriptionListFromFeed("http://mrjakeparker.tumblr.com/rss")
descriptionlistfromfile=GetDescriptionListFromFile(os.path.expanduser("~/.RSS/mrjakeparkertumblr"))
#print(descriptionlistfromfeed)
#print(descriptionlistfromfile)

print(descriptionlistfromfeed[0][0:124])
print(descriptionlistfromfile[0][0:124])
if (descriptionlistfromfile[2]==descriptionlistfromfeed[1]):
    print("match")


for item in descriptionlistfromfeed:
    print(len(item))
print("---")
for item in descriptionlistfromfile:
    print(len(item))

if 1 == 0:
    for item in descriptionlist:
        print("item:%s...." % (item[0:70]) )

outputimagelist=CompareDescriptionListFromFeedToDescriptionListFromFile(descriptionlistfromfeed,descriptionlistfromfile)
for item in outputimagelist:
    print("item:%s...." % (item[0:70]) )

