# Nix Configuration

## New Machine Setup

### 1. Install Nix

Use the [Determinate Systems installer](https://determinate.systems/posts/determinate-nix-installer) — it handles macOS quirks, enables flakes by default, and includes a clean uninstaller.

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

### 2. Clone this repository

```sh
git clone git@github.com:onoya/nix-configuration.git
cd nix-configuration
```

### 3. Add your machine to `flake.nix`

Add a new entry under `darwinConfigurations` in `flake.nix`:

```nix
"Your-MacBook-Name" = mkDarwinSystem {
  hostname = "Your-MacBook-Name";
  username = "yourusername";
};
```

The hostname should match what you want the machine to be called (check current hostname with `scutil --get LocalHostName`).

### 4. Bootstrap nix-darwin (first time only)

```sh
nix run nix-darwin -- switch --flake .#Your-MacBook-Name
```

This sets the machine hostname, installs all packages, and puts `darwin-rebuild` on your PATH.

### 5. Subsequent rebuilds

```sh
darwin-rebuild switch --flake .
```

Or use the `rebuild` shell alias. After the initial bootstrap, the hostname is set by Nix so no `#hostname` suffix is needed.

---

## Day-to-Day Operations

Commands are available via `just` from the repo root:

```sh
just rebuild   # apply config changes (no package updates)
just update    # update flake inputs and rebuild
just gc        # remove generations older than 30 days
```

Run `just` with no arguments to list all available commands.

The Determinate Systems daemon (`determinate-nixd`) automatically keeps the Nix binary up to date — no manual upgrade step needed.

---

## Cleaning Up

Remove leftover channels if you previously used channel-based Nix (not needed for pure flakes):

```sh
nix-channel --list              # check for leftover channels
nix-channel --remove nixpkgs    # remove if present
nix-channel --remove home-manager
```

---

## Secrets Management

Secrets (API keys, tokens, credentials) are managed via `~/.secrets`, which is sourced automatically by zsh. This file is **not** tracked in git and must be created manually on each machine.

```sh
touch ~/.secrets
chmod 600 ~/.secrets
```

```sh
# ~/.secrets
export GITHUB_TOKEN="ghp_xxxxxxxxxxxx"
export OPENAI_API_KEY="sk-xxxxxxxxxxxx"
export AWS_ACCESS_KEY_ID="AKIA..."
export AWS_SECRET_ACCESS_KEY="..."
```

After editing `~/.secrets`, run `source ~/.zshrc` or open a new terminal.
