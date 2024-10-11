# Gentoo Installer

Gentoo installation script for `amd64` with `openRC`.

This script is intended to create a default gentoo base system (even though opinionated for my use cases) with a distribution kernel and `doas` instead of `sudo`, as well as my own preferred base dependencies: `yadm`, `neovim`, `fastfetch`, `starship`, `zoxide`, `keychain` and `eza`. `networkmanager`, `chrony`, `elogind` and `openrc` are also part of the base toolkit.

### Disclaimer

This project can be used as reference for different solutions but is not the final and ultimate approach as some decisions are very opinionated as referred above.

Any contribution either in the form of issues discovering, pull requests or ideas are welcome.

## Install

To install, run the following command in a live `debian` base ISO such as Ubuntu:

```bash
bash <(curl -s https://raw.githubusercontent.com/PedroJoaoPereira/gentoo-installer/refs/heads/main/web-install.sh)
```

To install a templated setup, run the following command:

```bash
bash <(curl -s https://raw.githubusercontent.com/PedroJoaoPereira/gentoo-installer/refs/heads/main/web-install.sh) gentoo-laptop-msi-es
```
