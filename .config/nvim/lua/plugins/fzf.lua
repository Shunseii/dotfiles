return {
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      -- The backdrop dims the editor behind the picker; with a transparent colorscheme it turns black instead.
      opts.winopts = opts.winopts or {}
      opts.winopts.backdrop = false
    end,
  },
}
