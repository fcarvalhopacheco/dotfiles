return {
  {
    'renerocksai/telekasten.nvim',
    dependencies = {
      'nvim-telescope/telescope.nvim',
      'renerocksai/calendar-vim'
    },

    config = function()
      local home = vim.fn.expand("/Users/fcp/Documents/zettelkasten")
      local work = vim.fn.expand("/Users/fcp/Documents/zettelkasten/work")

      -- Mapping helper function
      local function map(mode, lhs, rhs, opts)
        local options = { noremap = true }
        if opts then
          options = vim.tbl_extend("force", options, opts)
        end
        vim.api.nvim_set_keymap(mode, lhs, rhs, options)
      end

      map("n", "<leader>zp", ":lua require('telekasten').panel()<CR>", { desc = "[Z]ettle [P]anel" })

      -- FIND/FOLLOW
      map("n", "<leader>zfn", ":lua require('telekasten').find_notes()<CR>", { desc = "[F]ind [N]otes" })
      map("n", "<leader>zfd", ":lua require('telekasten').find_daily_notes()<CR>",
        { desc = "[F]ind [D]aily notes" })
      map("n", "<leader>zfw", ":lua require('telekasten').find_weekly_notes()<CR>",
        { desc = "[F]ind [W]eekly notes" })
      map("n", "<leader>zff", ":lua require('telekasten').find_friends()<CR>",
        { desc = "[F]ind [F]riends" })
      map("n", "<leader>zfl", ":lua require('telekasten').follow_link()<CR>", { desc = "[F]ollow [L]ink" })

      -- SEARCH/SHOW
      map("n", "<leader>zsn", ":lua require('telekasten').search_notes()<CR>",
        { desc = "[S]earch [N]otes" })
      map("n", "<leader>zsc", ":lua require('telekasten').show_calendar()<CR>",
        { desc = "[S]how [C]alendar" })
      map("n", "<leader>zC", ":CalendarT<CR>", { desc = "[C]alendar" })
      map("n", "<leader>zsb", ":lua require('telekasten').show_backlinks()<CR>",
        { desc = "[S]how [B]acklinks" })
      map("n", "<leader>zst", ":lua require('telekasten').show_tags()<CR>", { desc = "[S]how [T]ags" })
      map("n", "<leader>z#", ":lua require('telekasten').show_tags()<CR>", { desc = "[#] == tags" })
      map("i", "<leader>z#", "<cmd>:lua require('telekasten').show_tags({i = true})<CR>",
        { desc = "[#] == tags" })

      -- GOTO
      map("n", "<leader>zgt", ":lua require('telekasten').goto_today()<CR>", { desc = "[T]oday" })
      map("n", "<leader>zgw", ":lua require('telekasten').goto_thisweek()<CR>",
        { desc = "[W]eek" })

      -- NEW NOTES
      map("n", "<leader>znn", ":lua require('telekasten').new_note()<CR>", { desc = "[N]ote" })
      map("n", "<leader>znt", ":lua require('telekasten').new_templated_note()<CR>",
        { desc = "[T]emplated note" })

      -- OTHERS
      map("n", "<leader>zy", ":lua require('telekasten').yank_notelink()<CR>",
        { desc = "[Y]ank notelink" })
      map("n", "<leader>zI", ":lua require('telekasten').insert_img_link({ i=true })<CR>",
        { desc = "[I]nsert img link " })
      map("n", "<leader>zp", ":lua require('telekasten').preview_img()<CR>", { desc = "[P]review img" })
      map("n", "<leader>zb", ":lua require('telekasten').browse_media()<CR>", { desc = "[B]rowse media " })
      map("n", "<leader>zr", ":lua require('telekasten').rename_note()<CR>", { desc = "[R]ename note" })

      require('telekasten').setup({

        -- Mapping helper

        home                        = home,
        -- if true, telekasten will be enabled when opening a note within the configured home
        take_over_my_home           = true,

        -- auto-set telekasten filetype: if false, the telekasten filetype will not be used
        --                               and thus the telekasten syntax will not be loaded either
        auto_set_filetype           = false,
        auto_set_syntax             = true,

        -- dir names for special notes (absolute path or subdir name)
        dailies                     = home .. '/' .. 'daily',
        weeklies                    = home .. '/' .. 'weekly',
        templates                   = home .. '/' .. 'templates',

        -- image (sub)dir for pasting
        -- dir name (absolute path or subdir name)
        -- or nil if pasted images shouldn't go into a special subdir
        image_subdir                = "img",

        -- markdown file extension
        extension                   = ".md",

        -- Generate note filenames. One of:
        -- "title" (default) - Use title if supplied, uuid otherwise
        -- "uuid" - Use uuid
        -- "uuid-title" - Prefix title by uuid
        -- "title-uuid" - Suffix title with uuid
        new_note_filename           = "uuid-title",
        -- file uuid type ("rand" or input for os.date such as "%Y%m%d%H%M")
        uuid_type                   = "%Y%m%d%H%M",
        -- UUID separator
        uuid_sep                    = "-",

        -- following a link to a non-existing note will create it
        follow_creates_nonexisting  = true,
        dailies_create_nonexisting  = true,
        weeklies_create_nonexisting = true,

        -- template for new notes (new_note, follow_link)
        -- set to `nil` or do not specify if you do not want a template
        template_new_note           = home .. '/' .. 'templates/new_note.md',

        -- template for newly created daily notes (goto_today)
        -- set to `nil` or do not specify if you do not want a template
        template_new_daily          = home .. '/' .. 'templates/daily.md',

        -- template for newly created weekly notes (goto_thisweek)
        -- set to `nil` or do not specify if you do not want a template
        template_new_weekly         = home .. '/' .. 'templates/weekly.md',

        template_new_work           = home .. '/' .. 'templates/memory_help.md',


        -- image link style
        -- wiki:     ![[image name]]
        -- markdown: ![](image_subdir/xxxxx.png)
        image_link_style       = "markdown",

        -- Calendar integration
        plug_into_calendar     = true, -- use calendar integration
        calendar_opts          = {
          weeknm = 1,                  -- calendar week display mode:
          --   1 .. 'WK01'
          --   2 .. 'WK 1'
          --   3 .. 'KW01'
          --   4 .. 'KW 1'
          --   5 .. '1'

          calendar_monday = 1, -- use monday as first day of week:
          --   1 .. true
          --   0 .. false

          calendar_mark = 'left-fit', -- calendar mark placement
          -- where to put mark for marked days:
          --   'left'
          --   'right'
          --   'left-fit'
        },

        -- telescope actions behavior
        close_after_yanking    = false,
        insert_after_inserting = true,

        -- tag notation: '#tag', ':tag:', 'yaml-bare'
        tag_notation           = "#tag",

        -- command palette theme: dropdown (window) or ivy (bottom panel)
        command_palette_theme  = "ivy",

        -- tag list theme:
        -- get_cursor: small tag list at cursor; ivy and dropdown like above
        show_tags_theme        = "ivy",

        -- when linking to a note in subdir/, create a [[subdir/title]] link
        -- instead of a [[title only]] link
        subdirs_in_links       = true,

        -- template_handling
        -- What to do when creating a new note via `new_note()` or `follow_link()`
        -- to a non-existing note
        -- - prefer_new_note: use `new_note` template
        -- - smart: if day or week is detected in title, use daily / weekly templates (default)
        -- - always_ask: always ask before creating a note
        template_handling      = "always_ask",

        -- path handling:
        --   this applies to:
        --     - new_note()
        --     - new_templated_note()
        --     - follow_link() to non-existing note
        --
        --   it does NOT apply to:
        --     - goto_today()
        --     - goto_thisweek()
        --
        --   Valid options:
        --     - smart: put daily-looking notes in daily, weekly-looking ones in weekly,
        --              all other ones in home, except for notes/with/subdirs/in/title.
        --              (default)
        --
        --     - prefer_home: put all notes in home except for goto_today(), goto_thisweek()
        --                    except for notes with subdirs/in/title.
        --
        --     - same_as_current: put all new notes in the dir of the current note if
        --                        present or else in home
        --                        except for notes/with/subdirs/in/title.
        new_note_location      = 'smart',

        -- should all links be updated when a file is renamed
        rename_update_links    = true,

        -- vaults                 = {
        --   work = {
        --     -- configuration for WORK vault.
        --     home                        = work,
        --     take_over_my_home           = true,
        --     auto_set_filetype           = true,
        --     dailies                     = home .. '/' .. 'daily',
        --     weeklies                    = home .. '/' .. 'weekly',
        --     templates                   = home .. '/' .. 'templates',
        --     image_subdir                = "img",
        --     extension                   = ".md",
        --     new_note_filename           = "uuid-title",
        --     uuid_type                   = "%Y%m%d%H%M",
        --     uuid_sep                    = "-",
        --     follow_creates_nonexisting  = true,
        --     dailies_create_nonexisting  = true,
        --     weeklies_create_nonexisting = true,
        --     template_new_note           = home .. '/' .. 'templates/new_note.md',
        --     template_new_daily          = home .. '/' .. 'templates/daily.md',
        --     template_new_weekly         = home .. '/' .. 'templates/weekly.md',
        --     template_new_work           = home .. '/' .. 'templates/memory_help.md',
        --     image_link_style            = "markdown",
        --     plug_into_calendar          = true,
        --     calendar_opts               = {
        --       weeknm = 1,
        --       calendar_monday = 1,
        --       calendar_mark = 'left-fit',
        --     },
        --     close_after_yanking         = false,
        --     insert_after_inserting      = true,
        --     tag_notation                = "#tag",
        --     command_palette_theme       = "ivy",
        --     show_tags_theme             = "ivy",
        --     subdirs_in_links            = true,
        --     template_handling           = "always_ask",
        --     new_note_location           = "smart",
        --     rename_update_links         = true,
        --   }
        -- },

      })
      vim.cmd([[
      hi tklink ctermfg=72 guifg=#689d6a cterm=bold,underline gui=bold,underline
      hi tkBrackets ctermfg=gray guifg=gray

      " real yellow
      hi tkHighlight ctermbg=yellow ctermfg=darkred cterm=bold guibg=yellow guifg=darkred gui=bold
      " gruvbox
      "hi tkHighlight ctermbg=214 ctermfg=124 cterm=bold guibg=#fabd2f guifg=#9d0006 gui=bold

      hi link CalNavi CalRuler
      hi tkTagSep ctermfg=gray guifg=gray
      hi tkTag ctermfg=175 guifg=#d3869b

      ]])
    end,
  },





}
