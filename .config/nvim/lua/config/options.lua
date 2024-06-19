-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- Copy to clipboard directly
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete to void register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])
vim.keymap.set({ "n", "v" }, "<leader>c", [["_c]])

-- Move a selection around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Paste text without overwriting register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Keep cursor in the same place when scrolling through page
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

local opt = vim.opt

opt.wrap = true

-- vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = true, sp = "Grey" })
-- vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = true, sp = "Grey" })

-- Change treesitter context color to gray and add underline
-- vim.cmd([[
--   augroup TreesitterContextBottom
--     autocmd!
--     autocmd ColorScheme * hi TreesitterContextBottom gui=underline guisp=Grey guifg=Grey
--     autocmd ColorScheme * hi TreesitterContextLineNumberBottom gui=underline guisp=Grey
--   augroup END
-- ]])
