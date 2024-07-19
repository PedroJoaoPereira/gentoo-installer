#!/bin/sh

echo Formatting disk $THIS_DISK...

# note that a blank line (commented as "default")
# will send an empty line terminated with a newline to take the fdisk default
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

  ${THIS_EXTRA_LAYOUT}

  w  # write changes to disk
  p  # print disk partition table
  q  # quit
EOF

echo Done formatting!

# ----- ----- ----- ----- -----

echo Creating filesystems...

# fat32 BOOT
mkfs.vfat -F 32 ${THIS_DISK}p1

# linux-swap SWAP
mkswap ${THIS_DISK}p2
swapon ${THIS_DISK}p2

# ext4 ROOT
mkfs.ext4 ${THIS_DISK}p3

eval $THIS_EXTRA_FILESYSTEMS

echo Done creating filesystems!
