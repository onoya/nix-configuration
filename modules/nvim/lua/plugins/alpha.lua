local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
  "   _   __         _    ___          ",
  "  / | / /__  ____ | |  / (_)___ ___ ",
  " /  |/ / _ \\/ __ \\| | / / / __ `__ \\",
  "/ /|  /  __/ /_/ /| |/ / / / / / / /",
  "/_/ |_/\\___/\\____/ |___/_/_/ /_/ /_/ ",
  "                                     ",
}

dashboard.section.buttons.val = {
  dashboard.button("f", "  Find file",    "<cmd>Telescope find_files<cr>"),
  dashboard.button("r", "  Recent files", "<cmd>Telescope oldfiles<cr>"),
  dashboard.button("g", "  Live grep",    "<cmd>Telescope live_grep<cr>"),
  dashboard.button("e", "  New file",     "<cmd>enew<cr>"),
  dashboard.button("q", "  Quit",         "<cmd>qa<cr>"),
}

dashboard.section.footer.val = "  nix-managed · nixCats"

alpha.setup(dashboard.config)
