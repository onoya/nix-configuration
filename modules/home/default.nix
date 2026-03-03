{ config, pkgs, lib, ... }:

{
  imports = [
    ../claude.nix
    ../fastfetch.nix
    ../ghostty.nix
    ../git.nix
    ../nvim.nix
    ../tmux.nix
    ../zsh.nix
  ];

  home = {
    stateVersion = "25.05";

    packages = [
      pkgs.awscli2
      pkgs.bat
      pkgs.btop
      pkgs.comma
      pkgs.devenv
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
      pkgs.nh
      pkgs.nix-output-monitor
      pkgs.nodejs_24
      pkgs.mas
      pkgs.pnpm_9
      pkgs.ripgrep
      pkgs.unar
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
      stdlib = ''
        eval "$(${lib.getExe pkgs.devenv} direnvrc)"
      '';
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
