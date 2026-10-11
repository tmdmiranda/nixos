local cmp = require'cmp'

cmp.setup({
  completion = {
    autocomplete = false,
  },

  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),      -- Press Ctrl+Space to show completion
    ['<CR>'] = cmp.mapping.confirm({ select = false }), -- Enter to confirm selection
    ['<C-e>'] = cmp.mapping.abort(),
  }),

  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'buffer' },
    { name = 'async_path' },
  },
})
