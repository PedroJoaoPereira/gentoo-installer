#!/bin/bash

# detects if git is not installed
[[ -z $(command -v git) ]] && echo 'Required command "git" was not found' && exit 1
# detects if wget is not installed
[[ -z $(command -v wget) ]] && echo 'Required command "wget" was not found' && exit 1

# clones project
git clone https://github.com/pedrojoaopereira/gentoo-installer
# runs installer
gentoo-installer/install.sh $1 2>&1 | tee ./install.log
