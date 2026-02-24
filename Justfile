# List available commands
default:
    @just --list

# Rebuild and switch to current configuration
rebuild:
    nh darwin switch .

# Full system update: upgrade Nix, update flake inputs, and rebuild
update:
    sudo nix upgrade-nix
    nix flake update
    nh darwin switch .

# Remove generations older than 30 days
gc:
    nix-collect-garbage --delete-older-than 30d
