{ ... }:

{
  home.file.".config/zed/settings.json".text = builtins.toJSON {
    vim_mode = true;
    theme = "Catppuccin Mocha";
    buffer_font_family = "JetBrainsMono Nerd Font";

    auto_install_extensions = {
      catppuccin = true;
      nix = true;
    };

    tab_size = 2;
    relative_line_numbers = true;
    soft_wrap = "none";
    cursor_blink = false;
    cursor_shape = "block";
    scroll_beyond_last_line = "off";
    vertical_scroll_margin = 8;

    format_on_save = "on";
    ensure_final_newline_on_save = true;
    remove_trailing_whitespace_on_save = true;

    inlay_hints = {
      enabled = true;
    };

    git = {
      inline_blame = {
        enabled = true;
      };
    };

    minimap = {
      show = "never";
    };

    vim = {
      use_system_clipboard = "always";
    };

    telemetry = {
      metrics = false;
      diagnostics = false;
    };
  };
}
