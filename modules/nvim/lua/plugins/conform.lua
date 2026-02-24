require('conform').setup({
  formatters_by_ft = {
    lua = { 'stylua' },
    javascript = { 'prettier' },
    typescript = { 'prettier' },
    javascriptreact = { 'prettier' },
    typescriptreact = { 'prettier' },
    json = { 'prettier' },
    css = { 'prettier' },
    html = { 'prettier' },
    nix = { 'alejandra' },
  },
  format_on_save = {
    timeout_ms = 500,
    lsp_fallback = true,
  },
})

vim.keymap.set({ 'n', 'v' }, '<leader>fm', function()
  require('conform').format({ async = true, lsp_fallback = true })
end, { desc = 'Format file or range' })
