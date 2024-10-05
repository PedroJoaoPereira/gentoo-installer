#!/bin/bash

clear
echo -e "
  ______   __             _                           
 / __   | / /            | |                     _    
| | //| |/ /____ ___ ____| | _   ____ ___   ___ | |_  
| |// | |___   _|___) ___) || \ / ___) _ \ / _ \|  _) 
|  /__| |   | |    ( (___| | | | |  | |_| | |_| | |__ 
 \_____/    |_|     \____)_| |_|_|   \___/ \___/ \___)
______________________________________________________
"

# mounts system
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
mount --types proc /proc /mnt/gentoo/proc || exit 1
mount --rbind /sys /mnt/gentoo/sys || exit 1
mount --make-rslave /mnt/gentoo/sys || exit 1
mount --rbind /dev /mnt/gentoo/dev || exit 1
mount --make-rslave /mnt/gentoo/dev || exit 1
mount --bind /run /mnt/gentoo/run || exit 1
mount --make-slave /mnt/gentoo/run || exit 1
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm || exit 1
chmod 1777 /dev/shm /run/shm

# creates chroot scripts
mkdir -p /mnt/gentoo/installation-scripts
envsubst <"${STEPS_DIR}/05-installing-base.sh" >"/mnt/gentoo/installation-scripts/05-installing-base.sh"
envsubst <"${STEPS_DIR}/06-installing-bootloader.sh" >"/mnt/gentoo/installation-scripts/06-installing-bootloader.sh"
envsubst <"${STEPS_DIR}/07-installing-dependencies.sh" >"/mnt/gentoo/installation-scripts/07-installing-dependencies.sh"
envsubst <"${STEPS_DIR}/08-finishing-installation.sh" >"/mnt/gentoo/installation-scripts/08-finishing-installation.sh"
if [[ ! -z $1 ]]; then
  envsubst <$1 >"/mnt/gentoo/installation-scripts/09-installing-extras.sh"
fi

# chroots into system
chroot /mnt/gentoo /bin/bash <<EOF
source /etc/profile
export PS1="(chroot) ${PS1}"

source /installation-scripts/05-installing-base.sh
source /installation-scripts/06-installing-bootloader.sh
source /installation-scripts/07-installing-dependencies.sh
source /installation-scripts/08-finishing-installation.sh
[[ -f /installation-scripts/09-installing-extras.sh ]] && source /installation-scripts/09-installing-extras.sh

eselect news read >/dev/null 2>&1 || exit 1
emerge --ask=n --depclean || exit 1
eclean distfiles || exit 1
eclean packages || exit 1
eclean-kernel -n 2 || exit 1

rm /stage3-*.tar.*
rm -rf /installation-scripts
EOF
