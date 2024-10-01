#!/bin/bash

clear
echo -e "
                                            _                            _ 
                                           | |                          | |
 ____   ____ ____ ____   ____  ____ ____   | |  _ ____  ____ ____   ____| |
|  _ \ / ___) _  )  _ \ / _  |/ ___) _  )  | | / ) _  )/ ___)  _ \ / _  ) |
| | | | |  ( (/ /| | | ( ( | | |  ( (/ /   | |< ( (/ /| |   | | | ( (/ /| |
| ||_/|_|   \____) ||_/ \_||_|_|   \____)  |_| \_)____)_|   |_| |_|\____)_|
|_|              |_|                                                       
___________________________________________________________________________
"
# TODO:
# sets initramfs configuration
mkdir -p /etc/dracut.conf.d
cat <<EOF >/etc/dracut.conf.d/override.conf
${THIS_DRACUT_CONF}
EOF
# installs firmware, hooks and bootloader
echo 'sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE' >>/etc/portage/package.license
echo 'sys-kernel/installkernel dracut grub' >>/etc/portage/package.use
emerge --ask=n sys-kernel/linux-firmware sys-kernel/installkernel
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id='Gentoo Grub Bootloader'
sed -i 's/#GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/g' /etc/default/grub
