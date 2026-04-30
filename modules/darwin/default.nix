{ pkgs, username, ... }:

let
  # Mac App Store apps — installed via activation script with sudo
  # because brew bundle + mas install is broken on macOS 14.8.2+
  # (Apple's CVE-2025-43411 patch requires sudo for installd)
  # Upstream: https://github.com/nix-darwin/nix-darwin/issues/1627
  # Tracking: https://github.com/onoya/nix-configuration/issues/63
  masApps = {
    Magnet = 441258766;
    GiphyCapture = 668208984;
  };

  masInstallScript = pkgs.writeShellScript "install-mas-apps" ''
    MAS="/opt/homebrew/bin/mas"
    echo "Managing Mac App Store apps..."
    ${builtins.concatStringsSep "\n" (builtins.attrValues (builtins.mapAttrs (name: id: ''
      if ! sudo -u ${username} "$MAS" list | grep -q "^${toString id} "; then
        echo "Installing ${name} (${toString id})..."
        sudo -u ${username} "$MAS" get ${toString id} || echo "WARNING: Failed to install ${name}"
      else
        echo "${name} already installed."
      fi
    '') masApps))}
  '';
in
{
  # Nix is managed by Determinate Systems' daemon (determinate-nixd).
  # nix-darwin's nix.* options are disabled to avoid conflicts.
  determinateNix.enable = true;
  determinateNix.customSettings = {
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

    brews = [
      "mas"
    ];

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

    masApps = {};
  };

  # Install Mac App Store apps via activation script (requires sudo)
  system.activationScripts.postActivation.text = ''
    ${masInstallScript}
  '';

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
