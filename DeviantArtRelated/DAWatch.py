import urllib2
import urllib
import cookielib
import sys


def main(username, password):
    # Define urls for later
    loginURL = 'https://www.deviantart.com/users/login'
    watchURL = 'http://my.deviantart.com/deviants/add'
    randomURL = 'http://www.deviantart.com/random/deviant'
    
    cookiez = cookielib.CookieJar()
    opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cookiez))
    login_data = urllib.urlencode({'username' : username, 'password' : password})
    opener.open(loginURL, login_data)
    resp = opener.open(loginURL)
    loginreturn = resp.read()
    
    # Checks for successful log-in
    if "loggedIn" in loginreturn:
        print "Logged in successfully!"
    else:
        print "Log-in failed!"
        sys.exit("Failed to log-in - exiting")
        
    
    while 1:
        # Get a random deviant
        html = urllib2.Request(randomURL)
        hiii = opener.open(html)
        randomreturn = hiii.read()
    
        user = randomreturn
        
        # Find their username in the response
        iuser = user[user.find('<meta name="title" content="') +28:user.find(' on deviantART" />')]
    
        # Add them
        deviousdata = urllib.urlencode({'username' : iuser})
        opener.open(watchURL, deviousdata)
        watchreturn = opener.open(watchURL)
        
        print "Added: " + iuser
   
    
        
        

# Put your username and password here
main("Bithynia", "fluorescenthell")
