#!/bin/bash

echo -e "\n### Mounting ${THIS_DISK}${THIS_DISK_SEPARATOR}1...\n"
# creates boot mount point
mkdir -p /efi
mount ${THIS_DISK}${THIS_DISK_SEPARATOR}1 /efi
if [ $? -ne 0 ]; then
   echo 'Error mounting BOOT partition'
   exit 1
fi

echo -e '\n### Synchronizing system repositories...\n'
# synchronizes gentoo with daily snapshot
emerge-webrsync
if [ $? -ne 0 ]; then
   echo 'Error synchronizing portage'
   exit 1
fi
# synchronizes gentoo with hourly snapshot
emerge --ask=n --sync --quiet
if [ $? -ne 0 ]; then
   echo 'Error synchronizing portage'
   exit 1
fi

echo -e '\n### Changing portage profile...\n'
# selects portage profile
eselect profile set $(eselect profile list | grep ${THIS_PROFILE} | head -n 1 | grep -o '\[.*\]' | tr -d '[]')
if [ $? -ne 0 ]; then
   echo 'Error selecting profile'
   exit 1
fi
eselect profile list | grep '*'
# emerges cpuid2cpuflags temporarily
emerge --oneshot --ask=n app-portage/cpuid2cpuflags
if [ $? -ne 0 ]; then
   echo 'Error installing cpuid2cpuflags'
   exit 1
fi
# changes global USE flags
sed -i "s/USE=\"\"/USE=\"${THIS_EXTRA_USE_FLAGS}\"/g" /etc/portage/make.conf
# selects CPU flags
sed -i "s/CPU_FLAGS_X86=\"\"/CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d' ' -f2-)\"/g" /etc/portage/make.conf
# selects GPU flags
sed -i "s/VIDEO_CARDS=\"\"/VIDEO_CARDS=\"${THIS_VIDEO_CARDS}\"/g" /etc/portage/make.conf
# selects INPUT flags
sed -i "s/INPUT_DEVICES=\"\"/INPUT_DEVICES=\"${THIS_INPUT_DEVICES}\"/g" /etc/portage/make.conf

echo -e '\n### Updating world...\n'
# upgrades system with selected profile and flags
emerge --ask=n --update --deep --newuse @world
if [ $? -ne 0 ]; then
   echo 'Error upgrading portage'
   exit 1
fi
# removes obsolete packages
emerge --ask=n --depclean
if [ $? -ne 0 ]; then
   echo 'Error cleaning portage'
   exit 1
fi
# reads news items
eselect news read >/dev/null 2>&1

echo -e '\n### Configuring system...\n'
# sets timezone
echo 'Europe/Lisbon' >/etc/timezone
emerge --ask=n --config sys-libs/timezone-data
if [ $? -ne 0 ]; then
   echo 'Error generating timezone'
   exit 1
fi
# sets system language
sed -i 's/#en_US ISO-8859-1/en_US ISO-8859-1/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
if [ $? -ne 0 ]; then
   echo 'Error generating locale'
   exit 1
fi
eselect locale set 6
if [ $? -ne 0 ]; then
   echo 'Error selecting locale'
   exit 1
fi
# reloads environment variables
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
