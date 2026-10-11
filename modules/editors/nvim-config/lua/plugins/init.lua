return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      require('nvim-tree').setup{
        update_focused_file = {
          enable = true,
          update_root = true,
        },
        sync_root_with_cwd = true,
      }
    end,
    dependencies = {"nvim-tree/nvim-web-devicons",
    },
  },

  {
      "hrsh7th/nvim-cmp",
      opts = function(_, opts)
        opts.completion = {
          autocomplete = false, -- kills the auto popup
        }

        local cmp = require("cmp")
        opts.mapping = vim.tbl_deep_extend("force", opts.mapping or {}, {
          ["<C-Space>"] = cmp.mapping.complete(), -- manual trigger
        })

        return opts
      end,
    },
  }
  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },

