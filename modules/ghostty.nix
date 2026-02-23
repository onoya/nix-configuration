{ config, lib, pkgs, ... }:

{
  home.file.".config/ghostty/config".text = ''
    cursor-style = block
    background-opacity = 0.8
    background-blur = true
    working-directory = ${config.home.homeDirectory}/codes
    window-save-state = always

    # Global hotkey to show/hide Ghostty
    keybind = global:alt+space=toggle_quick_terminal

    # Shift+Enter for newline in Claude Code
    keybind = shift+enter=text:\x1b\r
  '';
}
