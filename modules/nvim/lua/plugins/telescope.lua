local telescope = require('telescope')
local builtin = require('telescope.builtin')

telescope.setup({
  extensions = {
    fzf = {},
  },
})

telescope.load_extension('fzf')

local map = vim.keymap.set

map("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
map("n", "<leader>fg", builtin.live_grep, { desc = "Live grep" })
map("n", "<leader>fb", builtin.buffers, { desc = "Find buffers" })
map("n", "<leader>fh", builtin.help_tags, { desc = "Help tags" })
map("n", "<leader>fo", builtin.oldfiles, { desc = "Recent files" })
map("n", "<leader><leader>", builtin.find_files, { desc = "Find files" })
