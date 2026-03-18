{ pkgs, username, ... }:

{
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "root" username ];
    extra-substituters = [ "https://devenv.cachix.org" ];
    extra-trusted-public-keys = [ "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=" ];
  };

  system.primaryUser = username;

  homebrew = {
    enable = true;

    # Automatically update homebrew packages and run cleanup
    onActivation = {
      autoUpdate = true;
      cleanup = "zap";  # Removes all unused packages and casks
      upgrade = true;
    };

    casks = [
      "authy"
      "brave-browser"
      "chatgpt"
      "claude"
      "claude-code"
      "cursor"
      "cyberghost-vpn"
      "discord"
      "docker-desktop"
      "ea"
      "figma"
      "firefox"
      "ghostty"
      "google-chrome"
      "mongodb-compass"
      "ngrok"
      "notion"
      "obs"
      "raycast"
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

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];

  environment.systemPackages = [];

  environment.variables = {
    NIXPKGS_ALLOW_INSECURE = "1";
  };

  # Create /etc/zshrc that loads the nix-darwin environment.
  programs.zsh = {
    enable = true;
    enableCompletion = true;
  };

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  nixpkgs.config.allowUnfree = true;
}
