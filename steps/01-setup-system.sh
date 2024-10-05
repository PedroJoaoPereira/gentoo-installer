#!/bin/bash

clear
echo -e "
            _                                  _               
  ___  ____| |_ _   _ ____      ___ _   _  ___| |_  ____ ____  
 /___)/ _  )  _) | | |  _ \    /___) | | |/___)  _)/ _  )    \ 
|___ ( (/ /| |_| |_| | | | |  |___ | |_| |___ | |_( (/ /| | | |
(___/ \____)\___)____| ||_/   (___/ \__  (___/ \___)____)_|_|_|
                     |_|           (____/                      
_______________________________________________________________
"

# gets user input
read -p ' - User: ' USER
read -s -p ' - Password: ' PASSWORD
echo ''
read -s -p ' - Confirm password: ' PASSWORD_CONFIRMATION
echo ''
read -p ' - Host: ' HOST
read -p ' - Device name /dev/_ (default is nvme0n1): ' DEVICE
read -p ' - Device separator /dev/nvme0n1_1 (default is p, type "?" for an empty separator symbol): ' DEVICE_SEPARATOR
read -p ' - EFI partition size (default is +1G, type "?" for remaining disk size): ' EFI_SIZE
read -p ' - SWAP partition size (default is +4G, type "?" for remaining disk size): ' SWAP_SIZE
read -p ' - ROOT partition size (default is "?" for remaining disk size, type "+128G" to change it to something else): ' ROOT_SIZE

# sets default values
DEVICE="/dev/${DEVICE:-nvme0n1}"
DEVICE_SEPARATOR="${DEVICE_SEPARATOR:-p}"
EFI_SIZE="${EFI_SIZE:-+1G}"
SWAP_SIZE="${SWAP_SIZE:-+4G}"
ROOT_SIZE="${ROOT_SIZE:-?}"

# checks if password and password confirmation match
if [[ ${PASSWORD} != ${PASSWORD_CONFIRMATION} ]]; then
    echo -e 'Passwords do not match!\n'
    exit 1
fi

# sets special input variables values
if [[ "${DEVICE_SEPARATOR}" = $'?' ]]; then
    DEVICE_SEPARATOR=''
fi
if [[ "${EFI_SIZE}" = $'?' ]]; then
    EFI_SIZE=' '
fi
if [[ "${SWAP_SIZE}" = $'?' ]]; then
    SWAP_SIZE=' '
fi
if [[ "${ROOT_SIZE}" = $'?' ]]; then
    ROOT_SIZE=' '
fi

# gets current stage3 file URL
STAGE_FILE=$(. ${SCRIPTS_DIR}/get-current-stage3-url.sh)

# prints out user choices
echo -e "
Confirm your choices:

User: ${USER}
Password: ********
Host: ${HOST}
Device: ${DEVICE}
Device separator: ${DEVICE_SEPARATOR}
EFI partition size: ${EFI_SIZE}
SWAP partition size: ${SWAP_SIZE}
ROOT partition size: ${ROOT_SIZE}
Stage file: ${STAGE_FILE}
"

# confirms user choices
read -p 'Are you sure you want to continue [Y/n]? ' CONFIRMATION_DIALOG
echo ''
if [[ "${CONFIRMATION_DIALOG}" == 'n' || "${CONFIRMATION_DIALOG}" == 'N' ]]; then
    exit 1
fi

# checks if any empty variable
if [[ -z ${USER} || -z ${PASSWORD} || -z ${HOST} || -z ${STAGE_FILE} ]]; then
    echo 'Some variables are empty aborting'
    echo ''
    exit 1
fi

# exports variables
export USER PASSWORD HOST DEVICE DEVICE_SEPARATOR EFI_SIZE SWAP_SIZE ROOT_SIZE STAGE_FILE
