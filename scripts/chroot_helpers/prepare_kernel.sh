#!/bin/bash

echo -e '\n### Installing firmware...\n'
# installs linux-firmware
echo 'sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE' >>/etc/portage/package.license
emerge --ask=n sys-kernel/linux-firmware sys-firmware/sof-firmware
if [ $? -ne 0 ]; then
   echo 'Error installing firmware'
   exit 1
fi

echo -e '\n### Installing hooks...\n'
# sets kernel installation hooks
echo 'sys-kernel/installkernel dracut grub' >>/etc/portage/package.use
emerge --ask=n sys-kernel/installkernel
if [ $? -ne 0 ]; then
   echo 'Error installing hooks'
   exit 1
fi

echo -e '\n### Installing boot modules...\n'
# sets initramfs configuration
mkdir -p /etc/dracut.conf.d
cat <<EOF >/etc/dracut.conf.d/override.conf
${THIS_DRACUT_CONF}
EOF
# installs grub bootloader
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id='Gentoo Grub Bootloader'
if [ $? -ne 0 ]; then
   echo 'Error installing bootloader'
   exit 1
fi
# changes grub configurations for faster boot
sed -i 's/#GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/g' /etc/default/grub
