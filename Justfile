# List available commands
default:
    @just --list

# Rebuild and switch to current configuration
rebuild:
    nh darwin switch .

# Update flake inputs and rebuild
update:
    nix flake update
    nh darwin switch .

# Remove generations older than 30 days
gc:
    nix-collect-garbage --delete-older-than 30d
