return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}

      local function biome_or_prettier(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        if vim.fs.find({ "biome.json", "biome.jsonc" }, { upward = true, path = bufname })[1] then
          return { "biome" }
        end
        return { "prettier" }
      end

      opts.formatters_by_ft.html = biome_or_prettier
      opts.formatters_by_ft.jsonc = biome_or_prettier

      -- Use mix format directly for Elixir instead of LSP
      opts.formatters_by_ft.elixir = { "mix" }
      opts.formatters_by_ft.heex = { "mix" }
      opts.formatters_by_ft.eex = { "mix" }

      return opts
    end,
  },
}
