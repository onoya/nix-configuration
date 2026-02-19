# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a **Nix-darwin configuration** for managing macOS development environments declaratively using Nix flakes. The configuration supports multiple machines and integrates Nix packages with Homebrew and Mac App Store applications through nix-homebrew.

## Core Architecture

### Main Configuration Files
- **`flake.nix`** - Primary entry point defining system configuration, inputs, and outputs
- **`darwin.nix`** - System-level macOS configuration (homebrew, system defaults, environment)
- **`home.nix`** - User-level configuration via Home Manager (packages, dotfiles, shell)
- **`modules/`** - Modular configuration components for specific applications

### Configuration Pattern
The system uses a flake-based approach with:
- **nixpkgs-unstable** as the primary package source
- **nix-darwin** for macOS system management
- **Home Manager** for user environment configuration
- **nix-homebrew** for declarative Homebrew management
- Multi-machine support via flake outputs

## Common Commands

### System Management
```bash
# Rebuild system configuration (has zsh alias 'rebuild')
darwin-rebuild switch --flake .

# Update all flake dependencies and rebuild
nix flake update
darwin-rebuild switch --flake .

# Clean up old package generations
nix-collect-garbage --delete-older-than 15d
```

### Initial Setup (for new systems)
```bash
nix run nix-darwin --extra-experimental-features nix-command --extra-experimental-features flakes -- switch --flake .
```

## Development Environment

### Package Management Strategy
- **Nix packages**: Development tools, CLI utilities, programming languages
- **Homebrew casks**: GUI applications managed declaratively via nix-homebrew
- **Mac App Store**: Apple ecosystem apps

### Key Tools Configured
- **Shell**: Zsh with Oh My Zsh, autosuggestions, syntax highlighting
- **Development**: Node.js 20, pnpm, git, neovim, tmux
- **Terminal**: Ghostty (primary), iTerm2 configurations included
- **Navigation**: zoxide for smart directory jumping

### Environment Variables
- `PNPM_HOME` configured for global package management
- Development paths automatically configured via Nix
- Secrets managed via `~/.secrets` (see README.md for setup)

## Workflow Notes

### Making Changes
1. Edit configuration files (`darwin.nix`, `home.nix`, or modules)
2. Test with `darwin-rebuild switch --flake .`
3. Commit changes to version control
4. Use feature branches for significant updates

### Version Management
- System state version: Currently 25.05
- Uses `flake.lock` for reproducible builds
- Update workflow via pull requests from feature branches

### Modular Configuration
When adding new application configurations, create separate modules in `modules/` directory following the pattern established by `ghostty.nix`.