#!/bin/python2

# http://stackoverflow.com/questions/406695/reading-the-fileset-from-a-torrent 
import re
import sys


def tokenize(text, match=re.compile("([idel])|(\d+):|(-?\d+)").match):
    i = 0
    while i < len(text):
        m = match(text, i)
        s = m.group(m.lastindex)
        i = m.end()
        if m.lastindex == 2:
            yield "s"
            yield text[i:i+int(s)]
            i = i + int(s)
        else:
            yield s

def decode_item(next, token):
    if token == "i":
        # integer: "i" value "e"
        data = int(next())
        if next() != "e":
            raise ValueError
    elif token == "s":
        # string: "s" value (virtual tokens)
        data = next()
    elif token == "l" or token == "d":
        # container: "l" (or "d") values "e"
        data = []
        tok = next()
        while tok != "e":
            data.append(decode_item(next, tok))
            tok = next()
        if token == "d":
            data = dict(zip(data[0::2], data[1::2]))
    else:
        raise ValueError
    return data

def decode(text):
    try:
        src = tokenize(text)
        data = decode_item(src.next, src.next())
        for token in src: # look for more tokens
            raise SyntaxError("trailing junk")
    except (AttributeError, ValueError, StopIteration):
        raise SyntaxError("syntax error")
    return data


import sys
if __name__ == "__main__":
    print("-------THIS MUST BE RUN WITH PYTON 2 -----")
    totalArgs=len(sys.argv)
    filelist=sys.argv[1:] #strip off the actual program's name
    print(filelist)
    for filename in filelist:
        data = open(filename, "rb").read()
        torrent = decode(data)
#        print(torrent["name"])
        
        if "info" in torrent and "files" in torrent["info"]:
            for file in torrent["info"]["files"]:
                print("%r - %d bytes" % ("/".join(file["path"]), file["length"]))
        else:
            print(torrent["name"])
    
