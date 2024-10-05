#!/bin/bash

# gets current stage3 metadata
metadata=$(wget -qO- https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/latest-stage3-amd64-openrc.txt)
# gets current stage3 file name
metadata=$(echo $metadata | grep -oE 'stage3-amd64-openrc-[0-9]*T[0-9]*Z.tar.xz')
# gets current stage3 file URL
metadata="https://distfiles.gentoo.org/releases/amd64/autobuilds/current-stage3-amd64-openrc/${metadata}"
# prints out current stage3 file URL
echo $metadata
