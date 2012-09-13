#http://www.codepanel.net/showthread.php?tid=814&pid=1890
import httplib2, time
from BeautifulSoup import BeautifulSoup, SoupStrainer

site = "hackaday.com"
f=open(site+".txt", 'w')
http = httplib2.Http()
i=1
while 1:
    print i
    status, response = http.request("http://"+site+"/page/"+str(i)+"/")
    if str(status)[12:15] == "404":
        import sys;sys.exit("Done")
    for link in BeautifulSoup(response, parseOnlyThese=SoupStrainer('a')):
        if link.has_key('href'):
            if "http://"+site+"/category/" not in link['href'] and link['href'] != "http://"+site+"/contact":
                if site in link['href'] and "?share=" not in link['href'] and "/#comments" in link['href']:
                    f.write(link['href']+"\n")
    time.sleep(0.1)
    i+=1    
f.close()
#see http://codepanel.net for more great source codes!
