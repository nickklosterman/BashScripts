#adapeted from http://www.pythoncentral.io/python-beautiful-soup-example-yahoo-finance-scraper/
# sudo pacman -Syu python-beautifulsoup4
from urllib.request import urlopen
 
Url = 'http://finance.yahoo.com/q?s=PRLB' #'http://finance.yahoo.com/q/op?s=AAPL+Options'
Page = urlopen(Url)

from bs4 import BeautifulSoup
soup = BeautifulSoup(Page)
#print(Page)
print(soup)
soup.findAll(text='Prev Close:')
tableData=soup.findAll('td', attrs={'class': 'yfnc_tabledata1'})
tableHeaders=soup.findAll('th', attrs={'scope': 'row'})
#print(tableata)

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

#---- Profiles page
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
print(tabularData)
