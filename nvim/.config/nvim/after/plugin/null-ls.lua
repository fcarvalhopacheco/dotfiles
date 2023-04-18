-- import null-ls plugin safely
local setup, null_ls = pcall(require, "null-ls")
if not setup then
	return
end

-- for conciseness
local formatting = null_ls.builtins.formatting -- to setup formatters
local diagnostics = null_ls.builtins.diagnostics -- to setup linters
local code_actions = null_ls.builtins.code_actions -- to setup linters

-- to setup format on save
local ingroup = vim.api.nvim_create_augroup("LspFormatting", {})

-- configure null_ls
null_ls.setup({
	-- setup formatters & linters
	sources = {
		formatting.prettier.with({
			filetypes = {
				"javascript",
				"typescript",
				"typescriptreact",
				"javascriptreact",
				"json",
				"yaml",
				"markdown",
				"html",
				"css",
				"scss",
				"less",
				"graphql",
				"vue",
				"svelte",
				"lua",
				"gohtmltmpl",
				"jinja.html",
				"jinja",
			},
		}),
		formatting.stylua,
		--diagnostics.eslint,
		diagnostics.write_good,
		diagnostics.alex,
		--diagnostics.ansiblelint,
		diagnostics.flake8,
		diagnostics.proselint,
		code_actions.proselint,
		diagnostics.pydocstyle,
		diagnostics.pylint,
		diagnostics.pyproject_flake8,
		diagnostics.shellcheck,
		diagnostics.yamllint,
		diagnostics.zsh,
		formatting.autopep8,
		formatting.beautysh,
		formatting.black.with({ extra_args = { "--fast" } }),
		formatting.cbfmt,
		formatting.codespell,
		-- formatting.djhtml,
		formatting.isort,
		--formatting.nginx_beautifier,
		--formatting.pyflyby,
	},
	-- configure format on save
	on_attach = function(current_client, bufnr)
		if current_client.supports_method("textDocument/formatting") then
			vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = augroup,
				buffer = bufnr,
				callback = function()
					vim.lsp.buf.format({
						filter = function(client)
							--  only use null-ls for formatting instead of lsp server
							return client.name == "null-ls"
						end,
						bufnr = bufnr,
					})
				end,
			})
		end
	end,
})
