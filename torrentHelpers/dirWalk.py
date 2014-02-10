import os
rootdir='.'

searchfile="LoanCalculatorGUIDriver.class"
searchfile="The Surrogates 04.cbr"
bytesize=19867081

fileList={}
for root, subFolders, files in os.walk(rootdir):
    #print(root,subFolders,files)
    # if searchfile in files:
    #     print(" %s was found in %s and has size: %s bytes. Torrentfile says file size should be %s" % (searchfile,root,os.path.getsize(os.path.join(root,searchfile)),bytesize))
    #     print(os.path.getsize(os.path.join(root,searchfile)))
    #     print(root)#,subFolders)
    for file in files:
        print(file, os.path.getsize(os.path.join(root,file)),os.path.join(root,file))
        filelist[file]=os.path.getsize(os.path.join(root,file))
