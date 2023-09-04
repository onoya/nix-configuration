{ config, pkgs, ... }:

{
  imports = [ <home-manager/nix-darwin> ];

  users.users.onoya = {
    name = "onoya";
    home = "/Users/onoya";
  };

  home-manager.users.onoya = { pkgs, ... }: {
    home.stateVersion = "23.05";
    nixpkgs.config.allowUnfree = true;

    home.packages = [
      pkgs.vim
      pkgs.neovim
      pkgs.git
      pkgs.neovim
      pkgs.ripgrep
      pkgs.vscode
      pkgs.nodejs-18_x
      pkgs.mas
      pkgs.doctl
      pkgs.yarn
      # zsh agnoster font
      pkgs.powerline-fonts
    ];

    programs.direnv.enable = true;
    programs.direnv.enableZshIntegration = true;

    programs.git = {
      enable = true;
      userEmail = "ono.naoyaa@gmail.com";
      userName = "Naoya Ono";

      extraConfig = {
        init.defaultBranch = "main";

        core.editor = "vim";
      };
    };

    programs.zsh = {
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

  homebrew = {
    enable = true;

    casks = [
      "brave-browser"
      "google-chrome"
      "firefox"
      "notion"
      "visual-studio-code"
      "messenger"
      "iterm2"
      "tableplus"
      "alfred"
      "lastpass"
      "slack"
      "authy"
      "docker"
      "figma"
      "discord"
      "cyberghost-vpn"
      "spotify"
      "mongodb-compass"
    ];

    # Mac App Store Apps
    masApps = {
      Magnet = 441258766;
      GiphyCapture = 668208984;
    };
  };

  # System configuration
  system = {
    defaults.dock.autohide = true;

    defaults.screencapture.location = "~/Pictures";

    # Disable adding period with double-space
    defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;

    # Trackpad
    defaults.trackpad.Clicking = true;
    defaults.trackpad.Dragging = true;

    keyboard.enableKeyMapping = true;
    keyboard.remapCapsLockToControl = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
    ];

  # Use a custom configuration.nix location.
  # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
  # environment.darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.zsh.enable = true;  # default shell on catalina
  # programs.fish.enable = true;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
}
