{ config, pkgs, lib, ... }:

let
  # This gets the directory where the home.nix file is located
  dotfiles = builtins.toString ./.config/.;
in
{
  home = {
    stateVersion = "24.11";

    packages = [
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
      # zsh agnoster font
      pkgs.powerline-fonts
      pkgs.nerdfonts
      pkgs.pnpm_9

      pkgs.ffmpeg
      pkgs.yt-dlp
      pkgs.unar
    ];

    # Home Manager is pretty good at managing dotfiles. The primary way to manage
    # plain files is through "home.file".
    file = {
      ".config/ghostty/config".source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/ghostty/config";
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

    tmux = {
      enable = true;
      shortcut = "a";
      historyLimit = 100000;
      baseIndex = 1;
      newSession = true;

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
      ];

      extraConfig = ''
        set-option -g default-shell ${pkgs.zsh}/bin/zsh
        set-option -g default-command ${pkgs.zsh}/bin/zsh

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

    alacritty = {
      enable = true;
      settings = {
        live_config_reload = true;
        working_directory = "~/codes";

        window = {
          padding.x = 10;
          padding.y = 10;
          decorations = "Buttonless";
          opacity = 0.8;
          blur = true;
        };

        font = {
          normal = {
            family = "MesloLGS Nerd Font";
          };

          size = 14.0;
        };
      };
    };
  };
}
