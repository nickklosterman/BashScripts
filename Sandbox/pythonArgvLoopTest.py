import sys
import os.path
 

sysargvlength=len(sys.argv)
i=1
while i <  sysargvlength:
    if os.path.isfile(sys.argv[i]):
        print("%s is a file!" % sys.argv[i])
    else:
        print("%s is NOT a file!" % sys.argv[i])
    i+=1        


for arg in sys.argv:
    if os.path.isfile(arg):
        print("%s is a file!" % arg)
    else:
        print("%s is NOT a file!" % arg)
