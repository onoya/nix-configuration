{ config, lib, pkgs, ... }:

{
  home.file.".config/ghostty/config".text = ''
    cursor-style = block
    shell-integration-features = no-cursor
    background-opacity = 0.9
    working-directory = ${config.home.homeDirectory}/codes
    window-save-state = always

    # Global hotkey to show/hide Ghostty
    keybind = global:alt+space=toggle_quick_terminal
  '';
}
