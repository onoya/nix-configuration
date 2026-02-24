-- Neovim 0.11+ native LSP API (vim.lsp.config replaces nvim-lspconfig)

local capabilities = vim.tbl_deep_extend(
  'force',
  vim.lsp.protocol.make_client_capabilities(),
  require('cmp_nvim_lsp').default_capabilities()
)

local on_attach = function(_, bufnr)
  local map = function(keys, func, desc)
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
  end

  map('gd', vim.lsp.buf.definition, 'Go to definition')
  map('gD', vim.lsp.buf.declaration, 'Go to declaration')
  map('gr', vim.lsp.buf.references, 'Go to references')
  map('gi', vim.lsp.buf.implementation, 'Go to implementation')
  map('K', vim.lsp.buf.hover, 'Hover documentation')
  map('<leader>rn', vim.lsp.buf.rename, 'Rename')
  map('<leader>ca', vim.lsp.buf.code_action, 'Code action')
  map('<leader>e', vim.diagnostic.open_float, 'Show diagnostics')
  map('[d', vim.diagnostic.goto_prev, 'Previous diagnostic')
  map(']d', vim.diagnostic.goto_next, 'Next diagnostic')
end

vim.lsp.config('*', {
  capabilities = capabilities,
  on_attach = on_attach,
})

vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.git' },
})

vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx' },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
})

vim.lsp.config('nil_ls', {
  cmd = { 'nil' },
  filetypes = { 'nix' },
  root_markers = { 'flake.nix', '.git' },
})

vim.lsp.enable({ 'lua_ls', 'ts_ls', 'nil_ls' })
