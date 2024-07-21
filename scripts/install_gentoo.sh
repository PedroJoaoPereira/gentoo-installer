#!/bin/sh

# halts execution if THIS_HOST_NAME is not defined or empty
if [ -z "$THIS_HOST_NAME" ]; then
   echo "THIS_HOST_NAME is not defined or empty!"
   exit 1
fi
# halts execution if THIS_PASSWORD is not defined or empty
if [ -z "$THIS_PASSWORD" ]; then
   echo "THIS_PASSWORD is not defined or empty!"
   exit 1
fi
# halts execution if THIS_DISK is not defined or empty
if [ -z "$THIS_DISK" ]; then
   echo "THIS_DISK is not defined or empty!"
   exit 1
fi
# halts execution if THIS_EFI_SIZE, or THIS_SWAP_SIZE, or THIS_ROOT_SIZE is not defined or empty
if [ -z "$THIS_EFI_SIZE" ] || [ -z "$THIS_SWAP_SIZE" ] || [ -z "$THIS_ROOT_SIZE" ]; then
   echo "THIS_EFI_SIZE, THIS_SWAP_SIZE, or THIS_ROOT_SIZE is not defined or empty!"
   exit 1
fi

echo "### Formatting disk ${THIS_DISK}..."

# note that a blank line (commented as "default")
# will send an empty line terminated with a newline to take the fdisk default
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk ${THIS_DISK}
  g  # create empty GPT partition table
  n  # create EFI partition
     # choose default partition number
     # choose default sector number
  ${THIS_EFI_SIZE}
  y  # remove signature if it exists
  t  # create EFI partition type
  1  # EFI system type
  n  # create SWAP partition
     # choose default partition number
     # choose default sector number
  ${THIS_SWAP_SIZE}
  y  # remove signature if it exists
  t  # create SWAP partition type
     # choose default partition number
  19 # Linux swap type
  n  # create ROOT partition
     # choose default partition number
     # choose default sector number
  ${THIS_ROOT_SIZE}
  y  # remove signature if it exists
  t  # create ROOT partition type
     # choose default partition number
  23 # Linux root (x86-64) type
  ${THIS_EXTRA_LAYOUT}
  w  # write changes to disk
  p  # print disk partition table
  q  # quit
EOF

# print out all the partitions of the disk
fdisk -l ${THIS_DISK}

echo "### Creating filesystems in ${THIS_DISK}..."

# fat32 BOOT
mkfs.vfat -F 32 ${THIS_DISK}${THIS_DISK_SEPARATOR}1

# linux-swap SWAP
mkswap ${THIS_DISK}${THIS_DISK_SEPARATOR}2
swapon ${THIS_DISK}${THIS_DISK_SEPARATOR}2

# ext4 ROOT
mkfs.ext4 ${THIS_DISK}${THIS_DISK_SEPARATOR}3 <<EOD
y
EOD

# create extra filesystems
eval $THIS_EXTRA_FILESYSTEMS

# create mount points
mkdir -p /mnt/gentoo
mount ${THIS_DISK}${THIS_DISK_SEPARATOR}3 /mnt/gentoo
cd /mnt/gentoo

echo '### Downloading stage file...'

# download and extract stage files
wget ${THIS_STAGE3_FILE}
tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# create base portage configurations
rm -rf /mnt/gentoo/etc/portage/package.*

touch /mnt/gentoo/etc/portage/package.accept_keywords
touch /mnt/gentoo/etc/portage/package.license
touch /mnt/gentoo/etc/portage/package.mask
touch /mnt/gentoo/etc/portage/package.use

cat <<EOF >/mnt/gentoo/etc/portage/make.conf
# Global use flags
# Change /etc/portage/package.use for granular settings
USE="dbus networkmanager"

# Portage defaults
#MAKEOPTS="-j16 -l16"
EMERGE_DEFAULT_OPTS="--ask --verbose --quiet-build"

# Compiler settings
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"

# CPU settings
CPU_FLAGS_X86=""
# GPU settings
VIDEO_CARDS=""
# Input settings
INPUT_DEVICES=""

# GRUB EFI settings
GRUB_PLATFORMS="efi-64"

# This sets the language of build output to English.
# Please keep this setting intact when reporting bugs
LC_MESSAGES=C.utf8

# Fastest Gentoo mirrors
GENTOO_MIRRORS="https://mirrors.ptisp.pt/gentoo/ \\
    http://mirrors.ptisp.pt/gentoo/ \\
    https://ftp.rnl.tecnico.ulisboa.pt/pub/gentoo/gentoo-distfiles/ \\
    http://ftp.rnl.tecnico.ulisboa.pt/pub/gentoo/gentoo-distfiles/ \\
    ftp://ftp.rnl.tecnico.ulisboa.pt/pub/gentoo/gentoo-distfiles/ \\
    rsync://ftp.rnl.tecnico.ulisboa.pt/pub/gentoo/gentoo-distfiles/ \\
    http://ftp.dei.uc.pt/pub/linux/gentoo/ \\
    https://repo.ifca.es/gentoo-distfiles \\
    rsync://repo.ifca.es/gentoo-distfiles \\
    ftp://repo.ifca.es/gentoo-distfiles"
EOF

echo '### Prepare chroot into system...'

# copy and mount required system resources
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/

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

# substitute variables and mount output script
envsubst <$THIS_DIR/chroot_install_gentoo.sh >/mnt/gentoo/chroot_install_gentoo.sh

# chroot into system and execute installation script from there
chroot /mnt/gentoo /bin/bash <<END
. /chroot_install_gentoo.sh
END

# unmount all paritions
cd
umount -l /mnt/gentoo/dev{/shm,/pts,}
umount -R /mnt/gentoo
reboot
