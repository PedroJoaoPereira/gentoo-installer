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
sed -i "s/VIDEO_CARDS=\"\"/VIDEO_CARDS=\"intel i915 nvidia\"/g" /etc/portage/make.conf
# input devices - only for laptop touchpad
sed -i "s/INPUT_DEVICES=\"\"/INPUT_DEVICES=\"libinput\"/g" /etc/portage/make.conf

# remove all global use flags
sed -i "s/USE=\"dbus networkmanager\"/USE=\"\"/g" /etc/portage/make.conf

# print out portage configuration
echo -e '\n'
cat /etc/portage/make.conf

echo -e '\n### Create build profiles...\n'

# create single build job profile
cat <<EOF >/etc/portage/env/makeopts-jobs-1.conf
MAKEOPTS="--jobs=1"
EOF

# set packages to minimum build resources
echo 'dev-qt/qtbase makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'dev-qt/qtdeclarative makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'dev-util/spirv-tools makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'kde-apps/kate-addons makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'kde-apps/kdenlive makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'kde-misc/kdeconnect makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'media-libs/opencv makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'net-im/neochat makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'net-libs/nodejs makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'sys-devel/clang makeopts-jobs-1.conf' >>/etc/portage/package.env
echo 'sys-devel/llvm makeopts-jobs-1.conf' >>/etc/portage/package.env

# print out configuration files
cat /etc/portage/env/makeopts-jobs-1.conf
echo -e '\n'
cat /etc/portage/package.env

echo -e '\n### Changing profile to KDE stable...\n'

# change profile to kde plasma stable
eselect profile set $(eselect profile list | grep '.*plasma.*stable' | head -n 1 | grep -o '\[.*\]' | tr -d '[]')
if [ $? -ne 0 ]; then
  echo 'Error selecting profile'
  exit 1
fi

eselect profile list | grep '*'

echo -e '\n### Install profile dependencies...\n'

# change global use flags for some kde apps that require it
sed -i "s/USE=\"\"/USE=\"X geoclue harfbuzz libass -webengine -telepathy\"/g" /etc/portage/make.conf

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
echo 'sys-firmware/intel-microcode intel-ucode' >>/etc/portage/package.license
echo 'www-client/google-chrome google-chrome' >>/etc/portage/package.license
echo 'x11-drivers/nvidia-drivers NVIDIA-r2' >>/etc/portage/package.license

echo 'kde-apps/kde-apps-meta admin graphics multimedia network utils -accessibility -education -games -pim -sdk' >>/etc/portage/package.use
echo 'kde-plasma/plasma-meta bluetooth browser-integration crash-handler crypt cups desktop-portal discover display-manager elogind firewall gtk handbook kwallet legacy-systray networkmanager pulseaudio sddm smart wallpapers -accessibility -colord -flatpak -grub -plymouth -sdk -systemd -thunderbolt' >>/etc/portage/package.use

emerge --ask=n \
  app-laptop/laptop-mode-tools \
  kde-apps/kde-apps-meta \
  kde-plasma/plasma-meta \
  sys-firmware/intel-microcode \
  www-client/google-chrome \
  x11-base/xorg-server \

if [ $? -ne 0 ]; then
  echo 'Error installing'
  exit 1
fi

eselect news read >/dev/null 2>&1

echo -e '\n### Configuring display manager...\n'

sed -i "s/DISPLAYMANAGER=\"xdm\"/DISPLAYMANAGER=\"sddm\"/g" /etc/conf.d/display-manager

echo -e '\n### Adding services to openrc...\n'

# set up openrc services
rc-update add laptop_mode default
rc-update add elogind boot
rc-update add display-manager default
