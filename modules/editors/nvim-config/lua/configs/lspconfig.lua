require("nvchad.configs.lspconfig").defaults()

local zig_lsp = vim.fn.expand("$HOME/.zvm/bin/zls")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config["zls"] = {
  cmd = { "zls" },
  capabilities = capabilities,
  settings = {
    zls = {
      zig_exe_path = vim.fn.exepath("zig"),
    },
  },
}

vim.lsp.config["asm-lsp"] = {
  cmd = {"asm-lsp"},
  filetypes = {"asm", "s", "S", "nasm"},
  capabilities = capabilities
}

local servers = { "html", "cssls", "rust_analyzer", "stylua", "clangd", "zls", "lua_language_server", "gopls", "nil_ls", "asm-lsp" }

-- Enable all LSP servers
vim.lsp.enable(servers)
