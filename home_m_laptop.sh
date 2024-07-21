doas su # with password

# add to dracut conf
# /etc/dracut.conf.d/override.conf
add_drivers+=" i915 "
dracut --force

# reselect mirrors
emerge --oneshot --ask=n app-portage/mirrorselect
mirrorselect -i
rm -rf make.conf.backup

# choose cpu flags
emerge --oneshot --ask=n app-portage/cpuid2cpuflags
sed -i "s/CPU_FLAGS_X86=\"\"/CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d' ' -f2-)\"/g" /etc/portage/make.conf
# select video cards - only for intel graphics
sed -i "s/VIDEO_CARDS=\"\"/VIDEO_CARDS=\"intel i915 nvidia\"/g" /etc/portage/make.conf
# input devices - only for laptop touchpad
sed -i "s/INPUT_DEVICES=\"\"/INPUT_DEVICES=\"evdev libinput synaptics\"/g" /etc/portage/make.conf

# change global use flags
sed -i "s/USE=\"dbus networkmanager\"/USE=\"\"/g" /etc/portage/make.conf

# change profile
eselect profile list
eselect profile set XXX

# update system after flag changes
emerge --ask=n --verbose --update --deep --changed-use --with-bdeps=y --backtrack=30 @world
emerge --ask=n --depclean
eselect news read

# install dependencies
echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords

echo 'sys-firmware/intel-microcode intel-ucode' >>/etc/portage/package.license
echo 'www-client/google-chrome google-chrome' >>/etc/portage/package.license

emerge --ask=n \
  app-admin/stow \
  app-laptop/laptop-mode-tools \
  app-shells/starship \
  app-shells/zoxide \
  sys-apps/eza \
  sys-firmware/intel-microcode \
  sys-process/btop \
  www-client/google-chrome

rc-update add laptop_mode default
