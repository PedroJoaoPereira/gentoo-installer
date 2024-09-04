#!/bin/bash

echo -e '\n### Removing installation artifacts...\n'
# reads news items
eselect news read >/dev/null 2>&1
# removes artifacts
rm -rf /helpers
rm /chroot_install_gentoo.sh
rm /post_install_gentoo.sh
rm /stage3-*.tar.*
# sets up yadm
su chuck
yadm clone -b ${THIS_HOST_NAME} ${THIS_DOTFILES_URL} --bootstrap
