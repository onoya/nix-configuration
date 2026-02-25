{ config, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      cursor-style = "block";
      background-opacity = 0.8;
      background-blur = true;
      working-directory = "${config.home.homeDirectory}/codes";
      window-save-state = "always";
      initial-window = false;
      quick-terminal-size = "100%,100%";

      keybind = [
        # Global hotkey to show/hide Ghostty
        "global:alt+space=toggle_quick_terminal"
        # Shift+Enter for newline in Claude Code
        "shift+enter=text:\\x1b\\r"
      ];
    };
  };
}
