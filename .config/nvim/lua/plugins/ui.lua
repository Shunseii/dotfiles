return {
  "akinsho/bufferline.nvim",
  opts = {
    highlights = {
      fill = {
        bg = "#2E3440",
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
