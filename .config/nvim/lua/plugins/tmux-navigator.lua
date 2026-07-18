return {
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
    -- Disable the plugin's own <c-hjkl> maps; vim-herdr-navigation owns them.
    -- It falls back to tmux ($TMUX) or plain wincmd when not in a herdr pane,
    -- so an occasional tmux session still navigates correctly.
    init = function()
      vim.g.tmux_navigator_no_mappings = 1
    end,
    config = function()
      dofile(vim.fn.expand("~/.config/herdr/plugins/vim-herdr-navigation/editor/nvim.lua"))
    end,
  },
}
