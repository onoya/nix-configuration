require('catppuccin').setup({
  flavour = "mocha",
  transparent_background = true,
  integrations = {
    cmp = true,
    nvimtree = true,
    telescope = { enabled = true },
    treesitter = true,
    which_key = true,
    lualine = true,
  },
})

vim.cmd.colorscheme('catppuccin')
