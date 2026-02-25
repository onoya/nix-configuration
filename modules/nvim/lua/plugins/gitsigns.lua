require('gitsigns').setup({
  current_line_blame = true,
  current_line_blame_opts = {
    delay = 500,
    virt_text_pos = 'eol',
  },
  signs = {
    add          = { text = '▎' },
    change       = { text = '▎' },
    delete       = { text = '' },
    topdelete    = { text = '' },
    changedelete = { text = '▎' },
    untracked    = { text = '▎' },
  },
  on_attach = function(bufnr)
    local gs = package.loaded.gitsigns
    local map = function(keys, func, desc)
      vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'Git: ' .. desc })
    end

    map(']h', gs.next_hunk,                  'Next hunk')
    map('[h', gs.prev_hunk,                  'Prev hunk')
    map('<leader>gs', gs.stage_hunk,         'Stage hunk')
    map('<leader>gr', gs.reset_hunk,         'Reset hunk')
    map('<leader>gp', gs.preview_hunk,       'Preview hunk')
    map('<leader>gb', gs.blame_line,         'Blame line')
    map('<leader>gd', gs.diffthis,           'Diff this')
  end,
})
