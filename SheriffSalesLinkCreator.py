#this program takes as input a saved search from the Montgomery County Sheriff sales site

from html.parser import HTMLParser #works on ARch, not ubuntu


class MyHTMLParser(HTMLParser):
    def handle_starttag(self, tag, attrs):
        print("Encountered a start tag:", tag)
    def handle_endtag(self, tag):
        print("Encountered an end tag :", tag)
    def handle_data(self, data):
        print("Encountered some data  :", data)



#the input should be the summary view and not the detailed view
AuctionListFile=open("SFLISTAUCTIONDO.CFM.htm")
output=open("output.txt","w")

parser=MyHTMLParser(strict=False) #works on Arch


import re
def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)
def stripspaces(data):
    p = re.compile(r' ')
    return p.sub('+',data)

import time # for 
import json
def geocode(address):
    url = "http://maps.googleapis.com/maps/api/geocode/json?address=%s" % urllib.quote(address) 
    data = json.loads(urllib.urlopen(url).read()) 
    print(data)
    time.sleep(1.0) #to prevent getting status code 620 Too Many Queries from Google                                                            

# https://developers.google.com/maps/articles/phpsqlgeocode
#  https://developers.google.com/maps/documentation/geocoding/ 

"""
AuctionListFile=open("SFLISTAUCTIONDO.CFM.htm")
output=open("output.txt","w")
addresslineisnext=0
zipcodelineisnext=0
data="<html>"
linecounter=0
for line in AuctionListFile:
    if linecounter > 173:
    if addresslineisnext==1:
        line1=line.strip()
#        dataline="http://maps.google.com/maps?oe=utf-8&q="+line1.rstrip()+"+ohio"
        address=stripspaces(striphtml(line1.rstrip()))
#        print(address)
#        dataline="<a href=\"http://maps.google.com/maps?oe=utf-8&q="+line1.rstrip()+"+ohio\">" +line1.rstrip()+"</a> <br>"
        dataline="<a href=\"http://maps.google.com/maps?oe=utf-8&q="+address+"+ohio\">" +striphtml(line1.rstrip())
#        dataline=line1.rstrip()
#        data+=stripspaces(dataline)
        data+=dataline
        addresslineisnext=0
    if line.find("275px")!=-1:
        addresslineisnext=1


#actually we don't need the zip...
    if zipcodelineisnext==1:
 #       print(line)
        data+=striphtml(line)+"</a> <br>" #uncomment this line if you want to include the zipcode
        #        data=""
        zipcodelineisnext=0
    if line.find("45px")!=-1:
        zipcodelineisnext=1

data+="</html>"
#output.write(striphtml(data))
output.write(data)
#http://maps.google.com/maps?oe=utf-8&q=43+watervliet+avenue+dayton+ohio
"""


AuctionListFile=open("SFLISTAUCTIONDO.CFM.htm")
addresslineisnext=0
zipcodelineisnext=0

linecounter=0
propertyRecordcounter=0
SaleDate=""
CaseNumber=""
Address=""
Zipcode=""
Appraisal=""
MinBidAmt=""
SaleStatus=""
enddataflag=0
for line in AuctionListFile:
    if (linecounter > 172) and (enddataflag==0): #first valid record starts on line 173                                                               
        line1=line.strip()
        if line.find("65px")!=-1:
            propertyRecordcounter=0
            SaleDate=striphtml(line1.rstrip())
        if propertyRecordcounter==2:
            CaseNumber=striphtml(line1.rstrip())
        if propertyRecordcounter==5:
            Address=striphtml(line1.rstrip())
        if propertyRecordcounter==8:
            Zipcode=striphtml(line1.rstrip())
        if propertyRecordcounter==14:
            Appraisal=striphtml(line1.rstrip())
        if propertyRecordcounter==20:
            MinBidAmt=striphtml(line1.rstrip())
        if propertyRecordcounter==24:
            SaleStatus=striphtml(line1.rstrip())
            if SaleStatus=="":
                        propertyRecordcounter-=1 #when prop cancelled it appears one line lower                      
        propertyRecordcounter+=1
        if propertyRecordcounter>24:
            propertyRecordcounter=0 #reset counter when outside a record                                                  
            print(SaleDate,CaseNumber,Address,Zipcode,Appraisal,MinBidAmt,SaleStatus)
            geocode(Address)
        if line.find("</table>")!=-1: #this signals the end of the property list                                                              
            enddataflag=1
    linecounter+=1





 #stupid error: you get below when the indentation isn't pure tabs. it must count tabs to determine depthof a call.           
#TabError: inconsistent use of tabs and spaces in indentation    
