#!/bin/bash

clear
echo -e "
  ______ _______    _                      _ _ _                    _                             _                   _            
 / __   (_______)  (_)           _        | | (_)                  | |                           | |                 (_)           
| | //| |     _ ___ _ ____   ___| |_  ____| | |_ ____   ____ ___ _ | | ____ ____   ____ ____   _ | | ____ ____   ____ _  ____  ___ 
| |// | |    / |___) |  _ \ /___)  _)/ _  | | | |  _ \ / _  (___) || |/ _  )  _ \ / _  )  _ \ / || |/ _  )  _ \ / ___) |/ _  )/___)
|  /__| |   / /    | | | | |___ | |_( ( | | | | | | | ( ( | |  ( (_| ( (/ /| | | ( (/ /| | | ( (_| ( (/ /| | | ( (___| ( (/ /|___ |
 \_____/   (_/     |_|_| |_(___/ \___)_||_|_|_|_|_| |_|\_|| |   \____|\____) ||_/ \____)_| |_|\____|\____)_| |_|\____)_|\____|___/ 
                                                      (_____|              |_|                                                     
___________________________________________________________________________________________________________________________________
"

# installs dependencies
echo 'app-admin/doas persist' >>/etc/portage/package.use
emerge --ask=n \
  app-admin/eclean-kernel \
  app-portage/gentoolkit \
  dev-vcs/git \
  net-misc/chrony \
  sys-block/io-scheduler-udev-rules \
  sys-kernel/gentoo-kernel \
  app-admin/doas || exit 1

# configures doas
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf
