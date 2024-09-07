#!/bin/bash

echo -e '\n### Installing dependencies...\n'
echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords
echo 'app-admin/doas persist' >>/etc/portage/package.use
# installs dependencies
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
if [ $? -ne 0 ]; then
   echo 'Error installing dependencies'
   exit 1
fi
# reads news items
eselect news read >/dev/null 2>&1
# sets doas configuration
cat <<EOF >/etc/doas.conf
# https://wiki.gentoo.org/wiki/Doas
permit  persist :wheel
permit  nopass  :wheel as root  cmd shutdown
permit  nopass  :wheel as root  cmd reboot
EOF
chown -c root:root /etc/doas.conf
