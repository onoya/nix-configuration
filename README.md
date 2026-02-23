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

## Secrets Management

Secrets (API keys, tokens, credentials) are managed via `~/.secrets` file which is sourced automatically by zsh.

### Setup

```sh
# Create the secrets file (not tracked in git)
touch ~/.secrets
chmod 600 ~/.secrets
```

### Format

```sh
# ~/.secrets
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxx"
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
```

### Important Notes

- This file is **NOT** managed by Nix and must be created manually on each machine
- Never commit secrets to version control
- Use `chmod 600` to restrict file permissions
- After editing `~/.secrets`, run `source ~/.zshrc` or open a new terminal for changes to take effect
