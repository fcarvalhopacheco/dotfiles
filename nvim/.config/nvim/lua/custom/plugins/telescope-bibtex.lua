return {
  {
    'nvim-telescope/telescope.nvim', -- Telescope core plugin
  },
  {
    'nvim-telescope/telescope-bibtex.nvim',
    lazy = true, -- This plugin should be lazily loaded
    dependencies = {
      'nvim-telescope/telescope.nvim', -- Dependency declaration
    },
    keys = {
      { '<leader>zz', ':Telescope bibtex<CR>', desc = '[Z]otero references' },
    },
    init = function()
      -- Loading the bibtex extension as soon as telescope is available
      require('telescope').load_extension 'bibtex'
    end,
    config = function()
      -- Configuration for the bibtex extension.
      -- This block allows you to set up the extension with specific options.
      require('telescope').setup {
        extensions = {
          bibtex = {
            depth = 1, -- Depth for the *.bib file
            custom_formats = {}, -- Custom format for citation label
            format = '', -- Format to use for citation label
            global_files = { '~/Documents/zotero/My_Library.bib' }, -- Path to global bibliographies
            search_keys = { 'author', 'year', 'title' }, -- Define the search keys
            citation_format = '{{author}} ({{year}}), {{title}}.', -- Template for the formatted citation
            citation_trim_firstname = true, -- Only use initials for the authors first name
            citation_max_auth = 2, -- Max number of authors to write in the formatted citation
            context = false, -- Context awareness disabled by default
            context_fallback = true, -- Fallback to global/directory .bib files if context not found
            wrap = false, -- Wrapping in the preview window is disabled by default
          },
        },
      }
      -- Important: After setting up telescope with the above options,
      -- you need to explicitly load the bibtex extension with the configured options.
      require('telescope').load_extension 'bibtex'
    end,
  },
}
