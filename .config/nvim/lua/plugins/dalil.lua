-- Use the local checkout when there is one (it's where dalil.nvim is developed), else install from GitHub.
local checkout = vim.fn.expand("~/Projects/dalil.nvim")
local source = vim.uv.fs_stat(checkout) and { dir = checkout } or { "Shunseii/dalil.nvim" }

return {
  vim.tbl_extend("force", source, {
    name = "dalil.nvim",
    -- Loaded at startup rather than on first use, so restoring a session can bring back its chat.
    event = "VeryLazy",
    cmd = { "Dalil", "DalilOpen", "DalilNew", "DalilAsk", "DalilAdd", "DalilAddFile", "DalilMode", "DalilModel", "DalilCancel", "DalilSave", "DalilHistory", "DalilRename", "DalilDelete", "DalilHint", "DalilHintDelete", "DalilHintClear", "DalilHintToggle" },
    opts = {},
    keys = {
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ac", "<cmd>Dalil<cr>", desc = "Toggle Claude" },
      { "<leader>af", "<cmd>DalilOpen<cr>", desc = "Focus Claude" },
      { "<leader>an", "<cmd>DalilNew<cr>", desc = "New Claude session" },
      { "<leader>aS", "<cmd>DalilSave<cr>", desc = "Save Claude conversation" },
      { "<leader>ah", "<cmd>DalilHistory<cr>", desc = "Saved conversations (this project)" },
      { "<leader>aH", "<cmd>DalilHistory!<cr>", desc = "Saved conversations (all)" },
      { "<leader>ab", "<cmd>DalilAddFile<cr>", desc = "Add current buffer" },
      { "<leader>as", ":DalilAdd<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>am", "<cmd>DalilMode<cr>", desc = "Claude permission mode" },
      { "<leader>aM", "<cmd>DalilModel<cr>", desc = "Claude model" },
      { "<leader>ax", "<cmd>DalilCancel<cr>", desc = "Cancel Claude" },
      { "<leader>ae", ":DalilHint<cr>", mode = { "n", "v" }, desc = "Hint for line/selection" },
      { "<leader>aE", ":DalilHint!<cr>", mode = { "n", "v" }, desc = "Deeper hint (Opus)" },
      { "<leader>ad", ":DalilHintDelete<cr>", mode = { "n", "v" }, desc = "Delete hint" },
      { "<leader>aD", "<cmd>DalilHintClear<cr>", desc = "Delete all hints in buffer" },
      { "<leader>at", "<cmd>DalilHintToggle<cr>", desc = "Toggle hints" },
    },
  }),
}
