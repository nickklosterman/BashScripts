#!/bin/bash

pushd .
/bin/bash /Users/nklosterman/.bash_profile #load up the environment variables holding the api keys
. $HOME/.bash_profile
cd /Users/nklosterman/.personal/nickGit/instagramNodeSandbox/Images/
/Users/nklosterman/.nvm/v0.10.32/bin/node /Users/nklosterman/.personal/nickGit/instagramNodeSandbox/app.js

popd 
touch /private/tmp/instagramheartbeat
