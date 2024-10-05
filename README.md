# Gentoo Installer

Gentoo installation script for `amd64` with `openRC`.

This script is intended to create a default gentoo base system (even though opinionated for my use cases) with a distribution kernel and `doas` instead of `sudo`, as well as hardcoded region setup and language.

### Disclaimer

This project can be used as reference for different solutions but is not the final and ultimate solution as some decisions are very opinionated as referred above.

Any contribution either in the form of issues discovering, pull requests or ideas are welcome.

## Install

From an Arch linux installation ISO:

```bash
# loads your keyboard layout
loadkeys pt-latin9

# connects to the internet by wifi (if needed)
iwctl
station wlan0 connect NETWORK_NAME
PASSWORD
exit

# checks internet connectivity
ping gentoo.org

# installs required dependencies
pacman -Sy git wget

# clones this project
git clone https://github.com/pedrojoaopereira/gentoo-installer

# executes installation script
gentoo-installer/install.sh
```

