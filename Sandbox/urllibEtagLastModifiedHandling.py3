#!/usr/bin/python
import urllib.request
request=urllib.request.Request('http://mrjakeparker.com/feed/')
opener=urllib.request.build_opener()
print(opener.info())
firstdatastream=opener.open(request)
#firstdatastream.header_items
print(firstdatastream)
#request.add_header('If-Modified-Since',firstdatastream.header_items.get('Last-Modified')) 
#seconddatastream = opener.open(request)