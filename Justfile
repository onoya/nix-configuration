# List available commands
default:
    @just --list

# Rebuild and switch to current configuration
rebuild:
    sudo darwin-rebuild switch --flake .

# Update all flake inputs and rebuild
update:
    nix flake update
    sudo darwin-rebuild switch --flake .

# Remove generations older than 15 days
gc:
    nix-collect-garbage --delete-older-than 15d
