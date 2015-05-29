#!/bin/bash

pushd .
/bin/bash /Users/nklosterman/.bash_profile #load up the environment variables holding the api keys
. $HOME/.bash_profile
cd /Users/nklosterman/.personal/nickGit/tumblrNodeSandbox/tumblr.jsTest/Images/
/bin/bash /Users/nklosterman/.personal/nickGit/tumblrNodeSandbox/tumblr.jsTest/driverScript.sh

popd
touch /private/tmp/tumblrheartbeat
