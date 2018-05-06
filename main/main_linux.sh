#!/bin/bash

set -x

sudo open

main() { # wrapper to avoid some bash errors
  include part/smc
  include part/pkg_linux
  include part/cjdns
  include part/atom
  include part/npm
  include part/ipfs
}
