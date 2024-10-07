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
echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords
echo 'app-admin/doas persist' >>/etc/portage/package.use

max_attempts=3
attempt_num=1
until emerge --ask=n \
  app-admin/doas \
  app-admin/eclean-kernel \
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
  net-misc/networkmanager \
  sys-block/io-scheduler-udev-rules \
  sys-kernel/gentoo-kernel; do
  if [ ${attempt_num} -eq ${max_attempts} ]; then
    echo "Attempt ${attempt_num} failed! No more attempts left!"
    exit 1
  fi
  echo "Attempt ${attempt_num} failed! Trying again in 5 seconds..."
  attempt_num=$((attempt_num + 1))
  sleep 5
done

# configures doas
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf
