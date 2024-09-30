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
envsubst <"${STEPS_DIR}/05-xxx.sh" >"/mnt/gentoo/installation-scripts/chroot_install_gentoo.sh"

# TODO
envsubst <$1 >$2

# creates file from template with expanded variables in a directory
create_file() {
  envsubst <$1 >$2
}

echo -e '\n### Preparing chroot...\n'

# copies DNS information
# mounts required filesystems
# required on non gentoo live install environments

echo -e '\n### Creating chroot scripts...\n'
# creates chroot scripts directory
create_file "${THIS_SCRIPTS_DIR}/chroot_install_gentoo.sh" "/mnt/gentoo/chroot_install_gentoo.sh"
create_file "${THIS_HOST_DIR}/post_install_gentoo.sh" "/mnt/gentoo/post_install_gentoo.sh"
for file in ${THIS_SCRIPTS_DIR}/chroot_helpers/*.sh; do
  create_file "${file}" "/mnt/gentoo/helpers/$(basename $file)"
done
