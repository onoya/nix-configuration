{ config, pkgs, lib, ... }:

let
  # This gets the directory where the home.nix file is located
  dotfiles = builtins.toString ./.config/.;
in
{
  imports = [
    # Ghostty config
    ./modules/ghostty.nix
  ];

  home = {
    stateVersion = "25.05";

    packages = [
      pkgs.awscli2
      pkgs.claude-code
      pkgs.vim
      pkgs.neovim
      pkgs.git
      pkgs.ripgrep
      pkgs.vscode
      pkgs.nodejs_20
      pkgs.mas
      pkgs.ngrok
      pkgs.doctl
      pkgs.yarn
      pkgs.tmux
      pkgs.fzf
      # zsh agnoster font
      pkgs.powerline-fonts
      pkgs.pnpm_9

      pkgs.ffmpeg
      pkgs.yt-dlp
      pkgs.unar
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

    tmux = {
      enable = true;
      shortcut = "a";
      historyLimit = 100000;
      baseIndex = 1;

      plugins = [
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        pkgs.tmuxPlugins.continuum
        pkgs.tmuxPlugins.better-mouse-mode
        pkgs.tmuxPlugins.sensible
        pkgs.tmuxPlugins.tmux-fzf
      ];

      extraConfig = ''
        set-option -g default-shell ${pkgs.zsh}/bin/zsh
        set-option -g default-command ${pkgs.zsh}/bin/zsh

        set -g @continuum-restore 'on'

        unbind %
        bind | split-window -h -c "#{pane_current_path}"

        unbind '"'
        bind - split-window -v -c "#{pane_current_path}"

        bind -r j resize-pane -D 5
        bind -r k resize-pane -U 5
        bind -r l resize-pane -R 5
        bind -r h resize-pane -L 5

        bind -r m resize-pane -Z

        set -g mouse on
      '';
    };
  };
}
