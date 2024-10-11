#!/bin/bash

function intro() {
  clear
  echo -e "

 ██████╗ ███████╗███╗   ██╗████████╗ ██████╗  ██████╗     ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
██╔════╝ ██╔════╝████╗  ██║╚══██╔══╝██╔═══██╗██╔═══██╗    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
██║  ███╗█████╗  ██╔██╗ ██║   ██║   ██║   ██║██║   ██║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
██║   ██║██╔══╝  ██║╚██╗██║   ██║   ██║   ██║██║   ██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
╚██████╔╝███████╗██║ ╚████║   ██║   ╚██████╔╝╚██████╔╝    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
 ╚═════╝ ╚══════╝╚═╝  ╚═══╝   ╚═╝    ╚═════╝  ╚═════╝     ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
________________________________________________________________________________________________________________________________
                    ________________________________________________________________________________________
"

  echo -e "
This script performs a stable gentoo base installation with no extra configurations
This is used to get a working barebones system on which to work on and customize to your liking
"

  read -n 1 -s -p ' - Press any key to continue...'
}

function configure_system() {
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
    host=$(basename $1 | sed 's/\.props//')
  fi

  # gets user input
  if [[ -z ${user} ]]; then
    read -p ' - User: ' USER
  else
    USER=${user}
  fi
  read -s -p ' - Password: ' PASSWORD
  echo ''
  read -s -p ' - Confirm password: ' PASSWORD_CONFIRMATION
  echo ''
  if [[ -z ${host} ]]; then
    read -p ' - Host: ' HOST
  else
    HOST=${host}
  fi
  if [[ -z ${device} ]]; then
    read -p ' - Device name /dev/_ (default is nvme0n1): ' DEVICE
  else
    DEVICE=${device}
  fi
  if [[ -z ${separator} ]]; then
    read -p ' - Device separator /dev/nvme0n1_1 (default is p, type "?" for an empty separator symbol): ' DEVICE_SEPARATOR
  else
    DEVICE_SEPARATOR=${separator}
  fi
  if [[ -z ${efi} ]]; then
    read -p ' - EFI partition size (default is +1G, type "?" for remaining disk size): ' EFI_SIZE
  else
    EFI_SIZE=${efi}
  fi
  if [[ -z ${swap} ]]; then
    read -p ' - SWAP partition size (default is +8G, type "?" for remaining disk size): ' SWAP_SIZE
  else
    SWAP_SIZE=${swap}
  fi
  if [[ -z ${root} ]]; then
    read -p ' - ROOT partition size (default is "?" for remaining disk size, type "+128G" to change it to something else): ' ROOT_SIZE
  else
    ROOT_SIZE=${root}
  fi
  if [[ -z ${timezone} ]]; then
    read -p ' - Timezone (default is Europe/Lisbon): ' TIMEZONE
  else
    TIMEZONE=${timezone}
  fi
  if [[ -z ${keymap} ]]; then
    read -p ' - Keymap (default is pt-latin9): ' KEYMAP
  else
    KEYMAP=${keymap}
  fi

  # sets default values
  DEVICE="/dev/${DEVICE:-nvme0n1}"
  DEVICE_SEPARATOR="${DEVICE_SEPARATOR:-p}"
  EFI_SIZE="${EFI_SIZE:-+1G}"
  SWAP_SIZE="${SWAP_SIZE:-+8G}"
  ROOT_SIZE="${ROOT_SIZE:-?}"
  STAGE_FILE=$(. ${SCRIPTS_DIR}/get-current-stage3-url.sh)
  TIMEZONE="${TIMEZONE:-Europe/Lisbon}"
  KEYMAP="${KEYMAP:-pt-latin9}"

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
Timezone: ${TIMEZONE}
Keymap: ${KEYMAP}
"

  # confirms user choices
  read -p 'Are you sure you want to continue [Y/n]? ' CONFIRMATION_DIALOG
  echo ''
  if [[ "${CONFIRMATION_DIALOG}" == 'n' || "${CONFIRMATION_DIALOG}" == 'N' ]]; then
    exit 1
  fi

  # checks if any empty variable
  if [[ -z ${USER} || -z ${PASSWORD} || -z ${HOST} || -z ${STAGE_FILE} || -z ${TIMEZONE} || -z ${KEYMAP} ]]; then
    echo 'Some variables are empty aborting'
    echo ''
    exit 1
  fi

  # exports variables
  export USER PASSWORD HOST DEVICE DEVICE_SEPARATOR EFI_SIZE SWAP_SIZE ROOT_SIZE STAGE_FILE TIMEZONE KEYMAP
}

function main() {
  intro
  configure_system

  echo $USER
}

main
