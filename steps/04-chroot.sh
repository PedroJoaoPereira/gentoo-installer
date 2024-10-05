#!/bin/bash

clear
echo -e "
       _                           
      | |                     _    
  ____| | _   ____ ___   ___ | |_  
 / ___) || \ / ___) _ \ / _ \|  _) 
( (___| | | | |  | |_| | |_| | |__ 
 \____)_| |_|_|   \___/ \___/ \___)
___________________________________
"

# mounts system
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm /run/shm

# creates chroot scripts
mkdir -p /mnt/gentoo/installation-scripts
envsubst <"${STEPS_DIR}/05-install-base.sh" >"/mnt/gentoo/installation-scripts/05-install-base.sh"
envsubst <"${STEPS_DIR}/06-prepare-kernel.sh" >"/mnt/gentoo/installation-scripts/06-prepare-kernel.sh"
envsubst <"${STEPS_DIR}/07-install-dependencies.sh" >"/mnt/gentoo/installation-scripts/07-install-dependencies.sh"
envsubst <"${STEPS_DIR}/08-finish-installation.sh" >"/mnt/gentoo/installation-scripts/08-finish-installation.sh"

# chroots into system
chroot /mnt/gentoo /bin/bash <<EOF
source /etc/profile
export PS1="(chroot) ${PS1}"

source /installation-scripts/05-install-base.sh
source /installation-scripts/06-prepare-kernel.sh
source /installation-scripts/07-install-dependencies.sh
source /installation-scripts/08-finish-installation.sh

eselect news read >/dev/null 2>&1
emerge --ask=n --depclean
eclean distfiles
eclean packages
eclean-kernel -n 2

rm /stage3-*.tar.*
rm -rf /installation-scripts
EOF
