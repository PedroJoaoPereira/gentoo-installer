#!/bin/bash

# checks variable definition
check_var() {
   if [ -z "$1" ]; then
      echo -e "\n>>> $2 is not defined\n"
      exit 1
   fi
}

# required variables
THIS_REQUIRED_VARS=(
   "THIS_HOST_NAME"
   "THIS_PASSWORD"
   "THIS_DISK"
   "THIS_EFI_SIZE"
   "THIS_SWAP_SIZE"
   "THIS_ROOT_SIZE"
   "THIS_DISK_SEPARATOR"
   "THIS_STAGE3_FILE"
   "THIS_PROFILE"
   "THIS_VIDEO_CARDS"
   "THIS_INPUT_DEVICES"
   "THIS_DRACUT_CONF"
   "THIS_DOTFILES_URL"
)
# checks required variables
for var in "${vars[@]}"; do
   check_var "${!var}" "$var"
done
# checks if required post install script exists
if [ ! -f "${THIS_HOST_DIR}/post_install_gentoo.sh" ]; then
   echo -e "\n>>> ${THIS_HOST_DIR}/post_install_gentoo.sh does not exist\n"
   exit 1
fi
