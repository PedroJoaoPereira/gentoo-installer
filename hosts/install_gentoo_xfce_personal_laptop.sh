#!/bin/sh

# ----- ----- ----- ----- -----
# machine settings

export THIS_HOST_NAME=gentoo-xfce-personal-laptop
export THIS_PASSWORD=

# ----- ----- ----- ----- -----
# disk configuration

export THIS_DISK=/dev/nvme0n1

export THIS_EFI_SIZE=+1G
export THIS_SWAP_SIZE=+40G
export THIS_ROOT_SIZE=' '

# fdisk options here
export THIS_EXTRA_LAYOUT=$(
   cat <<END
END
)

# mkfs commands here
export THIS_EXTRA_FILESYSTEMS=$(
   cat <<END
END
)

# ----- ----- ----- ----- -----

export THIS_DISK_SEPARATOR=p
export THIS_STAGE3_FILE=https://distfiles.gentoo.org/releases/amd64/autobuilds/20240825T170406Z/stage3-amd64-desktop-openrc-20240825T170406Z.tar.xz
export THIS_DOTFILES_URL=https://github.com/PedroJoaoPereira/dotfiles.git

# ----- ----- ----- ----- -----

# get this script directory
# to use as relative path to other scripts
export THIS_DIR=$(dirname $(readlink -f $0))/../scripts

# run installation
. $THIS_DIR/install_gentoo.sh
