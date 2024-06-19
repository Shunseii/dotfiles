return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      highlights = {
        -- fill = {
        --   bg = "#2E3440",
        -- },
        -- background = {
        --   bg = "#2E3440",
        -- },
        -- --       tab = {
        -- --         bg = "#2E3440",
        -- --       },
        -- --       tab_close = {
        -- --         bg = "#2E3440",
        -- --       },
        -- -- Tab is selected but unfocused
        -- buffer_visible = {
        --   bg = "#2E3440",
        -- },
        -- --       modified = {
        -- --         bg = "#2E3440",
        -- --       },
        -- -- buffer_selected = {
        -- --   bg = "#2E3440",
        -- -- },
        -- tab_separator = {
        --   bg = "#2E3440",
        --   fg = "#2E3440",
        -- },
        -- --       indicator_visible = {
        -- --         bg = "#2E3440",
        -- --       },
        -- --       indicator_selected = {
        -- --         bg = "#2E3440",
        -- --       },
        -- separator = {
        --   bg = "#2E3440",
        --   fg = "#2E3440",
        -- },
        -- separator_selected = {
        --   bg = "#2E3440",
        --   fg = "#2E3440",
        -- },
        -- separator_visible = {
        --   bg = "#2E3440",
        --   fg = "#2E3440",
        -- },
        --       close_button = {
        --         bg = "#2E3440",
        --       },
        --       close_button_visible = {
        --         bg = "#2E3440",
        --       },
        --       close_button_selected = {
        --         bg = "#2E3440",
        --       },
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    opts = {
      sections = {
        lualine_z = {},
      },
    },
  },

  {
    "folke/noice.nvim",
    opts = {
      lsp = {
        hover = {
          -- Set not show a message if hover is not available
          -- ex: shift+k on Typescript code
          silent = true,
        },
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },
}
