#!/bin/bash

clear
echo -e "
                                   (_)                  | (_)    | |         
 ____   ____ ____ ____   ____  ____ _ ____   ____     _ | |_  ___| |  _  ___ 
|  _ \ / ___) _  )  _ \ / _  |/ ___) |  _ \ / _  |   / || | |/___) | / )/___)
| | | | |  ( (/ /| | | ( ( | | |   | | | | ( ( | |  ( (_| | |___ | |< (|___ |
| ||_/|_|   \____) ||_/ \_||_|_|   |_|_| |_|\_|| |   \____|_(___/|_| \_|___/ 
|_|              |_|                       (_____|                           
_____________________________________________________________________________
"
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
    p  # print disk partition table
    q  # quit
EOF
echo
fdisk -l ${DEVICE}

# fat32 BOOT
mkfs.vfat -F 32 ${DEVICE}${DEVICE_SEPARATOR}1
if [ $? -ne 0 ]; then
    echo 'Error creating EFI filesystem'
    exit 1
fi
# linux-swap SWAP
mkswap ${DEVICE}${DEVICE_SEPARATOR}2
swapon ${DEVICE}${DEVICE_SEPARATOR}2
if [ $? -ne 0 ]; then
    echo 'Error creating SWAP filesystem'
    exit 1
fi
# ext4 ROOT
mkfs.ext4 ${DEVICE}${DEVICE_SEPARATOR}3 <<EOD
y
EOD
if [ $? -ne 0 ]; then
    echo 'Error creating ROOT filesystem'
    exit 1
fi
