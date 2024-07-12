# Nix Configuration

## Setup Guide

### Install Nix in Multi-user mode

```sh
sh <(curl -L https://nixos.org/nix/install)
```

### Add specific channel versions for nixpkgs and home-manager

```sh
nix-channel --add https://nixos.org/channels/nixpkgs-23.11-darwin nixpkgs
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update
```

### Install nix-darwin

```sh
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

### Clone this repository

```sh
git clone git@github.com:onoya/nix-configuration.git
```

### Build and switch to the configuration

```sh
darwin-rebuild switch -I darwin-config=$HOME/codes/nix-configuration/darwin-configuration.nix
```
