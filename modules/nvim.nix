{ pkgs, ... }:

{
  nixCats = {
    enable = true;
    packageNames = [ "nvim" ];
    luaPath = "${./nvim}";

    categoryDefinitions.replace = { pkgs, ... }: {
      startupPlugins = {
        general = with pkgs.vimPlugins; [
          plenary-nvim
          nvim-web-devicons
          which-key-nvim
          nvim-autopairs
        ];
        colorscheme = with pkgs.vimPlugins; [
          catppuccin-nvim
        ];
        ui = with pkgs.vimPlugins; [
          lualine-nvim
          nvim-tree-lua
        ];
        telescope = with pkgs.vimPlugins; [
          telescope-nvim
          telescope-fzf-native-nvim
        ];
        treesitter = with pkgs.vimPlugins; [
          nvim-treesitter.withAllGrammars
        ];
        completion = with pkgs.vimPlugins; [
          nvim-cmp
          cmp-nvim-lsp
          cmp-buffer
          cmp-path
          luasnip
          cmp_luasnip
        ];
        formatting = with pkgs.vimPlugins; [
          conform-nvim
        ];
      };

      lspsAndRuntimeDeps = {
        general = with pkgs; [
          ripgrep
          fd
        ];
        lsp = with pkgs; [
          lua-language-server
          typescript-language-server
          nil
        ];
        formatting = with pkgs; [
          stylua
          prettier
          alejandra
        ];
      };
    };

    packageDefinitions.replace = {
      nvim = { pkgs, ... }: {
        settings = {
          wrapRc = true;
          aliases = [ "vi" "vim" ];
        };
        categories = {
          general = true;
          colorscheme = true;
          ui = true;
          telescope = true;
          treesitter = true;
          lsp = true;
          completion = true;
          formatting = true;
        };
      };
    };
  };
}
