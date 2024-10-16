#!/bin/bash

# detects if git is installed
if ! command -v git &>/dev/null; then
  echo 'Required command "git" was not found'
  exit 1
fi

# detects if wget is installed
if ! command -v wget &>/dev/null; then
  echo 'Required command "wget" was not found'
  exit 1
fi

# clones project
git clone https://github.com/pedrojoaopereira/gentoo-installer
# runs installer
gentoo-installer/install.sh $1 2>&1 | tee ./install.log
