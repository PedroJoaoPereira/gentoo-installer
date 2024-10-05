#!/bin/bash

clear
echo -e "
 _                      _ _    _                      
(_)           _        | | |  | |                     
 _ ____   ___| |_  ____| | |  | | _   ____  ___  ____ 
| |  _ \ /___)  _)/ _  | | |  | || \ / _  |/___)/ _  )
| | | | |___ | |_( ( | | | |  | |_) | ( | |___ ( (/ / 
|_|_| |_(___/ \___)_||_|_|_|  |____/ \_||_(___/ \____)
______________________________________________________
"

# creates boot mount point
mkdir -p /efi
mount ${DEVICE}${DEVICE_SEPARATOR}1 /efi

# installs base system
emerge-webrsync
emerge --ask=n --sync --quiet
emerge --oneshot --ask=n app-portage/cpuid2cpuflags
sed -i "s/CPU_FLAGS_X86=\"\"/CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d' ' -f2-)\"/g" /etc/portage/make.conf
emerge --ask=n --update --deep --newuse @world

# configures system
echo 'Europe/Lisbon' >/etc/timezone
emerge --ask=n --config sys-libs/timezone-data
sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
eselect locale set 6
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
