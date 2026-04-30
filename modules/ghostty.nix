{ config, lib, pkgs, ... }:

{
  home.file.".config/ghostty/config".text = ''
    font-family = JetBrainsMono Nerd Font
    cursor-style = block
    background-opacity = 0.8
    background-blur = true
    working-directory = ${config.home.homeDirectory}/dev
    window-save-state = always
    initial-window = false

    # Global hotkey to show/hide Ghostty
    keybind = global:alt+space=toggle_quick_terminal
    quick-terminal-size = 100%,100%

    # Shift+Enter for newline in Claude Code
    keybind = shift+enter=text:\x1b\r
  '';
}
