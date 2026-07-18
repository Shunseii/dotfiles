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
    -- The <C-h/j/k/l> maps are loaded from lua/config/keymaps.lua (on VeryLazy,
    -- after LazyVim's default <C-w> window maps) so they aren't clobbered.
  },
}
