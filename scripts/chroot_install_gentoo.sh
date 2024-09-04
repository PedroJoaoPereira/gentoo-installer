#!/bin/bash

# installs gentoo by the handbook
. ./helpers/install_base.sh
. ./helpers/prepare_kernel.sh
. ./helpers/install_dependencies.sh
. ./helpers/configure_system.sh
. /post_install_gentoo.sh
. ./helpers/cleanup_system.sh
# running exit leaves this script and chroot
exit
