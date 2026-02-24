local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
  "                                                     ",
  "  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
  "  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
  "  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
  "  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
  "  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
  "  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
  "                                                     ",
}

dashboard.section.buttons.val = {
  dashboard.button("f", "  Find file",    "<cmd>Telescope find_files<cr>"),
  dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
  dashboard.button("g", "  Live grep",    "<cmd>Telescope live_grep<cr>"),
  dashboard.button("e", "  New file",     "<cmd>enew<cr>"),
  dashboard.button("q", "  Quit",         "<cmd>qa<cr>"),
}

alpha.setup(dashboard.config)

-- Don't show dashboard when opening a file directly
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
      require("alpha").start()
    end
  end,
})
