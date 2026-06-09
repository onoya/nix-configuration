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

This repo uses [`just`](https://github.com/casey/just) as a task runner and [`nh`](https://github.com/viperML/nh) (nix-helper) as the rebuild driver. `nh` wraps `darwin-rebuild` and shows a diff of what will change before applying.

```bash
# Rebuild system configuration (runs `nh darwin switch .`)
just rebuild

# Also available as a zsh function `rebuild` that works from any directory
rebuild

# Update flake inputs and rebuild
just update

# Clean up package generations older than 30 days
just gc

# List all available recipes
just
```

Prefer `just rebuild` / `rebuild` over `darwin-rebuild switch --flake .` — same end result, but `nh` gives a diff preview and nicer output. Fall back to raw `darwin-rebuild` only when debugging `nh` itself.

### Initial Setup (for new systems)

Use the bootstrap script — see [README.md](./README.md). For manual first-time bootstrap before `nh` is installed:

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
2. Test with `just rebuild`
3. Commit changes to version control
4. Use feature branches for significant updates

### Version Management
- System state version: Currently 25.05
- Uses `flake.lock` for reproducible builds
- Update workflow via pull requests from feature branches

### Modular Configuration
When adding new application configurations, create separate modules in `modules/` directory following the pattern established by `ghostty.nix`.