#!/bin/bash

clear
echo -e "
  ______  _____      ___ _       _      _     _                 _                      _ _            _             
 / __   |/ ___ \    / __|_)     (_)    | |   (_)               (_)           _        | | |      _   (_)            
| | //| ( (   ) )__| |__ _ ____  _  ___| | _  _ ____   ____ ___ _ ____   ___| |_  ____| | | ____| |_  _  ___  ____  
| |// | |> > < <___)  __) |  _ \| |/___) || \| |  _ \ / _  (___) |  _ \ /___)  _)/ _  | | |/ _  |  _)| |/ _ \|  _ \ 
|  /__| ( (___) )  | |  | | | | | |___ | | | | | | | ( ( | |   | | | | |___ | |_( ( | | | ( ( | | |__| | |_| | | | |
 \_____/ \_____/   |_|  |_|_| |_|_(___/|_| |_|_|_| |_|\_|| |   |_|_| |_(___/ \___)_||_|_|_|\_||_|\___)_|\___/|_| |_|
                                                     (_____|                                                        
____________________________________________________________________________________________________________________
"

# sets system
rc-update add elogind boot
rc-update add chronyd default
rc-update add NetworkManager default
sed -i "s/keymap=\"us\"/keymap=\"${KEYMAP}\"/g" /etc/conf.d/keymaps

# sets mount points
cat <<EOF >/etc/fstab
# <fs> <mountpoint> <type> <opts> <dump> <pass>
# boot partition
${DEVICE}${DEVICE_SEPARATOR}1 /efi vfat umask=0077 0 2
# swap partition
${DEVICE}${DEVICE_SEPARATOR}2 none swap sw 0 0
# root partition
${DEVICE}${DEVICE_SEPARATOR}3 / ext4 defaults,noatime 0 1
EOF

# sets local network
echo ${HOST} >/etc/hostname
cat <<EOF >/etc/hosts
# IPv4 and IPv6 localhost aliases
127.0.0.1       localhost ${HOST}
::1             localhost ${HOST}
EOF

# sets users
useradd -m -G users,wheel,audio,video,usb,plugdev -s /bin/bash ${USER}
chown -R -c ${USER}:${USER} /home/${USER}
passwd <<EOF
${PASSWORD}
${PASSWORD}
EOF
passwd ${USER} <<EOF
${PASSWORD}
${PASSWORD}
EOF
passwd -dl root

# removes useless ttys
sed -i 's/^c[3-6]:/#\0/' /etc/inittab
sed -i "s/^c1:12345:respawn:\/sbin\/agetty/\0 -a ${USER}/" /etc/inittab
