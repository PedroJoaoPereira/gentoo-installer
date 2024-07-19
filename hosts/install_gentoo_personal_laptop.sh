#!/bin/sh

THIS_HOST_NAME=gentoo-personal-laptop

# ----- ----- ----- ----- -----

INSTALLATION_FORMAT=false

THIS_DISK=/dev/nvme0n1

THIS_EFI_SIZE=+2G
THIS_SWAP_SIZE=+8G
THIS_ROOT_SIZE=+256G

THIS_EXTRA_LAYOUT=$(
   cat <<END
END
)

THIS_EXTRA_FILESYSTEMS=$(
   cat <<END
END
)

# ----- ----- ----- ----- -----

# get this script directory
# to use as relative path to other scripts
THIS_DIR=$(dirname $(readlink -f $0))/../scripts

# run installation
. $THIS_DIR/install_gentoo.sh
