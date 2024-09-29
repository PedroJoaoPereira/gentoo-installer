#!/bin/bash

# machine settings
export THIS_HOST_NAME=gentoo-personal-laptop
export THIS_PASSWORD=

# disk configuration
export THIS_DISK=/dev/nvme0n1
export THIS_EFI_SIZE=+1G
export THIS_SWAP_SIZE=+4G
export THIS_ROOT_SIZE=' '
export THIS_DISK_SEPARATOR=p

# static settings
export THIS_STAGE3_FILE=https://distfiles.gentoo.org/releases/amd64/autobuilds/20240923T191858Z/stage3-amd64-openrc-20240923T191858Z.tar.xz
export THIS_PROFILE='.*amd64.*stable'

export THIS_EXTRA_USE_FLAGS=''
export THIS_VIDEO_CARDS='intel i915'
export THIS_INPUT_DEVICES='libinput'
export THIS_DRACUT_CONF='add_drivers+=" i915 "'

export THIS_DOTFILES_URL=https://github.com/PedroJoaoPereira/dotfiles.git

# ----- ----- ----- ----- -----

# get this script directory
# to use as relative path to other scripts
export THIS_HOST_DIR=$(dirname $(readlink -f $0))/
export THIS_SCRIPTS_DIR=${THIS_HOST_DIR}../../scripts

# run installation
. $THIS_SCRIPTS_DIR/install_gentoo.sh
