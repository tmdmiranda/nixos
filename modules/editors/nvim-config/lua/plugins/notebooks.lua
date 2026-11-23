
return {
  {
    "benlubas/molten-nvim",
    version = "^1.0.0",
    lazy = false,
    build = ":UpdateRemotePlugins",

    init = function()
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_output_win_border = { "", "━", "", "" }
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true

      -- Enable after configuring image.nvim
      vim.g.molten_image_provider = "image.nvim"
    end,

    keys = {
      {
        "<leader>mi",
        "<cmd>MoltenInit<cr>",
        desc = "Initialize Jupyter kernel",
      },
      {
        "<leader>ml",
        "<cmd>MoltenEvaluateLine<cr>",
        desc = "Execute line",
      },
      {
        "<leader>mr",
        "<cmd>MoltenReevaluateCell<cr>",
        desc = "Re-execute cell",
      },
      {
        "<leader>mo",
        "<cmd>MoltenShowOutput<cr>",
        desc = "Show output",
      },
      {
        "<leader>mh",
        "<cmd>MoltenHideOutput<cr>",
        desc = "Hide output",
      },
      {
        "<leader>me",
        ":<C-u>MoltenEvaluateVisual<cr>",
        mode = "v",
        desc = "Execute selection",
      },
    },
  },

  {
    "goerz/jupytext.nvim",
    version = "0.2.0",
    lazy = false,

    opts = {
      format = "py:percent",
      update = true,
    },
  },

{
  "3rd/image.nvim",
  lazy = false,
  build = false,

  opts = {
    backend = "kitty",
    processor = "magick_cli",

    max_width = 100,
    max_height = 15,

    window_overlap_clear_enabled = true,
    window_overlap_clear_ft_ignore = {
      "cmp_menu",
      "cmp_docs",
      "",
    },
  },
},
}

