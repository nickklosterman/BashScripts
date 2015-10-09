#!/bin/bash
pushd .
cd $HOME/Library/Application\ Support/Firefox/Profiles
todaysDate=`date "+%Y-%m-%d"`
tar czvf da1wz8yd.default.${todaysDate}.tgz da1wz8yd.default/
mv da1wz8yd.default.${todaysDate}.tgz $HOME/.personal/Transfer/ProfileBackups/firefox
popd 
