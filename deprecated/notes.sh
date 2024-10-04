### WIP
# emerge sys-process/cronie
# rc-update add sshd default
# rc-update add cronie default

# TODO:
# sets initramfs configuration
# mkdir -p /etc/dracut.conf.d
# cat <<EOF >/etc/dracut.conf.d/override.conf
# ${THIS_DRACUT_CONF}
# EOF

# live RAM
tmpfs /tmp tmpfs size=16G,noatime,nodev,nosuid 0 0
tmpfs /var/tmp tmpfs size=1G,noatime,nodev,nosuid 0 0

# -----

# changes global USE flags
sed -i "s/USE=\"\"/USE=\"${THIS_EXTRA_USE_FLAGS}\"/g" /etc/portage/make.conf
# selects CPU flags
sed -i "s/CPU_FLAGS_X86=\"\"/CPU_FLAGS_X86=\"$(cpuid2cpuflags | cut -d' ' -f2-)\"/g" /etc/portage/make.conf
# selects GPU flags
sed -i "s/VIDEO_CARDS=\"\"/VIDEO_CARDS=\"${THIS_VIDEO_CARDS}\"/g" /etc/portage/make.conf
# selects INPUT flags
sed -i "s/INPUT_DEVICES=\"\"/INPUT_DEVICES=\"${THIS_INPUT_DEVICES}\"/g" /etc/portage/make.conf

# -----

echo 'app-shells/zoxide ~amd64' >>/etc/portage/package.accept_keywords
echo 'app-admin/doas persist' >>/etc/portage/package.use
# installs dependencies
emerge --ask=n \
  app-admin/doas \
  app-admin/eclean-kernel \
  app-admin/stow \
  app-admin/yadm \
  app-editors/neovim \
  app-misc/fastfetch \
  app-portage/gentoolkit \
  app-shells/starship \
  app-shells/zoxide \
  dev-vcs/git \
  net-misc/chrony \
  net-misc/keychain \
  sys-apps/eza \
  sys-block/io-scheduler-udev-rules \
  sys-kernel/gentoo-kernel
