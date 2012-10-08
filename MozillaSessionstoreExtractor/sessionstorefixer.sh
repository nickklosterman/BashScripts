#!/bin/bash
sed 's/\],"selectedWindow":0,"_closedWindows":\[//' $1 > sessionstore.js
