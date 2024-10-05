#!/bin/bash

clear
echo -e "
  ______ ________   _                      _ _ _                                           
 / __   (_______/  (_)           _        | | (_)                    _                     
| | //| |  ____ ___ _ ____   ___| |_  ____| | |_ ____   ____ ___ ___| |_  ____  ____  ____ 
| |// | | (___ (___) |  _ \ /___)  _)/ _  | | | |  _ \ / _  (___)___)  _)/ _  |/ _  |/ _  )
|  /__| |_____) )  | | | | |___ | |_( ( | | | | | | | ( ( | |  |___ | |_( ( | ( ( | ( (/ / 
 \_____/(______/   |_|_| |_(___/ \___)_||_|_|_|_|_| |_|\_|| |  (___/ \___)_||_|\_|| |\____)
                                                      (_____|                 (_____|      
___________________________________________________________________________________________
"

# creates root mount point
mkdir -p /mnt/gentoo
mount ${DEVICE}${DEVICE_SEPARATOR}3 /mnt/gentoo
cd /mnt/gentoo

# downloads stage file
wget ${STAGE_FILE}
tar xpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

# configures empty portage configuration
rm -rf /mnt/gentoo/etc/portage/package.*
mkdir -p /mnt/gentoo/etc/portage/env
touch /mnt/gentoo/etc/portage/package.accept_keywords
touch /mnt/gentoo/etc/portage/package.env
touch /mnt/gentoo/etc/portage/package.license
touch /mnt/gentoo/etc/portage/package.mask
touch /mnt/gentoo/etc/portage/package.use
cat <<EOF >/mnt/gentoo/etc/portage/make.conf
# global USE flags
USE="networkmanager"

# CPU settings
CPU_FLAGS_X86=""
# GPU settings
VIDEO_CARDS=""
# Input settings
INPUT_DEVICES=""

# portage default options
#MAKEOPTS="-jXX -lYY"
EMERGE_DEFAULT_OPTS="--ask --verbose --quiet-build"

# compiler settings
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"

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
