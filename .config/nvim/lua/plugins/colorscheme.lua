-- return {
--   {
--     "folke/tokyonight.nvim",
--     lazy = true,
--     opts = {
--       style = "storm",
--       transparent = true,
--       styles = {
--         sidebars = "dark",
--         floats = "dark",
--       },
--       on_highlights = function(highlights, colors)
--         -- Make Avante separators more visible
--         highlights.AvanteSeparator = { fg = colors.fg_gutter }
--         highlights.AvanteVerticalSeparator = { fg = colors.fg_gutter }
--         highlights.AvanteHorizontalSeparator = { fg = colors.fg_gutter }
--         highlights.AvanteWinSeparator = { fg = colors.fg_gutter }
--         highlights.AvanteSidebarWinSeparator = { fg = colors.fg_gutter }
--       end,
--     },
--   },
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "tokyonight",
--     },
--   },
-- }

-- return {
--   {
--     dir = vim.fn.stdpath("config") .. "/lua/themes/nord-custom",
--     name = "nord-custom",
--     lazy = false,
--     priority = 1000,
--   },
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "nord-custom",
--     },
--   },
-- }

return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      on_highlights = function(highlights, colors)
        -- Make Avante separators consistent with nvim-tree separators
        local separator_color = "#3b4252" -- Same as nvim-tree separators
        highlights.AvanteBorder = { fg = separator_color }
        highlights.AvanteSeparator = { fg = separator_color }
        highlights.AvanteVerticalSeparator = { fg = separator_color }
        highlights.AvanteHorizontalSeparator = { fg = separator_color }
        highlights.AvanteWinSeparator = { fg = separator_color }
        highlights.AvanteSidebarWinSeparator = { fg = separator_color }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nord",
    },
  },
}
