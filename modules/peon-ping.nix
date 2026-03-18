{ inputs, pkgs, lib, config, ... }:

let
  peonPkg = inputs.peon-ping.packages.${pkgs.stdenv.hostPlatform.system}.default;
  peonDir = "${config.home.homeDirectory}/.openpeon";
in
{
  # Manage packs dir ourselves so both og-packs and registry packs can coexist
  home.activation.peonPacks = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    packsDir="${peonDir}/packs"

    # Ensure packs dir is a real writable directory, not a Nix store symlink
    if [ -L "$packsDir" ]; then
      rm "$packsDir"
    fi
    mkdir -p "$packsDir"

    # Install registry packs
    if [ ! -d "$packsDir/jarvis-mk2" ]; then
      ${peonPkg}/bin/peon packs install jarvis-mk2 || true
    fi
  '';

  programs.peon-ping = {
    enable = true;
    package = peonPkg;

    settings = {
      default_pack = "jarvis-mk2";
      volume = 0.7;
      enabled = true;
      desktop_notifications = false;
      categories = {
        "session.start" = true;
        "task.complete" = true;
        "task.error" = true;
        "input.required" = true;
        "resource.limit" = true;
        "user.spam" = true;
      };
    };

    enableZshIntegration = true;
  };
}
