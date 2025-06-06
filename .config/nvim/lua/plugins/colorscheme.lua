return {
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "storm",
      transparent = true,
      styles = {
        sidebars = "dark",
        floats = "dark",
      },
      on_highlights = function(highlights, colors)
        -- Make Avante separators more visible
        highlights.AvanteSeparator = { fg = colors.fg_gutter }
        highlights.AvanteVerticalSeparator = { fg = colors.fg_gutter }
        highlights.AvanteHorizontalSeparator = { fg = colors.fg_gutter }
        highlights.AvanteWinSeparator = { fg = colors.fg_gutter }
        highlights.AvanteSidebarWinSeparator = { fg = colors.fg_gutter }
      end,
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
