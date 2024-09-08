#!/bin/bash

echo -e '\n### Creating build profiles...\n'
# core2 build profile
echo 'CFLAGS="${CFLAGS} -march=core2"' >>/etc/portage/env/march-core2
echo 'CXXFLAGS="${CXXFLAGS} -march=core2"' >>/etc/portage/env/march-core2

echo -e '\n### Installing extra dependencies...\n'
echo 'net-libs/nodejs march-core2' >>/etc/portage/package.env
echo 'app-editors/vscode Microsoft-vscode' >>/etc/portage/package.license
echo 'net-im/discord all-rights-reserved' >>/etc/portage/package.license
echo 'sys-firmware/intel-microcode intel-ucode' >>/etc/portage/package.license
echo 'www-client/google-chrome google-chrome' >>/etc/portage/package.license
emerge --ask=n \
  app-editors/vscode \
  gnome-base/gnome-light \
  net-im/discord \
  sys-firmware/intel-microcode \
  sys-power/power-profiles-daemon \
  www-client/google-chrome
if [ $? -ne 0 ]; then
  echo 'Error installing extra dependencies'
  exit 1
fi
eselect news read >/dev/null 2>&1

echo -e '\n### Reloading environment...\n'
env-update && source /etc/profile

echo -e '\n### Setting up customizations...\n'
# overrides wheel use polkit rules
mkdir -p /etc/polkit-1/rules.d/
cat <<EOF >/etc/polkit-1/rules.d/49-wheel.rules
polkit.addAdminRule(function(action, subject) {
    return ["unix-group:wheel"];
});
EOF
# sets display manager to gdm
sed -i "s/.*DISPLAYMANAGER=.*/DISPLAYMANAGER=\"gdm\"/g" /etc/conf.d/display-manager
# sets up openrc services
rc-update add NetworkManager default
rc-update add display-manager default
rc-update add elogind boot
rc-update add numlock default
rc-update add power-profiles-daemon default