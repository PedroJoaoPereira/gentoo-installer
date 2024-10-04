#!/bin/bash

clear
echo -e "
 _                      _ _        _                             _                   _            
(_)           _        | | |      | |                           | |                 (_)           
 _ ____   ___| |_  ____| | |    _ | | ____ ____   ____ ____   _ | | ____ ____   ____ _  ____  ___ 
| |  _ \ /___)  _)/ _  | | |   / || |/ _  )  _ \ / _  )  _ \ / || |/ _  )  _ \ / ___) |/ _  )/___)
| | | | |___ | |_( ( | | | |  ( (_| ( (/ /| | | ( (/ /| | | ( (_| ( (/ /| | | ( (___| ( (/ /|___ |
|_|_| |_(___/ \___)_||_|_|_|   \____|\____) ||_/ \____)_| |_|\____|\____)_| |_|\____)_|\____|___/ 
                                          |_|                                                     
__________________________________________________________________________________________________
"
# installs dependencies
echo 'app-admin/doas persist' >>/etc/portage/package.use
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf
emerge --ask=n \
   app-admin/doas \
   app-admin/eclean-kernel \
   app-editors/neovim \
   app-misc/fastfetch \
   app-portage/gentoolkit \
   dev-vcs/git \
   net-misc/chrony \
   net-misc/keychain \
   sys-block/io-scheduler-udev-rules \
   sys-kernel/gentoo-kernel
