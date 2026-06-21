-- =========================
-- BASIC SETTINGS
-- =========================
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 200
vim.opt.clipboard = "unnamedplus"
vim.opt.mouse = "a"
vim.opt.path:append("**")
vim.cmd("colorscheme carbonfox")

-- terminal escape
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

-- =========================
-- TREESITTER
-- =========================
require("nvim-treesitter.configs").setup({
  ensure_installed = {},  -- parsers are provided by Nix already
  highlight = { enable = true },
})

-- =========================
-- LUALINE
-- =========================
require("lualine").setup()

-- =========================
-- TELESCOPE
-- =========================
local telescope = require("telescope")
telescope.setup({})
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files)
vim.keymap.set("n", "<leader>fg", require("telescope.builtin").live_grep)
vim.keymap.set("n", "<leader>fb", require("telescope.builtin").buffers)

-- =========================
-- LSP CONFIG
-- =========================
local lspconfig = require("lspconfig")
lspconfig.clangd.setup({})
lspconfig.pyright.setup({})
lspconfig.bashls.setup({})
lspconfig.yamlls.setup({})
lspconfig.lua_ls.setup({
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
})

vim.keymap.set("n", "gd", vim.lsp.buf.definition)
vim.keymap.set("n", "gr", vim.lsp.buf.references)
vim.keymap.set("n", "K", vim.lsp.buf.hover)
vim.keymap.set("n", "rn", vim.lsp.buf.rename)
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)

-- =========================
-- AUTOCOMPLETE (CMP)
-- =========================
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.confirm({ select = true }),
    ["<C-Space>"] = cmp.mapping.complete(),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "path" },
  },
})

-- =========================
-- DTS SUPPORT (Embedded)
-- =========================
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.dts", "*.dtsi" },
  callback = function()
    vim.bo.filetype = "dts"
  end,
})
