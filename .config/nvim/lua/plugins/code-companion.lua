return {
  -- Temporarily disabled for avante.nvim testing
  --[[
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      strategies = {
        chat = {
          adapter = "copilot", -- Default to Copilot
          auto_submit = true, -- Auto-submit tool use
        },
        inline = {
          adapter = "copilot", -- Default to Copilot
        },
        agent = {
          adapter = "copilot", -- Default to Copilot
          auto_submit = true, -- Enable autonomous agent workflows
        },
      },
      adapters = {
        -- Keep Anthropic/Claude available for switching
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = vim.trim(vim.fn.system('op read "op://Private/Anthropic/api-key" --no-newline')),
            },
          })
        end,
        -- Copilot as default
        copilot = function()
          return require("codecompanion.adapters").extend("copilot", {})
        end,
      },
      display = {
        diff = {
          enabled = true,
          close_chat_at = 240, -- Keep chat open during diffs
          provider = "mini_diff", -- Force consistent diff provider
        },
        chat = {
          show_settings = true,
        },
        action_palette = {
          provider = "default",
        },
      },
      prompt_library = {
        ["Code and iterate"] = {
          strategy = "workflow",
          description = "Make code changes, check LSP errors, and iterate until clean",
          opts = {
            index = 5,
            is_default = false,
            short_name = "ci",
          },
          prompts = {
            {
              -- First group: Setup and initial request
              {
                role = "system",
                content = function()
                  vim.g.codecompanion_auto_tool_mode = true
                  return "You are a development agent with access to these tools:\n- @editor: Read and edit files\n- @cmd_runner: Run shell commands\n- @full_stack_dev: Full stack development capabilities\n\nUse these tools to make changes and check for errors. Always show diffs before applying changes and ask for approval."
                end,
                opts = {
                  visible = false,
                },
              },
              {
                role = "user",
                content = "I want you to use @full_stack_dev to make the following changes: ",
                opts = {
                  auto_submit = false,
                },
              },
            },
            -- Second group: Check for errors and iterate
            {
              {
                role = "user",
                content = "Check for LSP errors for Typescript or eslint in #lsp and fix them using @full_stack_dev.",
                opts = {
                  auto_submit = true,
                },
                condition = function()
                  return _G.codecompanion_current_tool == "editor" or _G.codecompanion_current_tool == nil
                end,
                repeat_until = function(chat)
                  -- Keep repeating until no errors are found
                  return chat.tools and chat.tools.flags and chat.tools.flags.no_errors == true
                end,
              },
            },
          },
        },
      },
      opts = {
        log_level = "DEBUG", -- For troubleshooting
        send_code = true, -- Include code context automatically
        system_prompt = "When showing code changes, use proper code blocks with language tags. Never include patch markers like '*** Begin Patch' or '*** End Patch' in your responses as they will be applied literally to files.",
      },
    },
  },
  --]]
}
