#!/bin/sh

echo -e "\n### chroot successfully into disk ${THIS_DISK}${THIS_DISK_SEPARATOR}3...\n"

# source gentoo default profile
source /etc/profile
export PS1="(chroot) ${PS1}"

echo -e "\n### Mounting boot partition ${THIS_DISK}${THIS_DISK_SEPARATOR}1...\n"

# mount boot partition
mkdir -p /efi
mount ${THIS_DISK}${THIS_DISK_SEPARATOR}1 /efi
if [ $? -ne 0 ]; then
  echo 'Error mounting BOOT partition'
  exit 1
fi

echo -e '\n### Bootstrapping system...\n'

# install base dependencies
emerge-webrsync
if [ $? -ne 0 ]; then
  echo 'Error updating portage'
  exit 1
fi

emerge --ask=n --sync --quiet
if [ $? -ne 0 ]; then
  echo 'Error updating portage'
  exit 1
fi

emerge --ask=n --update --deep --newuse @world
if [ $? -ne 0 ]; then
  echo 'Error upgrading portage'
  exit 1
fi

emerge --ask=n --depclean
if [ $? -ne 0 ]; then
  echo 'Error cleaning portage'
  exit 1
fi

eselect news read >/dev/null 2>&1

echo -e '\n### Configuring system settings...\n'

# set timezone
echo 'Europe/Lisbon' >/etc/timezone
emerge --ask=n --config sys-libs/timezone-data
if [ $? -ne 0 ]; then
  echo 'Error generating timezone'
  exit 1
fi

# set system language
sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen
if [ $? -ne 0 ]; then
  echo 'Error generating locale'
  exit 1
fi

eselect locale set 6
if [ $? -ne 0 ]; then
  echo 'Error selecting locale'
  exit 1
fi

echo -e '\n### Updating system environment variables...\n'

# refresh profile after system changes
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

echo -e '\n### Installing firmware...\n'

echo 'sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE' >>/etc/portage/package.license
emerge --ask=n sys-kernel/linux-firmware sys-firmware/sof-firmware
if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi

eselect news read >/dev/null 2>&1

echo -e '\n### Preparing kernel installation...\n'

echo 'sys-kernel/installkernel dracut grub' >>/etc/portage/package.use
emerge --ask=n sys-kernel/installkernel
if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi

eselect news read >/dev/null 2>&1

# setup initramfs configuration file, though empty
mkdir -p /etc/dracut.conf.d
cat <<EOF >/etc/dracut.conf.d/override.conf
EOF

echo -e '\n### Installing bootloader...\n'

# install grub in boot partition
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id='Gentoo Grub Bootloader'
if [ $? -ne 0 ]; then
  echo 'Error installing bootloader'
  exit 1
fi

# change grub configurations for faster boot
sed -i 's/#GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/g' /etc/default/grub

echo -e '\n### Installing dependencies...\n'

# settings for doas
echo 'app-admin/doas persist' >>/etc/portage/package.use
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf

# personal base system dependencies
echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords

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
  sys-kernel/gentoo-kernel \
  sys-process/btop \
  sys-process/cronie

if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi

eselect news read >/dev/null 2>&1

echo -e '\n### Setting fstab...\n'

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

# print out file
cat /etc/fstab

echo -e '\n### Setting hostname...\n'

# set hostname
echo ${THIS_HOST_NAME} >/etc/hostname
cat <<EOF >/etc/hosts
# IPv4 and IPv6 localhost aliases
127.0.0.1       localhost ${THIS_HOST_NAME}
::1             localhost ${THIS_HOST_NAME}
EOF

# print out file
cat /etc/hostname

echo -e '\n### Setting root password...\n'

# set root password
passwd <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD

echo -e '\n### Setting keyboard layout...\n'

# set keyboard layout
sed -i 's/keymap="us"/keymap="pt-latin9"/g' /etc/conf.d/keymaps

echo -e '\n### Adding services to openrc...\n'

# set up openrc services
rc-update add NetworkManager default
rc-update add cronie default
rc-update add chronyd default
rc-update add sshd default
rc-update add numlock default

echo -e '\n### Creating new admin user...\n'

# add new user with minimal permissions
useradd -m -G users,wheel,plugdev,audio,video,input -s /bin/bash chuck
chown -R -c chuck:chuck /home/chuck

# set user password
passwd chuck <<EOD
${THIS_PASSWORD}
${THIS_PASSWORD}
EOD

echo -e '\n### Disabling root login...\n'

# disable root login
passwd -l root

echo -e '\n### Post installation setup...\n'

. /post_install_gentoo.sh

echo -e '\n### Removing installation artifacts...\n'

# remove artifacts
rm /chroot_install_gentoo.sh
rm /post_install_gentoo.sh
rm /stage3-*.tar.*

echo -e '\n### Changing system settings...\n'

# remove extra ttys
sed -i 's/^c[3-6]:/#\0/' /etc/inittab
# set tty1 auto login
sed -i 's/^c1:12345:respawn:\/sbin\/agetty/\0 -a chuck/' /etc/inittab

echo -e '\n### Pulling dotfiles repository...\n'

# set yadm
su chuck
yadm clone ${THIS_DOTFILES_URL} --no-bootstrap

# running exit leaves this script
# only run it if you want to leave the chroot script
exit
