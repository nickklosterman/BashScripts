#from: http://stackoverflow.com/questions/17766300/how-do-i-catch-a-404-error-in-urllib-python-3
import urllib
import datetime
from bs4 import BeautifulSoup

class EarningsAnnouncement:
    def __init__(self, Company, Ticker, EPSEst, AnnouncementDate, AnnouncementTime):
        self.Company = Company
        self.Ticker = Ticker
        self.EPSEst = EPSEst
        self.AnnouncementDate = AnnouncementDate
        self.AnnouncementTime = AnnouncementTime

webBaseStr = 'http://biz.yahoo.com/research/earncal/'
earningsAnnouncements = []
dayVar = datetime.date.today()
for dte in range(1, 30):
    currDay = str(dayVar.day)
    currMonth = str(dayVar.month)
    currYear = str(dayVar.year)
    if (len(currDay)==1): currDay = '0' + currDay
    if (len(currMonth)==1): currMonth = '0' + currMonth
    dateStr = currYear + currMonth + currDay
    webString = webBaseStr + dateStr + '.html'
    try:
        #with urllib.request.urlopen(webString) as url: page = url.read()
        page = urllib.request.urlopen(webString).read()
        soup = BeautifulSoup(page)
        tbls = soup.findAll('table')
        tbl6= tbls[6]
        rows = tbl6.findAll('tr')
        rows = rows[2:len(rows)-1]
        for earn in rows:
            earningsAnnouncements.append(EarningsAnnouncement(earn.contents[0], earn.contents[1],
            earn.contents[3], dateStr, earn.contents[3]))
    except urllib.HTTPError as err:
        if err.code == 404:
            continue
        else:
            raise

    dayVar += datetime.timedelta(days=1)
