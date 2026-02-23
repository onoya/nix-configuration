# List available commands
default:
    @just --list

# Rebuild and switch to current configuration
rebuild:
    nh darwin switch .

# Update all flake inputs and rebuild
update:
    nix flake update
    nh darwin switch .

# Remove generations older than 15 days
gc:
    nix-collect-garbage --delete-older-than 15d
