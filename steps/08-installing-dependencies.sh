#!/bin/bash

clear
echo -e '
  ______  _____     _                      _ _ _                    _                             _                   _            
 / __   |/ ___ \   (_)           _        | | (_)                  | |                           | |                 (_)           
| | //| ( (   ) )__ _ ____   ___| |_  ____| | |_ ____   ____ ___ _ | | ____ ____   ____ ____   _ | | ____ ____   ____ _  ____  ___ 
| |// | |> > < <___) |  _ \ /___)  _)/ _  | | | |  _ \ / _  (___) || |/ _  )  _ \ / _  )  _ \ / || |/ _  )  _ \ / ___) |/ _  )/___)
|  /__| ( (___) )  | | | | |___ | |_( ( | | | | | | | ( ( | |  ( (_| ( (/ /| | | ( (/ /| | | ( (_| ( (/ /| | | ( (___| ( (/ /|___ |
 \_____/ \_____/   |_|_| |_(___/ \___)_||_|_|_|_|_| |_|\_|| |   \____|\____) ||_/ \____)_| |_|\____|\____)_| |_|\____)_|\____|___/ 
                                                      (_____|              |_|                                                     
___________________________________________________________________________________________________________________________________
'

# installs networkmanager
emerge --ask=n net-misc/networkmanager || exit 1
rc-update add elogind boot
rc-update add NetworkManager default

# installs time synchronizer
emerge --ask=n net-misc/chrony || exit 1
rc-update add chronyd default

# installs gentoo tool kits
emerge --ask=n \
  app-admin/eclean-kernel \
  app-portage/gentoolkit \
  sys-block/io-scheduler-udev-rules || exit 1

# installs doas
echo 'app-admin/doas persist' >>/etc/portage/package.use
emerge --ask=n app-admin/doas || exit 1
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf

# sets user
useradd -m -G users,wheel,audio,video,usb,plugdev -s /bin/bash ${THIS_USER}
chown -R -c ${THIS_USER}:${THIS_USER} /home/${THIS_USER}
passwd ${THIS_USER} <<EOF
${THIS_PASSWORD}
${THIS_PASSWORD}
EOF
passwd -dl root
