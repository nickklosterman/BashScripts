#!/usr/bin/env/python
#-*- python -*-
'''
this is a simple program that is meant to open a file which lists available
files on wowebook and to compare that to files in my Wowebookdownloads directory
It will then tell me which available files I haven't gotten all ready. 
'''
import glob,os
availableEbooks=open('/tmp/wowIndividualBookTitles.txt')
wowEbookList=[ x.strip() for x in availableEbooks.readlines()] #need the x.strip otherwise ourlist hsa the \n in it.
availableEbooks.close()
print('\n'.join(wowEbookList))

#only include epubs and rars in our list, os.path.basename strips so I just have the filenames
myEbookDownloads=[os.path.basename(x.strip()) for x in glob.glob('/home/puffjay/Remote/BBB/Remote/SGOne/WowDownloads/*.rar')]
#myEbookDownloads.append([os.path.basename(x) for x in glob.glob('/home/puffjay/Remote/BBB/Remote/SGOne/WowDownloads/*.epub') ]) this turns the list into a str?? and makes the following print statement barf
#print('\n'.join(myEbookDownloads))
                       
listOfEbooksIDontHave=[i for i in wowEbookList if i not in myEbookDownloads]
listOfEbooksIDontHave
#print('\n'.join(listOfEbooksIDontHave))

