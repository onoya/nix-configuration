require('which-key').setup({})

require('which-key').add({
  { "<leader>f", group = "Find" },
  { "<leader>r", group = "Rename/Refactor" },
  { "<leader>c", group = "Code" },
})
