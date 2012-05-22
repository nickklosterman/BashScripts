

#attempt to parse html
#http://segfault.in/2010/07/parsing-html-table-in-python-with-beautifulsoup/ http://stackoverflow.com/questions/6325216/parse-html-table-to-python-list    
def Parse(inputfilename):
    ss=open(inputfilename,'r')
    for line in ss:
        one=0

def ParseTableData(inputfilename):
    from xml.etree import ElementTree as ET
    s = """<table>
  <tr><th>Event</th><th>Start Date</th><th>End Date</th></tr>
  <tr><td>a</td><td>b</td><td>c</td></tr>
  <tr><td>d</td><td>e</td><td>f</td></tr>
  <tr><td>g</td><td>h</td><td>i</td></tr>
</table>
"""
    ss=open(inputfilename,'r')
    s=ss.read()
    table = ET.XML(s)
    rows = iter(table)
    headers = [col.text for col in next(rows)]
    for row in rows:
        values = [col.text for col in row]
        print dict(zip(headers, values))


########### MAIN ############

inputfilename="/home/nicolae/Git/BashScripts/Rss/Demonoid/rss.php"
ParseTableData(inputfilename)
#Parse(inputfilename)
