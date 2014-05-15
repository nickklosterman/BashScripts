#!/bin/python3
"""
This program parses the package.json file and looks in your node_modules directory 
and removes any directories in node_modules that don't have corresponding entries
in the package.json file.
"""
import json
import shutil
import os

def getDependencies():
    dependenciesList=[]
    try:
        filehandle=open('package.json','r')
        contents=filehandle.read();
        jsonString=json.loads(contents)
        for majorkey,subdict in jsonString.items():
            if majorkey=='dependencies':
#        print(subdict)
#        print(type(subdict))
#        print(jsonString)
#        print(type(jsonString.items()))
                for minorkey,minordict in subdict.items():
                    print(minorkey)
                    dependenciesList.append(minorkey)
        print(dependenciesList)
#        print(type(dependenciesList))
        return dependenciesList
    except IOError:
        print("skipping, no package.json exists in this directory")
        return dependenciesList

def getDirectoryListing():
    directory='node_modules'
    try:
        dirList= [f for f in os.listdir(directory)
                  if os.path.isdir(os.path.join(directory, f))]
        print(dirList)
        return dirList
    except IOError:
        print("There is no node_modules directory here.")
        return []

def main():
    depList=getDependencies()
    dirList=getDirectoryListing()
    removalList=[x for x in dirList if x not in depList]
    print(removalList)
    for item in removalList:
        shutil.rmtree('node_modules/'+item)

if __name__ == '__main__':
    main()
