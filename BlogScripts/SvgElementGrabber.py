#This program is meant to grab thenounproject.com webpage and extract all the svg icons from the page and spit them out into separate files
#hmm it's be nice if just like the website it had an overview page and then a 'zoom' page so you knew which file the icon was in. or just a tooltip that zoomed the icon and gave the filename or just output the svg for copy and paste as well. Hmm but yeah want separate file for easy import/copy paste for adding to inkscape 

#uses httplib2: http://code.google.com/p/httplib2/wiki/Install

import httplib2, time
#from BeautifulSoup import BeautifulSoup, SoupStrainer # for python2
from bs4 import BeautifulSoup, SoupStrainer


# view-source:http://thenounproject.com/categories/travel-wayfinding/
categories=['animals', 'food-beverage', 'healthcare-wellness', 'people', 'safety-warnings', 'science-math', 'sports-recreation', 'tech-communication', 'transportation', 'travel-wayfinding', 'weather-nature']
site = "thenounproject.com"
f=open(site+".txt", 'wb')
f.write("<html>".encode('utf-8'))

for category in categories:
    http = httplib2.Http()
    #status, response = http.request("http://"+site) #just get main page
    status, response = http.request("http://"+site+"/categories/"+category+"/") 
    if str(status)[12:15] == "404":
        import sys;sys.exit("Done")
#    for link in BeautifulSoup(response).find('div',id="bundle-1").find_all('a'): #svg'):  #bundle- is the id for subsequent divs after you 'load more'
    for link in BeautifulSoup(response).find('section',id="categories").find_all('a'): #svg'):  #bundle- is the id for subsequent divs after you 'load more'
#need to prevent output of the 'favorite' icon
        if (not link.has_attr('data-favorite')):
        #need to prevent output of the quickview
            if (not link.span and link.svg): #if structure has an svg element but no span element. Am cheating using beautiful soup bc I don't want the quickview, and those have a span in them. I couldn't get it to work based on filtering by <a class=focus-link > for some reason.
                #since our find was on "a" tags we can just use .get
                filename=link.get('href').replace('/','').replace('#','_')
                filenameInComment="<!-- "+filename[4:]+" -->"
                filename=filename[4:]+".svg"
                f.write(filenameInComment.encode('utf-8'))
                separateFile=open(filename,'wb')
                separateFile.write((link.svg.encode('utf-8'))) #just output the svg element 
                separateFile.close()
                print(filename)
            
                f.write((link.svg.encode('utf-8'))) #just output the svg element 
                #f.write(u"\n------------------------\n".encode('utf-8'))
                f.write(u"\n \n".encode('utf-8'))
f.write("</html>".encode('utf-8'))
f.close()


#saved WORKING code
#grab all svg elements (works)
# import httplib2, time
# from bs4 import BeautifulSoup, SoupStrainer
# site = "thenounproject.com"
# f=open(site+".txt", 'wb')
# http = httplib2.Http()
# status, response = http.request("http://"+site)
# if str(status)[12:15] == "404":
#     import sys;sys.exit("Done")
# for svgElem in  BeautifulSoup(response).find_all('svg'):
#     f.write((svgElem.encode('utf-8')))
#     f.write(u"\n".encode('utf-8'))
# f.close()
