#!/bin/bash

echo -e "\n### Formatting disk ${THIS_DISK}...\n"
# note that a blank line will send a return to fdisk
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' <<EOF | fdisk ${THIS_DISK}
  g  # create empty GPT partition table
  n  # create EFI partition
     # choose default partition number
     # choose default sector number
  ${THIS_EFI_SIZE}
  y  # remove signature if it exists
  t  # create EFI partition type
  1  # EFI system type
  n  # create SWAP partition
     # choose default partition number
     # choose default sector number
  ${THIS_SWAP_SIZE}
  y  # remove signature if it exists
  t  # create SWAP partition type
     # choose default partition number
  19 # Linux swap type
  n  # create ROOT partition
     # choose default partition number
     # choose default sector number
  ${THIS_ROOT_SIZE}
  y  # remove signature if it exists
  t  # create ROOT partition type
     # choose default partition number
  23 # Linux root (x86-64) type
  w  # write changes to disk
  p  # print disk partition table
  q  # quit
EOF
# prints disk partitions
echo -e '\n'
fdisk -l ${THIS_DISK}

echo -e "\n### Creating disk ${THIS_DISK} filesystems...\n"
# fat32 BOOT
mkfs.vfat -F 32 ${THIS_DISK}${THIS_DISK_SEPARATOR}1
if [ $? -ne 0 ]; then
   echo 'Error creating BOOT filesystem'
   exit 1
fi
# linux-swap SWAP
mkswap ${THIS_DISK}${THIS_DISK_SEPARATOR}2
swapon ${THIS_DISK}${THIS_DISK_SEPARATOR}2
if [ $? -ne 0 ]; then
   echo 'Error creating SWAP filesystem'
   exit 1
fi
# ext4 ROOT
mkfs.ext4 ${THIS_DISK}${THIS_DISK_SEPARATOR}3 <<EOD
y
EOD
if [ $? -ne 0 ]; then
   echo 'Error creating ROOT filesystem'
   exit 1
fi
