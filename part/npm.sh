#!/bin/bash

[ "$PLATFORM" == "win" ] && wbt="windows-build-tools"

npm i -g --production $wbt nodemon gulp aegir pkg http-server npm-check-updates
