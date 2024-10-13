#!/bin/bash

# clones project
git clone https://github.com/pedrojoaopereira/gentoo-installer
# runs installer
gentoo-installer/install.sh $1 2>&1 | tee ./install.log
# removes artifacts
rm -rf gentoo-installer
