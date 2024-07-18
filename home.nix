{ pkgs, lib, ... }:

{
  home = {
    stateVersion = "24.05";

    packages = [
      pkgs.vim
      pkgs.neovim
      pkgs.git
      pkgs.ripgrep
      pkgs.vscode
      pkgs.nodejs-18_x
      pkgs.mas
      pkgs.doctl
      pkgs.yarn
      # zsh agnoster font
      pkgs.powerline-fonts
      pkgs.nerdfonts
      pkgs.nodePackages.pnpm
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through "home.file".
    file = {
      # # Building this configuration will create a copy of "dotfiles/screenrc" in
      # # the Nix store. Activating the configuration will then make '~/.screenrc' a
      # # symlink to the Nix store copy.
      # ".screenrc".source = ./dotfiles/screenrc;

      # # You can also set the file content immediately.
      # ".gradle/gradle.properties".text = ''
      #   org.gradle.console=verbose
      #   org.gradle.daemon.idletimeout=3600000
      # '';
    };
  };

  programs = {
    direnv = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      userEmail = "ono.naoyaa@gmail.com";
      userName = "Naoya Ono";

      extraConfig = {
        init.defaultBranch = "main";

        core.editor = "vim";
      };
    };

    zsh = {
      enable = true;

      shellAliases = {
        sail = "./vendor/bin/sail";
      };

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "git"
        ];
      };
    };
  };
}
