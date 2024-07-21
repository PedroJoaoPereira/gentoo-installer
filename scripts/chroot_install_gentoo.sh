#!/bin/sh

echo "### chroot successfully in disk ${THIS_DISK}..."

# source gentoo default profile
source /etc/profile
export PS1="(chroot) ${PS1}"

# mount boot partition
mkdir -p /efi
mount ${THIS_DISK}${THIS_DISK_SEPARATOR}1 /efi

echo '### Bootstrapping system...'

# install base dependencies
emerge --ask=n --sync
emerge --ask=n --update --deep --newuse @world
emerge --ask=n --depclean

echo '### Configuring system settings...'

# set timezone
echo "Europe/Lisbon" >/etc/timezone
emerge --ask=n --config sys-libs/timezone-data

# set system language
sed -i "s/#en_US ISO-8859-1/en_US ISO-8859-1/g" /etc/locale.gen
sed -i "s/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g" /etc/locale.gen

locale-gen
eselect locale set 6

# refresh profile after system changes
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo '### Installing firmware...'

echo "sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE" >>/etc/portage/package.license
emerge --ask=n sys-kernel/linux-firmware sys-firmware/sof-firmware

echo '### Preparing kernel installation...'

echo "sys-kernel/installkernel dracut grub" >>/etc/portage/package.use
emerge --ask=n sys-kernel/installkernel

# setup initramfs configuration file, though empty
mkdir -p /etc/dracut.conf.d
cat <<EOF >/etc/dracut.conf.d/override.conf
EOF

echo '### Installing bootloader...'

# install grub in boot partition
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id="Gentoo Grub Bootloader"

# change grub configurations for faster boot
sed -i 's/#GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/g' /etc/default/grub

echo '### Installing dependencies...'

# settings for doas
echo "app-admin/doas persist" >>/etc/portage/package.use
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf

# personal base system dependencies
emerge --ask=n \
  app-admin/doas \
  app-admin/eclean-kernel \
  app-admin/yadm \
  app-editors/neovim \
  app-misc/fastfetch \
  app-portage/gentoolkit \
  dev-vcs/git \
  net-misc/chrony \
  net-misc/keychain \
  sys-block/io-scheduler-udev-rules \
  sys-kernel/gentoo-kernel \
  sys-process/btop \
  sys-process/cronie

# mark all news as read
eselect news read

# set fstab
cat <<EOF >/etc/fstab
# <fs>                  <mountpoint>        <type>  <opts> <dump> <pass>
# boot partition
${THIS_DISK}${THIS_DISK_SEPARATOR}1          /efi                vfat    umask=0077 0 2
# swap partition
${THIS_DISK}${THIS_DISK_SEPARATOR}2          none                swap    sw 0 0
# root partition
${THIS_DISK}${THIS_DISK_SEPARATOR}3          /                   ext4    defaults,noatime 0 1
EOF

# set hostname
echo ${THIS_HOST_NAME} >/etc/hostname
cat <<EOF >/etc/hosts
# IPv4 and IPv6 localhost aliases
127.0.0.1       localhost ${THIS_HOST_NAME}
::1             localhost ${THIS_HOST_NAME}
EOF

# set root password
passwd <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD

# set keyboard layout
sed -i 's/keymap="us"/keymap="pt-latin9"/g' /etc/conf.d/keymaps

# set up openrc services
rc-update add NetworkManager default
rc-update add cronie default
rc-update add chronyd default
rc-update add sshd default
rc-update add numlock default

echo '### Creating new user...'

# add new user with minimal permissions
useradd -m -G users,wheel,plugdev,audio,video,input -s /bin/bash chuck
chown -R -c chuck:chuck /home/chuck

# set user password
passwd chuck <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD

# disable root login
passwd -l root

echo '### Finalizing installation...'

# remove artifacts
rm /chroot_install_gentoo.sh
rm /stage3-*.tar.*

# remove extra ttys
sed -i 's/^c[3-6]:/#\0/' /etc/inittab
# set tty1 auto login
sed -i 's/^c1:12345:respawn:\/sbin\/agetty/\0 -a chuck/' /etc/inittab

# set yadm
su chuck
yadm clone ${THIS_DOTFILES_URL} --no-bootstrap

# running exit leaves this script
# only run it if you want to leave the chroot script
exit
