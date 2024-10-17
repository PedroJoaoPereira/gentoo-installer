# add more dependencies flags
echo 'media-video/pipewire sound-server' >>/etc/portage/package.use
echo 'net-misc/networkmanager -modemmanager' >>/etc/portage/package.use
echo 'app-editors/vscode Microsoft-vscode' >>/etc/portage/package.license

# build profile
mkdir -p /etc/portage/env
echo 'CFLAGS="${CFLAGS} -march=core2"' >>/etc/portage/env/march-core2
echo 'CXXFLAGS="${CXXFLAGS} -march=core2"' >>/etc/portage/env/march-core2

echo 'net-libs/nodejs march-core2' >>/etc/portage/package.env

# create single build job profile
cat <<EOF >/etc/portage/env/makeopts-jobs-1.conf
MAKEOPTS="--jobs=1"
EOF

echo 'net-libs/nodejs makeopts-jobs-1.conf' >>/etc/portage/package.env

emerge --ask=n \
  app-editors/vscode \
  app-laptop/laptop-mode-tools \
  media-fonts/noto-emoji \
  sys-power/acpilight \
  sys-power/acpitool \
  sys-power/power-profiles-daemon \
  x11-misc/numlockx \
  x11-themes/neutral-xcursors

rc-update add laptop_mode default
rc-update add numlock default
rc-update add power-profiles-daemon default

# change profile to desktop stable
eselect profile set $(eselect profile list | grep '.*desktop.*stable' | head -n 1 | grep -o '\[.*\]' | tr -d '[]')
emerge --ask=n --verbose --update --deep --changed-use --with-bdeps=y --backtrack=30 @world
