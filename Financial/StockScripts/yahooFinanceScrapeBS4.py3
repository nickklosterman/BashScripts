# -*- python -*-
#adapeted from http://www.pythoncentral.io/python-beautiful-soup-example-yahoo-finance-scraper/
# sudo pacman -Syu python-beautifulsoup4



#from http://stackoverflow.com/questions/354038/how-do-i-check-if-a-string-is-a-number-in-python
def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

#returns a float if the string value is/can be converted to a number, otherwise returns the string
def ret_number(s):
    try:
        a=float(s)
        return a
    except ValueError:
        return s


import getopt, sys
print(sys.argv[1:])
#pretty much straight from : http://docs.python.org/release/3.1.5/library/getopt.html                                                                                        
#took me a while to catch that for py3k that you don't need the leading -- for the long options                                                                              
#sadly optional options aren't allowed. says it in the docs :( http://docs.python.org/3.3/library/getopt.html                                             
try:
    options, remainder = getopt.gnu_getopt(sys.argv[1:], 'c:t:', [
                                                                    'compare',
                                                                    'stocktable='
                                                                ])
except getopt.GetoptError as err:
    # print help information and exit:                                                                                                                                       
    print( str(err)) # will print something like "option -a not recognized"                                                                                                 
    usage()
    sys.exit(2)

for opt, arg in options:
    if opt in ('-c', '--compare'):
        comparisonflag=True
    elif opt in ('-t', '--ticker'):
        ticker=arg
    else:
        assert False, "unhandled option"


from urllib.request import urlopen
 
Url = 'http://finance.yahoo.com/q?s='+ticker #'http://finance.yahoo.com/q/op?s=AAPL+Options'
Page = urlopen(Url)

from bs4 import BeautifulSoup
soup = BeautifulSoup(Page)
#print(Page)
#print(soup)
soup.findAll(text='Prev Close:')
tableData=soup.findAll('td', attrs={'class': 'yfnc_tabledata1'})
tableHeaders=soup.findAll('th', attrs={'scope': 'row'})
#print(tableata)

data=[]
headers=[]
#append each to a list then zip them together 
for item in tableHeaders:
    #print(item.findAll(text=True))
    title=item.findAll(text=True)[0] #without the trailing [0] we are then inserting lists,instead of elements
    headers.append(title.rstrip(" :"))#remove trailing :   #item.findAll(text=True)[0]) #without the trailing [0] we are then inserting lists,instead of elements
    #print(item)

for item in tableData:
    #print(item.findAll(text=True))
    value=item.findAll(text=True)[0]   # I could determine whether the value is an integer and not just a float, but then JS would just end up turning it back into a flaot anyway. Mongo might care a bit more though. 
    data.append(ret_number(value.replace(",",""))) #item.findAll(text=True)[0])



print("------zipped=======")
zipped=dict(zip(headers,data))  #removing the dict vastly changes how things are operated , we then have a dict of bs4.element.NavigableString
#zipped=(zip(headers,data))  #removing the dict vastly changes how things are operated , we then have a zip of tuples
#print(zipped) # prints out address of object
print("------zipped items=======")
zipped["ticker"]=ticker
print(type(zipped))
# for item in zipped:
#     print(type(item))
#     print(item)
#     print(item[0][:-1],"-=-",item[1]) #use :-1 to strip trailing : 
#     for i in item:
#         print(i)

for k,v in zipped.items():
    print(k,"--",v)

print("------zipped items2=======")
# for item in zipped:
#     #print(type(item))
#     #print(item[0],item[1])
#     print(item)
#     for i in item:
#         print(i)
    
print("------json=======")
import json 
print(json.dumps(zipped))
#for item in zipped:
#    print(json.dumps(item))
#print(json.dumps(zipped))

print("------dict=======")
dictionary= dict(zipped)
print(dictionary)

#---- Profiles page
print('================== Profiles ===============')
Url='http://finance.yahoo.com/q/pr?s=PRLB+Profile'
Page=urlopen(Url)

soup = BeautifulSoup(Page)
tableData=soup.findAll('td', attrs={'class': 'yfnc_tabledata1'})
tableHeaders=soup.findAll('td', attrs={'class':'yfnc_tablehead1'})


# for item in tableHeaders:
#     print(item.findAll(text=True))
#     #print(item)

# for item in tableData:
#     print(item.findAll(text=True))
#     #print(item)

#this one *ALMOST* works, it breaks on the pay items and exercising of pay and options. 
data=[]
headers=[]
#append each to a list then zip them together 
for item in tableHeaders:
    #print(item.findAll(text=True))
    headers.append(item.findAll(text=True))
    #print(item)

for item in tableData:
    #print(item.findAll(text=True))
    data.append(item.findAll(text=True))

zipped=zip(headers,data)
for item in zipped:
    print(item)

#need to strip out extraneous stuff
address=soup.findAll('td',attrs={'width':'270', 'class':'yfnc_modtitlew1'})
print(address)

#this is done
businessSummary=soup.findAll('p')
print(businessSummary[2].findAll(text=True))

#-----------------
#---- Key Stats page
print('================== Key Stat===============')

Url='http://finance.yahoo.com/q/ks?s=PRLB+Key+Statistics'
Page=urlopen(Url)

soup = BeautifulSoup(Page)
tableData=soup.findAll('td', attrs={'class': 'yfnc_tabledata1'})
tableHeaders=soup.findAll('td', attrs={'class':'yfnc_tablehead1'})


# for item in tableHeaders:
#     print(item.findAll(text=True))
#     #print(item)

# for item in tableData:
#     print(item.findAll(text=True))
#     #print(item)

#
data=[]
headers=[]
#append each to a list then zip them together 
for item in tableHeaders:
    #print(item.findAll(text=True))
    headers.append(item.findAll(text=True))
    #print(item)

for item in tableData:
    #print(item.findAll(text=True))
    data.append(item.findAll(text=True))

zipped=zip(headers,data)
for item in zipped:
    print(item)

#the superscripts appear as separate elements in the headers field. could just do 
# item[0] in headers to just get the title. 
#-----------------

print('================== Financials ===============')
#Income Statements
Url='http://finance.yahoo.com/q/is?s=PRLB+Income+Statement&annual'
#Url='http://finance.yahoo.com/q/is?s=PRLB' #quarterly
#Balance Sheets
Url='http://finance.yahoo.com/q/bs?s=PRLB'
#Url='http://finance.yahoo.com/q/bs?s=PRLB&annual'
#Cash Flow
Url='http://finance.yahoo.com/q/cf?s=PRLB+Cash+Flow&annual'
#Url='http://finance.yahoo.com/q/cf?s=PRLB'

Page=urlopen(Url)

soup = BeautifulSoup(Page)

#tabularData=soup.findAll('table', attrs={'border':"0", 'cellpadding':"2", 'cellspacing':"1", 'width':"100%",'class':'yfunc_tabledata1'})
#tabularData=soup.findAll('TABLE', attrs={'border':'0', 'cellpadding':'0', 'cellspacing':'0', 'width':'100%','class':'yfnc_tabledata1'})
tabularData=soup.findAll('table', attrs={'class':'yfnc_tabledata1'})
#print(tabularData)
