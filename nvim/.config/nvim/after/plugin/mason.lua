-- import mason plugin safely
local mason_status, mason = pcall(require, "mason")
if not mason_status then
	return
end

-- import mason-lspconfig plugin safely
local mason_lspconfig_status, mason_lspconfig = pcall(require, "mason-lspconfig")
if not mason_lspconfig_status then
	return
end

-- import mason-null-ls plugin safely
local mason_null_ls_status, mason_null_ls = pcall(require, "mason-null-ls")
if not mason_null_ls_status then
	return
end

-- enable mason
mason.setup()

mason_lspconfig.setup({
	-- list of servers for mason to install
	ensure_installed = {
		-- "tsserver",
		"eslint",
		"ansiblels",
		"bashls",
		"diagnosticls",
		"grammarly",
		"html",
		"jsonls",
		"lua_ls",
		"prosemd_lsp",
		"pyright",
		"pylsp",
		"esbonio",
		"taplo",
		"lemminx",
		"yamlls",
		"cssls",
		-- "tailwindcss",
		"lua_ls",
	},
	-- auto-install configured servers (with lspconfig)
	automatic_installation = true, -- not the same as ensure_installed
})

mason_null_ls.setup({
	-- list of formatters & linters for mason to install
	ensure_installed = {
		"marksman",
		"prettier", -- ts/js formatter
		"stylua", -- lua formatter
		"eslint",
		"stylua",
		"write_good",
		-- "cspell",
		"alex",
		"ansiblelint",
		"flake8",
		"proselint",
		"code_actions.proselint",
		"pydocstyle",
		"pylint",
		"pyproject_flake8",
		"shellcheck",
		"yamllint",
		"zsh",
		"autopep8",
		"beautysh",
		"black",
		"cbfmt",
		"codespell",
		"djhtml",
		"isort",
		"nginx_beautifier",
		"pyflyby",
	},
	-- auto-install configured formatters & linters (with null-ls)
	automatic_installation = true,
	automatic_setup = true,
})
