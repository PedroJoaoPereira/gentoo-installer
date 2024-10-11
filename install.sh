#!/bin/bash

######################################################################
################                hosts                 ################
######################################################################
function example() {
  user=userName
  device=deviceName
  separator=?
  efi=+512M
  swap=+1G
  root=+64G
  timezone=Europe/Lisbon
  keymap=pt-latin9
}
function gentoo-laptop-msi-es() {
  user=chuck
  device=nvme0n1
  separator=p
  efi=+1G
  swap=+8G
  root=+128G
  timezone=Europe/Lisbon
  keymap=pt-latin9
}

######################################################################
################              functions               ################
######################################################################
function check-and-install-dependency() {
  # checks if command argument is installed
  if ! command -v $1 &>/dev/null; then
    # installs command argument
    apt install $1 -y
  fi
}

function get_current_stage3_url() {
  # gets current stage3 metadata
  metadata=$(wget -qO- https://distfiles.gentoo.org/releases/amd64/autobuilds/latest-stage3-amd64-openrc.txt)
  # gets current stage3 file name
  metadata=$(echo $metadata | grep -oE '[0-9]*T[0-9]*Z/stage3-amd64-openrc-[0-9]*T[0-9]*Z.tar.xz')
  # gets current stage3 file URL
  metadata="https://distfiles.gentoo.org/releases/amd64/autobuilds/${metadata}"
  # prints out current stage3 file URL
  echo $metadata
}

######################################################################
################                steps                 ################
######################################################################
function 00-intro() {
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

function 01-configure-system() {
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
  STAGE_FILE=$(get_current_stage3_url)
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

function 02-prepare-disks() {
  clear
  echo -e "
  ______ ______                                        _                    _ _      _          
 / __   (_____ \                                      (_)                  | (_)    | |         
| | //| | ____) )__ ____   ____ ____ ____   ____  ____ _ ____   ____ ___ _ | |_  ___| |  _  ___ 
| |// | |/_____(___)  _ \ / ___) _  )  _ \ / _  |/ ___) |  _ \ / _  (___) || | |/___) | / )/___)
|  /__| |_______   | | | | |  ( (/ /| | | ( ( | | |   | | | | ( ( | |  ( (_| | |___ | |< (|___ |
 \_____/(_______)  | ||_/|_|   \____) ||_/ \_||_|_|   |_|_| |_|\_|| |   \____|_(___/|_| \_|___/ 
                   |_|              |_|                       (_____|                           
________________________________________________________________________________________________
"

  # partitions disk
  # a blank line will send a return to fdisk
  sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk ${DEVICE}
    g  # create empty GPT partition table
    n  # create EFI partition
    # choose default partition number
    # choose default sector number
    ${EFI_SIZE}
    y  # remove signature if it exists
    t  # create EFI partition type
    1  # EFI system type
    n  # create SWAP partition
    # choose default partition number
    # choose default sector number
    ${SWAP_SIZE}
    y  # remove signature if it exists
    t  # create SWAP partition type
    # choose default partition number
    19 # Linux swap type
    n  # create ROOT partition
    # choose default partition number
    # choose default sector number
    ${ROOT_SIZE}
    y  # remove signature if it exists
    t  # create ROOT partition type
    # choose default partition number
    23 # Linux root (x86-64) type
    w  # write changes to disk
EOF

  # fat32 BOOT
  mkfs.vfat -F 32 ${DEVICE}${DEVICE_SEPARATOR}1
  # linux-swap SWAP
  mkswap ${DEVICE}${DEVICE_SEPARATOR}2
  swapon ${DEVICE}${DEVICE_SEPARATOR}2
  # ext4 ROOT
  mkfs.ext4 ${DEVICE}${DEVICE_SEPARATOR}3 <<EOF
y
EOF
}

function 03-install-stage() {
  clear
  echo -e "
  ______ ________   _                      _ _ _                                           
 / __   (_______/  (_)           _        | | (_)                    _                     
| | //| |  ____ ___ _ ____   ___| |_  ____| | |_ ____   ____ ___ ___| |_  ____  ____  ____ 
| |// | | (___ (___) |  _ \ /___)  _)/ _  | | | |  _ \ / _  (___)___)  _)/ _  |/ _  |/ _  )
|  /__| |_____) )  | | | | |___ | |_( ( | | | | | | | ( ( | |  |___ | |_( ( | ( ( | ( (/ / 
 \_____/(______/   |_|_| |_(___/ \___)_||_|_|_|_|_| |_|\_|| |  (___/ \___)_||_|\_|| |\____)
                                                      (_____|                 (_____|      
___________________________________________________________________________________________
"

  # creates root mount point
  mkdir -p /mnt/gentoo
  mount ${DEVICE}${DEVICE_SEPARATOR}3 /mnt/gentoo
  cd /mnt/gentoo

  # downloads stage file
  wget ${STAGE_FILE} || exit 1
  tar xpf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner

  # configures empty portage configuration
  rm -rf /mnt/gentoo/etc/portage/package.*
  mkdir -p /mnt/gentoo/etc/portage/env
  touch /mnt/gentoo/etc/portage/package.accept_keywords
  touch /mnt/gentoo/etc/portage/package.env
  touch /mnt/gentoo/etc/portage/package.license
  touch /mnt/gentoo/etc/portage/package.mask
  touch /mnt/gentoo/etc/portage/package.use
  cat <<EOF >/mnt/gentoo/etc/portage/make.conf
# global USE flags
USE="dbus elogind networkmanager"

# CPU settings
CPU_FLAGS_X86=""
# GPU settings
VIDEO_CARDS=""
# Input settings
INPUT_DEVICES=""

# portage default options
#MAKEOPTS="-jXX -lYY"
EMERGE_DEFAULT_OPTS="--ask --verbose --quiet-build"

# compiler settings
COMMON_FLAGS="-march=native -O2 -pipe"
CFLAGS="\${COMMON_FLAGS}"
CXXFLAGS="\${COMMON_FLAGS}"
FCFLAGS="\${COMMON_FLAGS}"
FFLAGS="\${COMMON_FLAGS}"

# GRUB EFI settings
GRUB_PLATFORMS="efi-64"
# default build output language
LC_MESSAGES=C.utf8
EOF
}

function 04-chroot() {
  echo ola
}

######################################################################
################                script                ################
######################################################################
# sets bash options
set -o errexit
set -o errtrace
set -o pipefail

function main() {
  # run always as root
  # sudo su
  # validate dependencies and installs them if not present
  check-and-install-dependency wget

  # checks if argument is passed
  is_template_host=false
  if [[ ! -z $1 ]]; then
    is_template_host=true
  fi

  # runs installation steps
  [[ ${is_template_host} == false ]] && 00-intro
  [[ ${is_template_host} == true ]] && $1 && host=$1
  01-configure-system
  02-prepare-disks
  03-install-stage
  04-chroot
}

# runs script with inherited arguments
main "$@"
