return {
  recommended = true,

  -- supermaven
  {
    "supermaven-inc/supermaven-nvim",
    build = ":SupermavenUseFree",
    config = function()
      require("supermaven-nvim").setup({})
    end,
  },

  -- supermaven cmp source
  {
    "nvim-cmp",
    ---@param opts cmp.ConfigSchema
    opts = function(_, opts)
      table.insert(opts.sources, 1, {
        name = "supermaven",
        group_index = 1,
        priority = 100,
      })
    end,
  },
}
