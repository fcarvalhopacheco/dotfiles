return {
  "ThePrimeagen/harpoon",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = true,
  keys = {
    { "<leader>ha", "<cmd>lua require('harpoon.mark').add_file()<cr>",        desc = "[H]arpoon [A]dd file with" },
    { "<leader>hm", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", desc = "[H]arpoon [M]enu" },
    { "<C-n>",      "<cmd>lua require('harpoon.ui').nav_next()<cr>",          desc = "Go to [N]ext harpoon mark" },
    { "<C-p>",      "<cmd>lua require('harpoon.ui').nav_prev()<cr>",          desc = "Go to [P]revious harpoon mark" },
    -- { "<c-z>",      "<cmd>lua require('harpoon.ui').nav_file(1)<cr>",         desc = "go to file 1" },
    -- { "<C-x>",      "<cmd>lua require('harpoon.ui').nav_file(2)<cr>",         desc = "Go to file 2" },
  },
}
