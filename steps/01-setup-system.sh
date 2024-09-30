#!/bin/bash

CONFIRMATION_DIALOG='n'
while [[ "${CONFIRMATION_DIALOG}" == 'n' || "${CONFIRMATION_DIALOG}" == 'N' || (! -z "${CONFIRMATION_DIALOG}" && "${CONFIRMATION_DIALOG}" != 'y' && "${CONFIRMATION_DIALOG}" != 'Y') ]]; do

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

    HOST=' '
    while [[ ! "${HOST}" =~ ^[[:alnum:]-]+$ ]]; do
        read -p ' - Host: ' HOST
        if [[ ! "${HOST}" =~ ^[[:alnum:]-]+$ ]]; then
            echo -e 'Host must not have special characters!\n'
        fi
    done

    PASSWORD=' '
    while [[ ${PASSWORD} != ${PASSWORD_CONFIRMATION} ]]; do
        read -s -p ' - Password: ' PASSWORD
        echo ''
        read -s -p ' - Confirm password: ' PASSWORD_CONFIRMATION
        echo ''
        if [[ ${PASSWORD} != ${PASSWORD_CONFIRMATION} ]]; then
            echo -e 'Passwords do not match!\n'
        elif [[ -z "${PASSWORD}" ]]; then
            echo -e 'Password cannot be empty!\n'
            PASSWORD='this'
            PASSWORD_CONFIRMATION='that'
        fi
    done

    read -p ' - Device name /dev/_ (default is nvme0n1): ' DEVICE
    DEVICE="/dev/${DEVICE:-nvme0n1}"

    read -p " - Partition separator /dev/nvme0n1_1 (default is p, type '?' for an empty separator symbol): " DEVICE_SEPARATOR_TEMP
    DEVICE_SEPARATOR_TEMP="${DEVICE_SEPARATOR_TEMP:-p}"
    if [[ "${DEVICE_SEPARATOR_TEMP}" = $'?' ]]; then
        DEVICE_SEPARATOR_TEMP=''
    fi
    DEVICE_SEPARATOR="${DEVICE_SEPARATOR_TEMP}"

    read -p " - Partition EFI size (default is '+1G', type '?' for remaining disk size): " EFI_SIZE_TEMP
    EFI_SIZE_TEMP="${EFI_SIZE_TEMP:-+1G}"
    if [[ "${EFI_SIZE_TEMP}" = $'?' ]]; then
        EFI_SIZE_TEMP=' '
    fi
    EFI_SIZE="${EFI_SIZE_TEMP}"

    read -p " - Partition SWAP size (default is '+4G', type '?' for remaining disk size): " SWAP_SIZE_TEMP
    SWAP_SIZE_TEMP="${SWAP_SIZE_TEMP:-+4G}"
    if [[ "${SWAP_SIZE_TEMP}" = $'?' ]]; then
        SWAP_SIZE_TEMP=' '
    fi
    SWAP_SIZE="${SWAP_SIZE_TEMP}"

    read -p " - Partition ROOT size (default is '?' remaining disk size, type '+128G' to change it to something else): " ROOT_SIZE_TEMP
    ROOT_SIZE_TEMP="${ROOT_SIZE_TEMP:-?}"
    if [[ "${ROOT_SIZE_TEMP}" = $'?' ]]; then
        ROOT_SIZE_TEMP=' '
    fi
    ROOT_SIZE="${ROOT_SIZE_TEMP}"

    read -p ' - Stage file URL (default is https://distfiles.gentoo.org/releases/amd64/autobuilds/20240929T163611Z/stage3-amd64-openrc-20240929T163611Z.tar.xz): ' STAGE_FILE
    STAGE_FILE="${STAGE_FILE:-https://distfiles.gentoo.org/releases/amd64/autobuilds/20240929T163611Z/stage3-amd64-openrc-20240929T163611Z.tar.xz}"

    echo -e "
Host: ${HOST}
Device: ${DEVICE}
Device separator: ${DEVICE_SEPARATOR}
EFI partition size: ${EFI_SIZE}
SWAP partition size: ${SWAP_SIZE}
ROOT partition size: ${ROOT_SIZE}
Stage file: ${STAGE_FILE}

Verify the setup details before moving on
"
    read -p 'Are you sure you want to continue [Y/n]? ' CONFIRMATION_DIALOG
done

export HOST
export PASSWORD
export DEVICE
export DEVICE_SEPARATOR
export EFI_SIZE
export SWAP_SIZE
export ROOT_SIZE
