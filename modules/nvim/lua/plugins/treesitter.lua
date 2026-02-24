-- nvim-treesitter v1.x with Neovim 0.11+
-- Parsers provided by Nix (withAllGrammars), highlighting is automatic.
require('nvim-treesitter').setup({})

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    local ok = pcall(vim.treesitter.start, args.buf)
    if ok then
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end
  end,
})
