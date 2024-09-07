#!/bin/bash

echo -e '\n### Setting up system...\n'
# sets fstab
cat <<EOF >/etc/fstab
# <fs>                  <mountpoint>        <type>  <opts> <dump> <pass>
# boot partition
${THIS_DISK}${THIS_DISK_SEPARATOR}1          /efi                vfat    umask=0077 0 2
# swap partition
${THIS_DISK}${THIS_DISK_SEPARATOR}2          none                swap    sw 0 0
# root partition
${THIS_DISK}${THIS_DISK_SEPARATOR}3          /                   ext4    defaults,noatime 0 1
EOF
# prints out fstab
cat /etc/fstab
# sets keyboard layout
sed -i 's/keymap="us"/keymap="pt-latin9"/g' /etc/conf.d/keymaps
# sets up openrc services
rc-update add chronyd default
# sets hostname
echo ${THIS_HOST_NAME} >/etc/hostname
cat <<EOF >/etc/hosts
# IPv4 and IPv6 localhost aliases
127.0.0.1       localhost ${THIS_HOST_NAME}
::1             localhost ${THIS_HOST_NAME}
EOF
# print out hostname
cat /etc/hostname

echo -e '\n### Creating users...\n'
# sets root password
passwd <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD
# adds non-root user
useradd -m -G users,wheel,audio,video,usb,plugdev -s /bin/bash chuck
chown -R -c chuck:chuck /home/chuck
# sets non-root user password
passwd chuck <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD
# disables root login
passwd -dl root
# removes extra ttys
sed -i 's/^c[3-6]:/#\0/' /etc/inittab
# sets tty1 auto login
sed -i 's/^c1:12345:respawn:\/sbin\/agetty/\0 -a chuck/' /etc/inittab
