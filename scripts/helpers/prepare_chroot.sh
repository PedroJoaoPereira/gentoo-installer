#!/bin/bash

# creates file from template with expanded variables in a directory
create_file() {
  echo -e "\n### Creating $2 from $1...\n"
  envsubst <$1 >$2
  if [ $? -ne 0 ]; then
    echo 'Error creating file target'
    exit 1
  fi
}

echo -e '\n### Preparing chroot...\n'
# copies DNS information
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
# mounts required filesystems
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
# required on non gentoo live install environments
test -L /dev/shm && rm /dev/shm && mkdir /dev/shm
mount --types tmpfs --options nosuid,nodev,noexec shm /dev/shm
chmod 1777 /dev/shm /run/shm

echo -e '\n### Creating chroot scripts...\n'
# creates chroot scripts directory
mkdir -p /mnt/gentoo/helpers
# creates chroot scripts
create_file "${THIS_SCRIPTS_DIR}/chroot_install_gentoo.sh" "/mnt/gentoo/chroot_install_gentoo.sh"
create_file "${THIS_HOST_DIR}/post_install_gentoo.sh" "/mnt/gentoo/post_install_gentoo.sh"
for file in ${THIS_SCRIPTS_DIR}/chroot_helpers/*.sh; do
  create_file "${file}" "/mnt/gentoo/helpers/$(basename $file)"
done
