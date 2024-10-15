#!/bin/bash

clear
echo -e "
  ______  __                      ___ _                   _                                                
 / __   |/  |                    / __|_)                 (_)                               _               
| | //| /_/ |___ ____ ___  ____ | |__ _  ____ _   _  ____ _ ____   ____ ___ ___ _   _  ___| |_  ____ ____  
| |// | | | (___) ___) _ \|  _ \|  __) |/ _  | | | |/ ___) |  _ \ / _  (___)___) | | |/___)  _)/ _  )    \ 
|  /__| | | |  ( (__| |_| | | | | |  | ( ( | | |_| | |   | | | | ( ( | |  |___ | |_| |___ | |_( (/ /| | | |
 \_____/  |_|   \____)___/|_| |_|_|  |_|\_|| |\____|_|   |_|_| |_|\_|| |  (___/ \__  (___/ \___)____)_|_|_|
                                       (_____|                   (_____|       (____/                      
___________________________________________________________________________________________________________
"

# reads from arguments file
if [[ ! -z $1 ]]; then
    source $1
    scripted_host=$(basename $1 | sed 's/\.props//')
fi

# gets user input
if [[ -z ${scripted_user} ]]; then
    read -p ' - User: ' THIS_USER
else
    THIS_USER=${scripted_user}
fi
read -s -p ' - Password: ' THIS_PASSWORD
echo ''
read -s -p ' - Confirm password: ' THIS_PASSWORD_CONFIRMATION
echo ''
if [[ -z ${scripted_host} ]]; then
    read -p ' - Host: ' THIS_HOST
else
    THIS_HOST=${scripted_host}
fi
if [[ -z ${scripted_device} ]]; then
    read -p ' - Device name /dev/_ (default is nvme0n1): ' THIS_DEVICE
else
    THIS_DEVICE=${scripted_device}
fi
if [[ -z ${scripted_separator} ]]; then
    read -p ' - Device separator /dev/nvme0n1_1 (default is p, type "?" for an empty separator symbol): ' THIS_DEVICE_SEPARATOR
else
    THIS_DEVICE_SEPARATOR=${scripted_separator}
fi
if [[ -z ${scripted_efi} ]]; then
    read -p ' - EFI partition size (default is +1G, type "?" for remaining disk size): ' THIS_EFI_SIZE
else
    THIS_EFI_SIZE=${scripted_efi}
fi
if [[ -z ${scripted_swap} ]]; then
    read -p ' - SWAP partition size (default is +8G, type "?" for remaining disk size): ' THIS_SWAP_SIZE
else
    THIS_SWAP_SIZE=${scripted_swap}
fi
if [[ -z ${scripted_root} ]]; then
    read -p ' - ROOT partition size (default is "?" for remaining disk size, type "+128G" to change it to something else): ' THIS_ROOT_SIZE
else
    THIS_ROOT_SIZE=${scripted_root}
fi
if [[ -z ${scripted_timezone} ]]; then
    read -p ' - Timezone (default is Europe/Lisbon): ' THIS_TIMEZONE
else
    THIS_TIMEZONE=${scripted_timezone}
fi
if [[ -z ${scripted_keymap} ]]; then
    read -p ' - Keymap (default is pt-latin9): ' THIS_KEYMAP
else
    THIS_KEYMAP=${scripted_keymap}
fi

function get-current-stage3-url() {
    # gets current stage3 metadata
    metadata=$(wget -qO- https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt)
    # gets current stage3 file name
    metadata=$(echo $metadata | grep -oE '[0-9]*T[0-9]*Z/stage3-amd64-openrc-[0-9]*T[0-9]*Z.tar.xz')
    # gets current stage3 file URL
    metadata="https://distfiles.gentoo.org/releases/amd64/autobuilds/${metadata}"
    # prints out current stage3 file URL
    echo $metadata
}

# sets default values
THIS_DEVICE="/dev/${THIS_DEVICE:-nvme0n1}"
THIS_DEVICE_SEPARATOR="${THIS_DEVICE_SEPARATOR:-p}"
THIS_EFI_SIZE="${THIS_EFI_SIZE:-+1G}"
THIS_SWAP_SIZE="${THIS_SWAP_SIZE:-+8G}"
THIS_ROOT_SIZE="${THIS_ROOT_SIZE:-?}"
THIS_STAGE_FILE=$(get-current-stage3-url)
THIS_TIMEZONE="${THIS_TIMEZONE:-Europe/Lisbon}"
THIS_KEYMAP="${THIS_KEYMAP:-pt-latin9}"

# checks if password and password confirmation match
if [[ ${THIS_PASSWORD} != ${THIS_PASSWORD_CONFIRMATION} ]]; then
    echo -e 'Passwords do not match!\n'
    exit 1
fi

# sets special input variables values
if [[ "${THIS_DEVICE_SEPARATOR}" = $'?' ]]; then
    THIS_DEVICE_SEPARATOR=''
fi
if [[ "${THIS_EFI_SIZE}" = $'?' ]]; then
    THIS_EFI_SIZE=' '
fi
if [[ "${THIS_SWAP_SIZE}" = $'?' ]]; then
    THIS_SWAP_SIZE=' '
fi
if [[ "${THIS_ROOT_SIZE}" = $'?' ]]; then
    THIS_ROOT_SIZE=' '
fi

# prints out user choices
echo -e "
Confirm your choices:

User: ${THIS_USER}
Password: ********
Host: ${THIS_HOST}
Device: ${THIS_DEVICE}
Device separator: ${THIS_DEVICE_SEPARATOR}
EFI partition size: ${THIS_EFI_SIZE}
SWAP partition size: ${THIS_SWAP_SIZE}
ROOT partition size: ${THIS_ROOT_SIZE}
Stage file: ${THIS_STAGE_FILE}
Timezone: ${THIS_TIMEZONE}
Keymap: ${THIS_KEYMAP}
"

# confirms user choices
read -p 'Are you sure you want to continue [Y/n]? ' CONFIRMATION_DIALOG
echo ''
if [[ "${CONFIRMATION_DIALOG}" == 'n' || "${CONFIRMATION_DIALOG}" == 'N' ]]; then
    exit 1
fi

# checks if any empty variable
if [[ -z ${THIS_USER} || -z ${THIS_PASSWORD} || -z ${THIS_HOST} || -z ${THIS_STAGE_FILE} || -z ${THIS_TIMEZONE} || -z ${THIS_KEYMAP} ]]; then
    echo 'Some variables are empty aborting'
    echo ''
    exit 1
fi
