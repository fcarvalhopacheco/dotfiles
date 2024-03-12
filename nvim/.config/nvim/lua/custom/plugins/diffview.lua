return {
  {
    'sindrets/diffview.nvim',
    requires = { 'nvim-tree/nvim-web-devicons' },
    cmd = {
      'DiffviewOpen',
      'DiffviewClose',
      'DiffviewToggleFiles',
      'DiffviewFocusFiles',
      'DiffviewRefresh',
      'DiffviewFileHistory',
    },
    keys = {
      { '<leader>gh', '<cmd>DiffviewFileHistory %<cr>', desc = 'File [H]istory' },
      { '<leader>gd', '<cmd>DiffviewOpen<cr>', desc = '[D]iff View' },
      { '<leader>gc', '<cmd>:tabclose<cr>', desc = '[C]lose Diff View' },
    },
    config = function()
      require('diffview').setup {
        keymaps = {
          view = {
            { 'n', 'q', ':DiffviewClose<CR>' },
          },
          file_panel = {
            { 'n', 'q', ':DiffviewClose<CR>' },
          },
          file_history_panel = {
            { 'n', 'q', ':DiffviewClose<CR>' },
          },
        },
      }
    end,
  },
}
