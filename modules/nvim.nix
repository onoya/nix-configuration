{ ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  xdg.configFile."nvim/init.lua" = { source = ./nvim/init.lua; force = true; };
  xdg.configFile."nvim/lua" = { source = ./nvim/lua; force = true; };
}
