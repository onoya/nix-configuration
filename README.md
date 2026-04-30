# Nix Configuration

## New Machine Setup

Run the bootstrap script on a fresh macOS — it handles everything:

```sh
curl -sL https://raw.githubusercontent.com/onoya/nix-configuration/main/bootstrap.sh | bash
```

This will:
1. Install Xcode Command Line Tools
2. Install Nix via the [Determinate Systems installer](https://determinate.systems/posts/determinate-nix-installer)
3. Clone this repository to `~/dev/nix-configuration` (creates `~/dev` if needed)
4. Let you select or create a machine configuration
5. Run `nix-darwin switch` to build the full system
6. Generate an ed25519 SSH key and add it to GitHub
7. Switch the git remote from HTTPS to SSH
8. Create `~/.secrets` for environment variables

The script is idempotent — safe to re-run after a partial failure.

### Manual Setup

If you prefer to run steps individually:

<details>
<summary>Click to expand manual steps</summary>

#### 1. Install Xcode CLI Tools

```sh
xcode-select --install
```

#### 2. Install Nix

```sh
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

#### 3. Clone this repository

```sh
git clone https://github.com/onoya/nix-configuration.git ~/dev/nix-configuration
cd ~/dev/nix-configuration
```

#### 4. Add your machine to `flake.nix`

Add a new entry under `darwinConfigurations`:

```nix
"Your-MacBook-Name" = mkDarwinSystem {
  hostname = "Your-MacBook-Name";
  username = "yourusername";
};
```

Create the host directory:

```sh
mkdir -p hosts/Your-MacBook-Name
echo '{ ... }: { }' > hosts/Your-MacBook-Name/default.nix
```

#### 5. Bootstrap nix-darwin (first time only)

```sh
nix run nix-darwin -- switch --flake .#Your-MacBook-Name
```

#### 6. Set up SSH

```sh
ssh-keygen -t ed25519 -C "your@email.com"
gh auth login
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname -s)"
git remote set-url origin git@github.com:onoya/nix-configuration.git
```

</details>

### Subsequent rebuilds

```sh
darwin-rebuild switch --flake .
```

Or use the `rebuild` shell alias.

### Migrating existing machines from `~/codes` to `~/dev`

```sh
mv ~/codes ~/dev
ln -s ~/dev ~/codes    # backwards compat for IDE recent projects, bookmarks, etc.
cd ~/dev/nix-configuration
rebuild
```

The symlink keeps old references working. Remove it whenever you're ready.

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
