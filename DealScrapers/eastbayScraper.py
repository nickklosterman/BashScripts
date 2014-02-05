import urllib.request
import json
#desiredStyles=[ 1051629, 10516415,10516735,1051697]
desiredStyles=[ '1051629', '10516415','10516735','1051697']
priceThreshold=110
shoeUrl="http://www.eastbay.com/product/model:188492/sku:1051624/mizuno-wave-creation-14-mens/black/orange/?cm=GLOBAL%20SEARCH%3A%20KEYWORD%20SEARCH"

socket = urllib.request.urlopen(shoeUrl) #http://www.eastbay.com/product/model:199132/sku:99424008?green=9CB0EEEA-AC14-56AB-B303-ED04C363AFC4&cm=CrossSellMB#sku=99424010&size=09.5")
htmlSource=socket.read() #.decode('utf-8') #reads contents into variable
parsed=htmlSource.decode('utf-8','ignore')
socket.close()
splitHtml=parsed.split('\n')
myList = []
for item in splitHtml:
    if "var styles" in item:
        if (type(item) is str):
            myList.append(item.replace("var styles = ","").replace("};","}")) #strip of beginning and encing variable stuff to get just the json string.

#print(len(myList))
#print(myList[0])

#UnicodeDecodeError: 'utf-8' codec can't decode byte 0xba in position

jsonString=json.loads(myList[0])
for majorkey,subdict in jsonString.items():
    #print(majorkey,subdict)
    #print(type(majorkey))
    #print(len(subdict))
    #print(subdict[7])
    if majorkey in desiredStyles:
        shoeSizeList=subdict[7]
        for item in shoeSizeList:
            if item[0] == ' 09.5':
                if float(item[2])<priceThreshold:
                    print("Product #: %s, Shoe Size: %s, Sale Price: $%s, Style: %s, Fit/Width: %s" % (majorkey,item[0],item[2],subdict[15],subdict[16]))
    
#    for subkey,subdict2 in subdict:
#        print(subkey,subdict2)
#    for subkey,value in subdict:
#        print(subkey,value)
#for item in data_string[""]:
