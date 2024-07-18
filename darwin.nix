{ pkgs, ... }:

{
  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  homebrew = {
    enable = true;

    casks = [
      "alfred"
      "authy"
      "brave-browser"
      "google-chrome"
      "firefox"
      "notion"
      "visual-studio-code"
      "messenger"
      "iterm2"
      "tableplus"
      "lastpass"
      "slack"
      "docker"
      "figma"
      "discord"
      "cyberghost-vpn"
      "spotify"
      "mongodb-compass"
      "vlc"
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

  environment.variables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
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
