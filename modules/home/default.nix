{ config, pkgs, lib, ... }:

{
  imports = [
    ../ghostty.nix
    ../claude.nix
    ../git.nix
    ../nvim.nix
    ../zsh.nix
    ../tmux.nix
  ];

  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "blue";

    # Neovim theming is managed by nixCats and its own plugin system
    nvim.enable = false;

    # Starship uses a custom prompt with non-catppuccin colors
    starship.enable = false;
  };

  home = {
    stateVersion = "25.05";

    packages = [
      pkgs.awscli2
      pkgs.bat
      pkgs.btop
      pkgs.comma
      pkgs.doctl
      pkgs.eza
      pkgs.fd
      pkgs.ffmpeg
      pkgs.fzf
      pkgs.gh
      pkgs.jq
      pkgs.just
      pkgs.lazygit
      pkgs.neo
      pkgs.fastfetch
      pkgs.nh
      pkgs.ngrok
      pkgs.nix-index
      pkgs.nodejs_24
      pkgs.mas
      pkgs.pnpm_9
      pkgs.ripgrep
      pkgs.unar
      pkgs.vscode
      pkgs.yarn
      pkgs.yazi
      pkgs.zoxide
    ];
  };

  home.sessionVariables = {
    PNPM_HOME = "${config.home.homeDirectory}/.local/share/pnpm";
  };

  home.sessionPath = [
    "$PNPM_HOME"
  ];

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
