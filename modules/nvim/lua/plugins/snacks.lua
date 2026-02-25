require('snacks').setup({
  lazygit = { enabled = true },
  gitbrowse = { enabled = true },
})

vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Git: Lazygit' })
vim.keymap.set('n', '<leader>gf', function() Snacks.lazygit.log_file() end, { desc = 'Git: File history' })
vim.keymap.set('n', '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git: Browse remote' })
