#!/bin/bash

echo -e "\n### Mounting ${THIS_DISK}${THIS_DISK_SEPARATOR}3...\n"
# creates root mount point
mkdir -p /mnt/gentoo
mount ${THIS_DISK}${THIS_DISK_SEPARATOR}3 /mnt/gentoo
if [ $? -ne 0 ]; then
   echo 'Error mounting ROOT partition'
   exit 1
fi
cd /mnt/gentoo

echo -e '\n### Downloading stage file...\n'
# downloads stage file
wget ${THIS_STAGE3_FILE}
if [ $? -ne 0 ]; then
   echo 'Error downloading stage file'
   exit 1
fi
# extracts stage file
tar xpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner
if [ $? -ne 0 ]; then
   echo 'Error extracting stage file'
   exit 1
fi

echo -e '\n### Creating portage configuration...\n'
# removes default portage configurations
rm -rf /mnt/gentoo/etc/portage/package.*
# replaces configuration directories with empty files
touch /mnt/gentoo/etc/portage/package.accept_keywords
touch /mnt/gentoo/etc/portage/package.env
touch /mnt/gentoo/etc/portage/package.license
touch /mnt/gentoo/etc/portage/package.mask
touch /mnt/gentoo/etc/portage/package.use
# creates build profiles directory
mkdir -p /mnt/gentoo/etc/portage/env
# creates default portage configuration
cat <<EOF >/mnt/gentoo/etc/portage/make.conf
# global USE flags
USE=""

# portage default options
#MAKEOPTS="-jXX -lYY"
EMERGE_DEFAULT_OPTS="--ask --verbose --quiet-build"

# compiler settings
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
# default build output language
LC_MESSAGES=C.utf8
# closest Gentoo mirrors
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
# prints portage configuration files
ls -la /mnt/gentoo/etc/portage
echo -e '\n'
cat /mnt/gentoo/etc/portage/make.conf
