local lsp = require('lsp-zero').preset({
  suggest_lsp_servers = true,
  setup_servers_on_start = true,
  set_lsp_keymaps = true,
  configure_diagnostics = true,
  cmp_capabilities = true,
  manage_nvim_cmp = true,
  call_servers = 'local',
  sign_icons = {
    error = '✘',
    warn = '▲',
    hint = '⚑',
    info = ''
  }
})


-- Make sure these are installed
lsp.ensure_installed({
  'eslint',
  'ansiblels',
  'bashls',
  'diagnosticls',
  'grammarly',
  'html',
  'jsonls',
  'lua_ls',
  'marksman',
  'prosemd_lsp',
  'remark_ls',
  'zk',
  'pyright',
  'pylsp',
  'esbonio',
  'taplo',
  'lemminx',
  'yamlls'

})

-- lsp.on_attach(function(client, bufnr)
--   local opts = {buffer = bufnr, remap = false}
--
--   vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
--   vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
--   vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
--   vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
--   vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
--   vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
--   vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
--   vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
--   vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
--   vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
-- end)


lsp.setup()

vim.diagnostic.config({
    virtual_text = true
})



-- Reference:
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#intergrate-with-null-ls


local null_ls = require('null-ls')
local null_opts = lsp.build_options('null-ls', {})

null_ls.setup({
  on_attach = function(client, bufnr)
    null_opts.on_attach(client, bufnr)

    local format_cmd = function(input)
      vim.lsp.buf.format({
        id = client.id,
        timeout_ms = 5000,
        async = input.bang,
      })
    end

    local bufcmd = vim.api.nvim_buf_create_user_command
    bufcmd(bufnr, 'NullFormat', format_cmd, {
      bang = true,
      range = true,
      desc = 'Format using null-ls'
    })
  end,
  sources = {
    -- Replace these with the tools you have installed
    null_ls.builtins.formatting.prettier,
    null_ls.builtins.diagnostics.eslint,
    null_ls.builtins.formatting.stylua,
    null_ls.builtins.diagnostics.write_good,
    null_ls.builtins.diagnostics.cspell,
    null_ls.builtins.code_actions.cspell,
    null_ls.builtins.diagnostics.alex,
    null_ls.builtins.diagnostics.ansiblelint,
    null_ls.builtins.diagnostics.flake8,
    null_ls.builtins.diagnostics.markdownlint,
    null_ls.builtins.diagnostics.proselint,
    null_ls.builtins.code_actions.proselint,
    null_ls.builtins.diagnostics.pydocstyle,
    null_ls.builtins.diagnostics.pylint,
    null_ls.builtins.diagnostics.pyproject_flake8,
    null_ls.builtins.diagnostics.shellcheck,
    null_ls.builtins.diagnostics.textlint,
    null_ls.builtins.diagnostics.vale,
    null_ls.builtins.diagnostics.yamllint,
    null_ls.builtins.diagnostics.zsh,
    null_ls.builtins.formatting.autopep8,
    null_ls.builtins.formatting.beautysh,
    null_ls.builtins.formatting.black,
    null_ls.builtins.formatting.cbfmt,
    null_ls.builtins.formatting.codespell,
    null_ls.builtins.formatting.djhtml,
    null_ls.builtins.formatting.isort,
    null_ls.builtins.formatting.markdown_toc,   -- To generate a TOC, add <!-- toc --> before headers in your markdown file.
    null_ls.builtins.formatting.nginx_beautifier,
    null_ls.builtins.formatting.pyflyby,


  }
})


-- References:
-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v1.x/advance-usage.md#automatic-setup
-- See mason-null-ls.nvim's documentation for more details:
-- https://github.com/jay-babu/mason-null-ls.nvim#setup
require('mason-null-ls').setup({
  ensure_installed = nil,
  automatic_installation = false, -- You can still set this to `true`
  automatic_setup = true,
})

-- Required when `automatic_setup` is true
require('mason-null-ls').setup_handlers()



