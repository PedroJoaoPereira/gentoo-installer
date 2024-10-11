#!/bin/bash

function check-and-install-dependencies() {
  # iterates all dependencies in list
  for dep in "$@"; do
    # checks if command argument is installed
    if ! command -v $dep &>/dev/null; then
      # installs command argument
      apt install $dep -y
    fi
  done
}

# runs as root
sudo su
# sets up dependencies
check-and-install-dependencies tee wget git
# clones project
git clone https://github.com/pedrojoaopereira/gentoo-installer
# runs installer
gentoo-installer/install.sh $1 2>&1 | tee ./install.log
# removes artifacts
rm -rf gentoo-installer
