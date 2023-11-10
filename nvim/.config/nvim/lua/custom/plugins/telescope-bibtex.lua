return {
  "nvim-telescope/telescope-bibtex.nvim",
  dependencies = {
    { 'nvim-telescope/telescope.nvim' },
  },
  lazy = true,
  keys = { { "<leader>fz", ":Telescope bibtex<CR>", desc = "Fuzzy [f]ind bibtex ([z]otero) references",
  } },
  init = function()
    require "telescope".load_extension("bibtex")
  end,
  opts = {
    extensions = {
      bibtex = {
        -- Depth for the *.bib file
        depth = 1,
        -- Custom format for citation label
        custom_formats = {},
        -- Format to use for citation label.
        -- Try to match the filetype by default, or use 'plain'
        format = '',
        -- Path to global bibliographies (placed outside of the project)
        global_files = { "~/Documents/zotero/WHOTS.bib" },
        -- Define the search keys to use in the picker
        search_keys = { 'author', 'year', 'title' },
        -- Template for the formatted citation
        -- citation_format = '{{author}} ({{year}}), {{title}}.',
        citation_format = "[[@{{label}}]]: {{author}} ({{date}}), {{title}}.",
        -- Only use initials for the authors first name
        citation_trim_firstname = true,
        -- Max number of authors to write in the formatted citation
        -- following authors will be replaced by "et al."
        --citation_max_auth = 2,
        -- Context awareness disabled by default
        context = false,
        -- Fallback to global/directory .bib files if context not found
        -- This setting has no effect if context = false
        context_fallback = true,
        -- Wrapping in the preview window is disabled by default
        wrap = false,
      },
    },
  },
}
