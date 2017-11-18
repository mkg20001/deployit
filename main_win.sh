#!/bin/bash

[ "$PLATFORM" == "win" ] && wbt="windows-build-tools"

npm i -g --production $wbt nodemon gulp bower aegir pkg http-server npm-check-updates
