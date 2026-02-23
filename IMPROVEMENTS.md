# Nix Config Improvements

Tracking ongoing improvements to bring this config in line with community best practices.

## Done

- [x] Switch to Determinate Systems Nix installer in README
- [x] Document new machine onboarding flow (flake.nix step, explicit `--flake .#hostname` for bootstrap)
- [x] Add `just` with `rebuild`, `update`, `gc` recipes
- [x] Module pattern established (`modules/ghostty.nix`, `modules/claude.nix`)
- [x] `direnv` configured with zsh integration
- [x] Modern CLI tools — `bat`, `eza`, `fd`, `delta`, `lazygit`, `btop`, `yazi`
- [x] Shell aliases wired up (`cat`, `ls`, `ll`, `la`, `lt`, `find`, `lg`)
- [x] `nh` — replaces `rebuild` function and `just rebuild`/`update` recipes
- [x] `comma` + `nix-index` — run packages without installing
- [x] Module splitting — `modules/git.nix`, `modules/zsh.nix`, `modules/tmux.nix`
- [x] `devShells` pattern — already in use across projects (e.g. lumina5)

## In Progress

_Nothing currently in progress._

## Pending

### `starship` Prompt (Optional)
Replace oh-my-zsh with the starship prompt. Faster, Rust-based, native Home Manager support. Matter of taste.

- [ ] Evaluate vs current oh-my-zsh setup
- [ ] Add `programs.starship` to a module if switching

### Future Linux Support

- [x] Restructure into `hosts/` and `modules/darwin/` + `modules/home/` directories
- [x] Fix hardcoded `nixpkgs.hostPlatform` — now uses `system` arg from `mkDarwinSystem`
- [ ] Add `mkNixosSystem` helper and a Linux host when the time comes
