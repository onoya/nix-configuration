{ pkgs, ... }:

{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  system.primaryUser = "onoya";

  homebrew = {
    enable = true;

    # Automatically update homebrew packages and run cleanup
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Removes all unused packages and casks
      upgrade = true;
    };

    casks = [
      "raycast"
      "authy"
      "brave-browser"
      "chatgpt"
      "claude"
      "cyberghost-vpn"
      "discord"
      "docker-desktop"
      "ea"
      "figma"
      "firefox"
      "ghostty"
      "google-chrome"
      "iterm2"
      "lastpass"
      "messenger"
      "mongodb-compass"
      "ngrok"
      "nvidia-geforce-now"
      "notion"
      "obs"
      "slack"
      "spotify"
      "tableplus"
      "visual-studio-code"
      "vlc"
      "zed"
      "zoom"
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

  # Enable Touch ID for sudo
  security.pam.services.sudo_local.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  security.pam.services.sudo_local.reattach = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages =
    [
    ];

  environment.variables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  # Auto upgrade nix package and the daemon service.
  # services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nixpkgs.config.allowUnfree = true;
  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
