#!/bin/bash

set -x

main() { # wrapper to avoid some bash errors
  include part/atom
  include part/npm
  include part/ipfs

  sleep 1m

  rm -rf /c/script-tmp
  rm /c/dostuff.sh
  exit 0
}

main
