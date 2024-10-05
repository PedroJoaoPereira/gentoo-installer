#!/bin/bash

clear
echo -e "
  ______    __     _                      _ _ _                 _                      _                 _             
 / __   |  / /    (_)           _        | | (_)               | |                _   | |               | |            
| | //| | / /_ ___ _ ____   ___| |_  ____| | |_ ____   ____ ___| | _   ___   ___ | |_ | | ___   ____  _ | | ____  ____ 
| |// | |/ __ (___) |  _ \ /___)  _)/ _  | | | |  _ \ / _  (___) || \ / _ \ / _ \|  _)| |/ _ \ / _  |/ || |/ _  )/ ___)
|  /__| ( (__) )  | | | | |___ | |_( ( | | | | | | | ( ( | |   | |_) ) |_| | |_| | |__| | |_| ( ( | ( (_| ( (/ /| |    
 \_____/ \____/   |_|_| |_(___/ \___)_||_|_|_|_|_| |_|\_|| |   |____/ \___/ \___/ \___)_|\___/ \_||_|\____|\____)_|    
                                                     (_____|                                                           
_______________________________________________________________________________________________________________________
"

# installs firmware, hooks and bootloader
echo 'sys-kernel/linux-firmware @BINARY-REDISTRIBUTABLE' >>/etc/portage/package.license
echo 'sys-kernel/installkernel dracut grub' >>/etc/portage/package.use
emerge --ask=n sys-kernel/linux-firmware sys-kernel/installkernel
grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id='Gentoo Grub Bootloader'
sed -i 's/#GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/#GRUB_CMDLINE_LINUX_DEFAULT=""/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/g' /etc/default/grub
sed -i 's/#GRUB_DISABLE_SUBMENU=y/GRUB_DISABLE_SUBMENU=y/g' /etc/default/grub
