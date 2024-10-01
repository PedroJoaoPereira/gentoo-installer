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
echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords
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
   app-admin/stow \
   app-admin/yadm \
   app-editors/neovim \
   app-misc/fastfetch \
   app-portage/gentoolkit \
   app-shells/starship \
   app-shells/zoxide \
   dev-vcs/git \
   net-misc/chrony \
   net-misc/keychain \
   sys-apps/eza \
   sys-block/io-scheduler-udev-rules \
   sys-kernel/gentoo-kernel
eselect news read >/dev/null 2>&1
