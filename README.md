# Nix Configuration

## Setup Guide

### Install Nix in Multi-user mode

```sh
sh <(curl -L https://nixos.org/nix/install)
```

### Install home-manager

```sh
nix-channel --add https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz home-manager
nix-channel --update
```

### Install nix-darwin

```sh
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```
