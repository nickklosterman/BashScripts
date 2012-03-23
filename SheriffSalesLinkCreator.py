#this program takes as input a saved search from the Montgomery County Sheriff sales site
from html.parser import HTMLParser

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
parser=MyHTMLParser(strict=False)

"""
insideTRflag=0
for line in AuctionListFile:
    if line.strip():  #remove whitespace
        #we set a flag to indicate we are between the opening and closing table row tags. When we are in between we strip the newline so that all of the data is on a single line.
        lowerline=line.lower() #convert to lowercase so don't have to worry about case sensitivity
        if lowerline.find("<tr bgcolor=")!=-1:
            insideTRflag=1
            #print( "IIIIinside")
            data="" #reset 
        if lowerline.find("</tr></font>")!=-1:
#print (data)
            insideTRflag=0
            data+=line  #keep newline
            output.write(data)

            #parser.feed(data)

            #print("OOOoutside")
        if insideTRflag == 1:
            data+=line.rstrip() #remove newline

AuctionListFile.close()
output.close()
"""
import re
def striphtml(data):
    p = re.compile(r'<.*?>')
    return p.sub('', data)
def stripspaces(data):
    p = re.compile(r' ')
    return p.sub('+',data)


AuctionListFile=open("SFLISTAUCTIONDO.CFM.htm")
output=open("output.txt","w")
addresslineisnext=0
zipcodelineisnext=0
data="<html>"
for line in AuctionListFile:
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


#parser.feed('<h1>Python</h1>')


 #stupid error: you get below when the indentation isn't pure tabs. it must count tabs to determine depthof a call.           
#TabError: inconsistent use of tabs and spaces in indentation    
