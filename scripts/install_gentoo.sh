#!/bin/bash

# halts execution if any input is not defined or empty
. $THIS_SCRIPTS_DIR/helpers/validate_inputs.sh
# installs gentoo by the hadnbook
. $THIS_SCRIPTS_DIR/helpers/prepare_disks.sh
. $THIS_SCRIPTS_DIR/helpers/install_stage_file.sh
. $THIS_SCRIPTS_DIR/helpers/prepare_chroot.sh

# chroots into system
chroot /mnt/gentoo /bin/bash <<END
echo -e "\n### chrooting system in ${THIS_DISK}${THIS_DISK_SEPARATOR}3...\n"
# sources gentoo profile variables
source /etc/profile
export PS1="(chroot) ${PS1}"
# executes chroot install script
. /chroot_install_gentoo.sh
END
