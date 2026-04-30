#!/usr/bin/env bash
#
# Bootstrap a fresh macOS machine with this Nix configuration.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/onoya/nix-configuration/main/bootstrap.sh | bash
#
# Idempotent — safe to re-run after a partial failure or manual partial setup.
#
set -euo pipefail

REPO_URL_HTTPS="https://github.com/onoya/nix-configuration.git"
REPO_URL_SSH="git@github.com:onoya/nix-configuration.git"
DEV_DIR="$HOME/dev"
REPO_DIR="$DEV_DIR/nix-configuration"
LEGACY_REPO_DIR="$HOME/codes/nix-configuration"
SSH_KEY="$HOME/.ssh/id_ed25519"

# ─── Helpers ──────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m→ %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m! %s\033[0m\n' "$*"; }
fail()  { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

confirm() {
  printf '\033[1;33m? %s [Y/n] \033[0m' "$1"
  read -r answer </dev/tty
  case "${answer:-Y}" in
    [Yy]*) return 0 ;;
    *)     return 1 ;;
  esac
}

# ─── Step 1: Xcode Command Line Tools ────────────────────────────────────────

install_xcode_cli() {
  if xcode-select -p &>/dev/null; then
    ok "Xcode CLI tools already installed"
    return
  fi

  info "Installing Xcode Command Line Tools..."
  xcode-select --install

  # Wait for installation to complete
  info "Waiting for Xcode CLI tools installation to finish..."
  until xcode-select -p &>/dev/null; do
    sleep 5
  done
  ok "Xcode CLI tools installed"
}

# ─── Step 2: Nix ─────────────────────────────────────────────────────────────

install_nix() {
  if command -v nix &>/dev/null; then
    ok "Nix already installed"
    return
  fi

  info "Installing Nix (Determinate Systems installer)..."
  curl --proto '=https' --tlsv1.2 -sSf -L \
    https://install.determinate.systems/nix | sh -s -- install

  # Source nix in current shell
  if [[ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]]; then
    # shellcheck disable=SC1091
    . /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
  fi

  command -v nix &>/dev/null || fail "Nix installation failed — 'nix' not found on PATH"
  ok "Nix installed"
}

# ─── Step 3: Clone / locate repository ───────────────────────────────────────

locate_or_clone_repo() {
  mkdir -p "$DEV_DIR"

  # Already at the target location
  if [[ -d "$REPO_DIR/.git" ]]; then
    ok "Repository already at $REPO_DIR"
    return
  fi

  # Check for legacy ~/codes location
  if [[ -d "$LEGACY_REPO_DIR/.git" ]]; then
    warn "Found repository at legacy location: $LEGACY_REPO_DIR"
    if confirm "Move to $REPO_DIR?"; then
      mv "$LEGACY_REPO_DIR" "$REPO_DIR"
      ok "Moved repository to $REPO_DIR"

      # Clean up ~/codes if empty
      rmdir "$HOME/codes" 2>/dev/null && ok "Removed empty ~/codes directory" || true
      return
    else
      # User chose to keep legacy location — use it for this run
      REPO_DIR="$LEGACY_REPO_DIR"
      warn "Continuing with $REPO_DIR (update bootstrap.sh REPO_DIR if permanent)"
      return
    fi
  fi

  # Check if we're running from inside an existing clone (e.g., user ran ./bootstrap.sh)
  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
  if [[ -f "$script_dir/flake.nix" && -d "$script_dir/.git" ]]; then
    if [[ "$script_dir" != "$REPO_DIR" ]]; then
      warn "Found repository at $script_dir (not the standard location)"
      if confirm "Move to $REPO_DIR?"; then
        mv "$script_dir" "$REPO_DIR"
        ok "Moved repository to $REPO_DIR"
        return
      else
        REPO_DIR="$script_dir"
        warn "Continuing with $REPO_DIR"
        return
      fi
    fi
    ok "Running from repository at $REPO_DIR"
    return
  fi

  info "Cloning configuration repository via HTTPS..."
  git clone "$REPO_URL_HTTPS" "$REPO_DIR"
  ok "Repository cloned to $REPO_DIR"
}

# ─── Step 4: Select hostname ─────────────────────────────────────────────────

select_hostname() {
  local hosts_dir="$REPO_DIR/hosts"
  local hosts=()
  local current_hostname
  current_hostname="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"

  # Collect existing host directories
  for dir in "$hosts_dir"/*/; do
    [[ -d "$dir" ]] && hosts+=("$(basename "$dir")")
  done

  # Auto-detect: if current machine hostname matches an existing config, use it
  for host in "${hosts[@]}"; do
    if [[ "$host" == "$current_hostname" ]]; then
      ok "Detected matching configuration: $host"
      if confirm "Use this configuration?"; then
        HOSTNAME="$host"
        return
      fi
      break
    fi
  done

  echo ""
  info "Available machine configurations:"
  local i=1
  for host in "${hosts[@]}"; do
    echo "  $i) $host"
    ((i++))
  done
  echo "  $i) Create new configuration"
  echo ""

  printf '\033[1;33m? Select configuration [1-%d]: \033[0m' "$i"
  read -r selection </dev/tty

  if [[ "$selection" -eq "$i" ]]; then
    create_new_host
  elif [[ "$selection" -ge 1 && "$selection" -lt "$i" ]]; then
    HOSTNAME="${hosts[$((selection - 1))]}"
    ok "Selected: $HOSTNAME"
  else
    fail "Invalid selection"
  fi
}

create_new_host() {
  local current_hostname
  current_hostname="$(scutil --get LocalHostName 2>/dev/null || hostname -s)"

  printf '\033[1;33m? Hostname [%s]: \033[0m' "$current_hostname"
  read -r input_hostname </dev/tty
  HOSTNAME="${input_hostname:-$current_hostname}"

  printf '\033[1;33m? Username [%s]: \033[0m' "$(whoami)"
  read -r input_username </dev/tty
  local username="${input_username:-$(whoami)}"

  # Create host directory
  local host_dir="$REPO_DIR/hosts/$HOSTNAME"
  mkdir -p "$host_dir"
  cat > "$host_dir/default.nix" <<'EOF'
{ ... }:

{
  # Machine-specific configuration
  # Add per-machine packages, settings, or overrides here
}
EOF

  # Add darwinConfiguration entry to flake.nix
  local entry
  entry=$(cat <<ENTRY

      "$HOSTNAME" = mkDarwinSystem {
        hostname = "$HOSTNAME";
        username = "$username";
      };
ENTRY
)

  # Insert before the closing braces of darwinConfigurations
  if ! grep -q "\"$HOSTNAME\"" "$REPO_DIR/flake.nix"; then
    sed -i '' "/^    };$/,/^  };$/{
      /^    };$/{
        i\\
$entry
      }
    }" "$REPO_DIR/flake.nix"
  fi

  ok "Created configuration for $HOSTNAME (user: $username)"
}

# ─── Step 5: Build system ────────────────────────────────────────────────────

build_system() {
  info "Building system configuration for $HOSTNAME..."
  info "This will take a while on the first run — go grab a coffee."
  echo ""

  # nix-darwin needs to own /etc/nix/nix.custom.conf, but the Determinate
  # installer creates it first. Rename it so nix-darwin can take over.
  if [[ -f /etc/nix/nix.custom.conf ]] && ! readlink /etc/nix/nix.custom.conf &>/dev/null; then
    info "Moving Determinate's nix.custom.conf aside for nix-darwin..."
    sudo mv /etc/nix/nix.custom.conf /etc/nix/nix.custom.conf.before-nix-darwin
  fi

  cd "$REPO_DIR"
  local nix_bin
  nix_bin="$(which nix)"
  sudo "$nix_bin" run nix-darwin -- switch --flake ".#$HOSTNAME"

  ok "System configuration applied"
}

# ─── Step 6: SSH key setup ────────────────────────────────────────────────────

setup_ssh() {
  if [[ -f "$SSH_KEY" ]]; then
    ok "SSH key already exists at $SSH_KEY"
  else
    info "Generating ed25519 SSH key..."
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"

    printf '\033[1;33m? Email for SSH key [ono.naoyaa@gmail.com]: \033[0m'
    read -r ssh_email </dev/tty
    ssh_email="${ssh_email:-ono.naoyaa@gmail.com}"

    ssh-keygen -t ed25519 -C "$ssh_email" -f "$SSH_KEY"
    ok "SSH key generated"
  fi

  # Start ssh-agent and add key
  eval "$(ssh-agent -s)" &>/dev/null
  ssh-add "$SSH_KEY" 2>/dev/null

  # Check if key is already on GitHub
  if command -v gh &>/dev/null && gh auth status &>/dev/null; then
    local pubkey_fingerprint
    pubkey_fingerprint="$(ssh-keygen -lf "$SSH_KEY.pub" | awk '{print $2}')"

    if gh ssh-key list 2>/dev/null | grep -q "$pubkey_fingerprint"; then
      ok "SSH key already registered on GitHub"
      return
    fi
  fi

  # Add to GitHub
  if confirm "Add SSH key to GitHub?"; then
    local key_label
    key_label="${HOSTNAME:-$(hostname -s)}"

    # Only authenticate if not already logged in
    if ! gh auth status &>/dev/null; then
      info "Authenticating with GitHub..."
      gh auth login --web --hostname github.com --git-protocol ssh
    else
      ok "Already authenticated with GitHub"
    fi

    info "Adding SSH key to GitHub..."
    gh ssh-key add "$SSH_KEY.pub" --title "$key_label"
    ok "SSH key added to GitHub as '$key_label'"
  fi
}

# ─── Step 7: Switch remote to SSH ────────────────────────────────────────────

switch_remote_to_ssh() {
  cd "$REPO_DIR"
  local current_url
  current_url="$(git remote get-url origin 2>/dev/null || echo "")"

  if [[ "$current_url" == "$REPO_URL_SSH" ]]; then
    ok "Remote already using SSH"
    return
  fi

  info "Switching git remote from HTTPS to SSH..."
  git remote set-url origin "$REPO_URL_SSH"
  ok "Remote switched to SSH"
}

# ─── Step 8: Secrets file ────────────────────────────────────────────────────

setup_secrets() {
  if [[ -f "$HOME/.secrets" ]]; then
    ok "~/.secrets already exists"
    return
  fi

  info "Creating ~/.secrets file..."
  cat > "$HOME/.secrets" <<'EOF'
# Secrets — sourced by zsh on shell startup
# Add exports here: export KEY="value"
EOF
  chmod 600 "$HOME/.secrets"
  ok "Created ~/.secrets (chmod 600)"
}

# ─── Main ─────────────────────────────────────────────────────────────────────

main() {
  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║  macOS Nix Configuration Bootstrap       ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""

  install_xcode_cli
  install_nix
  locate_or_clone_repo
  select_hostname
  build_system
  setup_ssh
  switch_remote_to_ssh
  setup_secrets

  echo ""
  echo "╔══════════════════════════════════════════╗"
  echo "║  Bootstrap complete!                     ║"
  echo "╚══════════════════════════════════════════╝"
  echo ""
  echo "  Open a new terminal to load the full environment."
  echo ""
  echo "  Useful commands:"
  echo "    rebuild        — apply config changes"
  echo "    just update    — update flake inputs + rebuild"
  echo "    just gc        — clean up old generations"
  echo ""
}

main "$@"
