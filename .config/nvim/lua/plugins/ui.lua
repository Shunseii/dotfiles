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
      -- Src: https://github.com/yioneko/vtsls/issues/159#issuecomment-2159349677
      -- REMOVE THIS once this issue is fixed: https://github.com/yioneko/vtsls/issues/159
      routes = {
        {
          filter = {
            event = "notify",
            find = "Request textDocument/inlayHint failed",
          },
          opts = { skip = true },
        },
      },
      presets = {
        lsp_doc_border = true,
      },
    },
  },

  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    opts = function(_, opts)
      local logo = [[
     _             ____        _                      
    / \   ___     / ___|  __ _| | __ _ _ __ ___  _   _ 
   / _ \ / __|____\___ \ / _` | |/ _` | '_ ` _ \| | | |
  / ___ \\__ \_____|__) | (_| | | (_| | | | | | | |_| |
 /_/   \_\___/    |____/ \__,_|_|\__,_|_| |_| |_|\__,_|
 ( )  / \  | | __ _(_) | ___   _ _ __ ___              
 |/  / _ \ | |/ _` | | |/ / | | | '_ ` _ \             
    / ___ \| | (_| | |   <| |_| | | | | | |            
   /_/   \_\_|\__,_|_|_|\_\\__,_|_| |_| |_|            
      ]]

      logo = string.rep("\n", 8) .. logo .. "\n\n"
      opts.config.header = vim.split(logo, "\n")
    end,
  },
}
