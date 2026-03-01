vim.opt.fillchars:append({ diff = " " })

return {
  {
    "gbprod/nord.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      transparent = true,
      on_highlights = function(highlights, colors)
        highlights.DiffAdd = { bg = "#2e4033" }
        highlights.DiffChange = { bg = "#3b3a2e" }
        highlights.DiffDelete = { bg = "#4c2c2c" }
        highlights.DiffText = { bg = "#3b4e6e" }

        local context_bg = "#4C566A"
        highlights.TreesitterContext = { bg = context_bg }
        highlights.TreesitterContextLineNumber = { bg = context_bg }
        highlights.TreesitterContextBottom = { underline = true, sp = context_bg }
        highlights.TreesitterContextLineNumberBottom = { underline = true, sp = context_bg }
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
