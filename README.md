# Gentoo Installer

Gentoo installation script for `amd64` with `openRC`.

This script is intended to create a default gentoo base system (even though opinionated for my use cases) with a distribution kernel and `doas` instead of `sudo`, as well as my own preferred base toolkit: `chrony`, `elogind`, `networkmanager` and `openrc`.

### Disclaimer

This project can be used as reference for different solutions but is not the final and ultimate approach as some decisions are very opinionated as referred above.

Any contribution either in the form of issues discovering, pull requests or ideas are welcome.

## Install

This installation process has two install approaches, a _install_ script that assumes that the required dependency `wget` is installed and assumes that the project was clones, and a more comfy approach _web-install_ that goes through the whole installation with minimal interaction.

This script assumes a `debian` based environment is used as the install environment and a root terminal shell.

```bash
sudo su
```

### _web-install_ 

To start the installation, run the following command in a live `debian` base ISO such as Ubuntu:

```bash
apt update
apt install curl -y
bash <(curl -s https://raw.githubusercontent.com/pedrojoaopereira/gentoo-installer/refs/heads/main/web-install.sh)
```

To install a templated setup - that reads the system configuration from a properties file, run the following command:

```bash
apt update
apt install curl -y
bash <(curl -s https://raw.githubusercontent.com/pedrojoaopereira/gentoo-installer/refs/heads/main/web-install.sh) gentoo-laptop-msi-es
```

### _install_

To start the installation, run the following command in a live `debian` base ISO such as Ubuntu:

```bash
apt update
apt install curl git wget -y
git clone https://github.com/pedrojoaopereira/gentoo-installer
gentoo-installer/install.sh 2>&1 | tee ./install.log
```

To install a templated setup - that reads the system configuration from a properties file, run the following command:

```bash
apt update
apt install curl git wget -y
git clone https://github.com/pedrojoaopereira/gentoo-installer
gentoo-installer/install.sh gentoo-laptop-msi-es 2>&1 | tee ./install.log
```