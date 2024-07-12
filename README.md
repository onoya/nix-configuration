# Nix Configuration

## Setup Guide

### Install Nix in Multi-user mode

```sh
sh <(curl -L https://nixos.org/nix/install)
```

### Add/Update required channels

```sh
./update-channels.sh
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
