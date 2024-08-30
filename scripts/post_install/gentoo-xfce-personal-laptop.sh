#!/bin/sh

echo -e '\n### Adding graphics driver to boot process...\n'

# add graphic driver while booting
cat <<EOF >/etc/dracut.conf.d/override.conf
add_drivers+=" i915 "
EOF

# regenerate initramfs
dracut --force --kver $(eselect kernel list | grep '*' | grep -o 'linux-.* ' | sed 's/linux-//g')
if [ $? -ne 0 ]; then
  echo 'Error generating initramfs'
  exit 1
fi

echo -e '\n### Configuring make.conf for machine...\n'

# emerge tool for getting cpu eligible flags
emerge --oneshot --ask=n app-portage/cpuid2cpuflags
if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi

# select cpu flags
sed -i "s/CPU_FLAGS_X86=\"\"/CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d' ' -f2-)\"/g" /etc/portage/make.conf
# select video cards - only for intel graphics
sed -i "s/VIDEO_CARDS=\"\"/VIDEO_CARDS=\"intel i915\"/g" /etc/portage/make.conf
# input devices - only for laptop touchpad
sed -i "s/INPUT_DEVICES=\"\"/INPUT_DEVICES=\"libinput\"/g" /etc/portage/make.conf

# remove all global use flags
sed -i "s/USE=\"dbus networkmanager\"/USE=\"\"/g" /etc/portage/make.conf

# print out portage configuration
echo -e '\n'
cat /etc/portage/make.conf

echo -e '\n### Changing profile to KDE stable...\n'

# change profile to desktop stable
eselect profile set $(eselect profile list | grep '.*desktop.*stable' | head -n 1 | grep -o '\[.*\]' | tr -d '[]')
if [ $? -ne 0 ]; then
  echo 'Error selecting profile'
  exit 1
fi

eselect profile list | grep '*'

echo -e '\n### Install profile dependencies...\n'

# update system after flag changes
emerge --ask=n --verbose --update --deep --changed-use --with-bdeps=y --backtrack=30 @world
if [ $? -ne 0 ]; then
  echo 'Error upgrading portage'
  exit 1
fi

emerge --ask=n --depclean
if [ $? -ne 0 ]; then
  echo 'Error cleaning portage'
  exit 1
fi

eselect news read >/dev/null 2>&1

echo -e '\n### Install dependencies...\n'

# install dependencies
echo 'app-editors/vscode Microsoft-vscode' >>/etc/portage/package.license
echo 'net-im/discord all-rights-reserved' >>/etc/portage/package.license
echo 'sys-firmware/intel-microcode intel-ucode' >>/etc/portage/package.license
echo 'www-client/google-chrome google-chrome' >>/etc/portage/package.license

echo 'net-libs/nodejs march-core2' >>/etc/portage/package.env

mkdir -p /etc/portage/env
echo 'CFLAGS="${CFLAGS} -march=core2"' >>/etc/portage/env/march-core2
echo 'CXXFLAGS="${CXXFLAGS} -march=core2"' >>/etc/portage/env/march-core2

emerge --ask=n \
  app-editors/vscode \
  app-laptop/laptop-mode-tools \
  media-fonts/noto-emoji \
  net-im/discord \
  sys-block/io-scheduler-udev-rules \
  sys-firmware/intel-microcode \
  www-client/google-chrome \
  x11-apps/setxkbmap \
  x11-apps/xinput \
  x11-base/xorg-server \
  x11-misc/numlockx

if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi
