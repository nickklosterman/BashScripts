#!/bin/bash
pushd .
cd $HOME/Library/Application Support/Google/Chrome
todaysDate=`date "+%Y-%m-%d"`
tar czvf Default.${todaysDate}.tgz Default/
mv Default.${todaysDate}.tgz $HOME/.personal/Transfer/ProfileBackups/chrome
popd 

