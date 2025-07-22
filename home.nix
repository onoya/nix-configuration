{ config, pkgs, lib, ... }:

let
  # This gets the directory where the home.nix file is located
  dotfiles = builtins.toString ./.config/.;
in
{
  imports = [
    # Ghostty config
    ./modules/ghostty.nix
    # Claude Code config
    ./modules/claude.nix
  ];

  home = {
    stateVersion = "25.05";

    packages = [
      pkgs.awscli2
      pkgs.claude-code
      pkgs.doctl
      pkgs.ffmpeg
      pkgs.fzf
      pkgs.git
      pkgs.gh
      pkgs.neovim
      pkgs.ngrok
      pkgs.nodejs_20
      pkgs.mas
      pkgs.pnpm_9
      # zsh agnoster font
      pkgs.powerline-fonts
      pkgs.ripgrep
      pkgs.tmux
      pkgs.unar
      pkgs.vim
      pkgs.vscode
      pkgs.yarn
      pkgs.yt-dlp
      pkgs.zoxide
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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      shellAliases = {
        sail = "./vendor/bin/sail";
        ll = "ls -l";
      };

      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
        plugins = [
          "git"
        ];
      };

      initContent = ''
        # Change to ~/codes directory when opening new terminal (if starting from home)
        if [[ "$PWD" == "$HOME" ]]; then
          cd ~/codes 2>/dev/null || true
        fi

        # Auto-start tmux session
        if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
          exec tmux new-session -A -s main
        fi

        # Function to handle darwin-rebuild with sudo
        rebuild() {
          sudo darwin-rebuild switch --flake .#
        }
      '';
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
        set -g status-right 'Continuum status: #{continuum_status}'

        # reload config
        bind r source-file ~/.config/tmux/tmux.conf \; display-message "Config reloaded!"

        # change binding for split horizontally to - and set it to the current path
        unbind %
        bind | split-window -h -c "#{pane_current_path}"

        # change binding for split vertically to | and set it to the current path
        unbind '"'
        bind - split-window -v -c "#{pane_current_path}"

        # creates a new window in the current path
        bind c new-window -c "#{pane_current_path}"

        # resize panes
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
