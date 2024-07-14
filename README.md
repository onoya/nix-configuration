# Nix Configuration

## Setup Guide

### Install Nix in Multi-user mode

```sh
sh <(curl -L https://nixos.org/nix/install)
```

### Install nix-darwin

```sh
nix-build https://github.com/LnL7/nix-darwin/archive/master.tar.gz -A installer
./result/bin/darwin-installer
```

### Clone this repository

```sh
git clone git@github.com:onoya/nix-configuration.git
cd nix-configuration
```

### Add/Update required channels

```sh
./update-channels.sh
```

### Build and switch to the configuration

```sh
darwin-rebuild switch -I darwin-config=./darwin-configuration.nix
```

## Cleaning up Storage

You may want to clean up Nix store from time to time to save storage space. You can use the following command to remove system versions older than 15 days, as well as old packages that are no longer in use.

```sh
nix-collect-garbage --delete-older-than 15d
```
