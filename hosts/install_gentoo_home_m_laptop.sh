#!/bin/sh

# ----- ----- ----- ----- -----
# machine settings

export THIS_HOST_NAME=gentoo-home-m-laptop
export THIS_PASSWORD=

# ----- ----- ----- ----- -----
# disk configuration

export THIS_DISK=/dev/sda

export THIS_EFI_SIZE=+512M
export THIS_SWAP_SIZE=+8G
export THIS_ROOT_SIZE=''

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

export THIS_DISK_SEPARATOR=''
export THIS_STAGE3_FILE=https://distfiles.gentoo.org/releases/amd64/autobuilds/20240714T170402Z/stage3-amd64-openrc-20240714T170402Z.tar.xz
export THIS_DOTFILES_URL=https://github.com/PedroJoaoPereira/dotfiles.git

# ----- ----- ----- ----- -----

# get this script directory
# to use as relative path to other scripts
export THIS_DIR=$(dirname $(readlink -f $0))/../scripts

# run installation
. $THIS_DIR/install_gentoo.sh
