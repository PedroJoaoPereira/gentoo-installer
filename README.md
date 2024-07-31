# Gentoo Installer

Gentoo installation script for my machines.

```bash
loadkeys pt-latin9
iwctl
station wlan0 connect NETWORK_NAME
PASSWORD
EXIT
ping gentoo.org
pacman -Sy git wget curl
git clone https://github.com/pedrojoaopereira/gentoo-installer
cd gentoo-installer
nano ./hosts/HOSTNAME.sh
ENTER NEW PASSWORD
./hosts/HOSTNAME.sh 2>&1 | tee ~/intall.log
```

