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

## In Progress

_Nothing currently in progress._

## Pending

### `starship` Prompt (Optional)
Replace oh-my-zsh with the starship prompt. Faster, Rust-based, native Home Manager support. Matter of taste.

- [ ] Evaluate vs current oh-my-zsh setup
- [ ] Add `programs.starship` to a module if switching

### `comma` (`,`)
Run any Nix package without installing it (e.g. `, ffmpeg ...`).

- [ ] Add `nix-index` and `comma` to packages

### `devShells` Pattern
Per-project dev environments via `flake.nix` + `direnv`. The Nix holy grail for project isolation.

- [ ] Document the pattern and add an example to README
- [ ] Add example `devShell` to this repo's flake for working on the nix config itself

### Future Linux Support
Low-effort structural prep before the config grows further.

- [ ] Split `darwin.nix` darwin-specific config from shared config
- [ ] Restructure into `hosts/` and `common/` directories
- [ ] Fix hardcoded `nixpkgs.hostPlatform = "aarch64-darwin"` in `darwin.nix` (use `system` arg from `mkDarwinSystem`)
