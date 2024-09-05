#!/bin/bash

echo -e '\n### Creating build profiles...\n'
# core2 build profile
echo 'CFLAGS="${CFLAGS} -march=core2"' >>/etc/portage/env/march-core2
echo 'CXXFLAGS="${CXXFLAGS} -march=core2"' >>/etc/portage/env/march-core2

echo -e '\n### Installing extra dependencies...\n'
echo 'net-libs/nodejs march-core2' >>/etc/portage/package.env
echo 'app-editors/vscode Microsoft-vscode' >>/etc/portage/package.license
echo 'net-im/discord all-rights-reserved' >>/etc/portage/package.license
echo 'sys-firmware/intel-microcode intel-ucode' >>/etc/portage/package.license
echo 'www-client/google-chrome google-chrome' >>/etc/portage/package.license
# installs dependencies
emerge --ask=n \
  app-editors/vscode \
  gnome-base/gnome-light \
  net-im/discord \
  sys-firmware/intel-microcode \
  www-client/google-chrome
if [ $? -ne 0 ]; then
  echo 'Error installing extra dependencies'
  exit 1
fi
# reads news items
eselect news read >/dev/null 2>&1
# reloads environment variables
env-update && source /etc/profile
# sets up openrc services
rc-update add elogind boot
