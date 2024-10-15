# Nix Configuration

## Setup Guide

### Install Nix in Multi-user mode

```sh
sh <(curl -L https://nixos.org/nix/install)
```

### Clone this repository

```sh
git clone git@github.com:onoya/nix-configuration.git
cd nix-configuration
```

### Initial setup for nix-darwin

This step is only required for the first time setup. For subsequent rebuilds, you can skip this step.

```sh
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .
```

For subsequent rebuilds, you can use the following command:

```sh
darwin-rebuild switch --flake .
```

## Cleaning up Storage

You may want to clean up Nix store from time to time to save storage space. You can use the following command to remove system versions older than 15 days, as well as old packages that are no longer in use.

```sh
nix-collect-garbage --delete-older-than 15d
```

## Update dependencies

To update dependencies, you can use the following command:

```sh
nix flake update
```

After updating dependencies, you can run the following command to update the system:

```sh
darwin-rebuild switch --flake .
```

## Update Brew packages

To update Brew packages, you can use the following command:

```sh
/opt/homebrew/bin/brew update
/opt/homebrew/bin/brew upgrade
```
