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
      pkgs.neofetch
      pkgs.nh
      pkgs.ngrok
      pkgs.nix-index
      pkgs.nodejs_24
      pkgs.mas
      pkgs.pnpm_9
      # zsh agnoster font
      pkgs.powerline-fonts
      pkgs.ripgrep
      pkgs.unar
      pkgs.vim
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
