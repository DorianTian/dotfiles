-- codecompanion.nvim: AI chat + inline edit in terminal neovim
-- Adapters: copilot (default, zero-config) / anthropic (if ANTHROPIC_API_KEY set)
if vim.g.vscode then
  return {}
end

return {
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    event = "VeryLazy",
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "AI chat toggle" },
      { "<leader>ai", "<cmd>CodeCompanionChat Add<cr>", mode = "v", desc = "AI add selection to chat" },
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "AI actions palette" },
      { "<leader>ae", "<cmd>CodeCompanion<cr>", mode = "v", desc = "AI inline edit" },
    },
    opts = {
      strategies = {
        chat = {
          adapter = vim.env.ANTHROPIC_API_KEY and "anthropic" or "copilot",
        },
        inline = {
          adapter = vim.env.ANTHROPIC_API_KEY and "anthropic" or "copilot",
        },
      },
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            schema = {
              model = { default = "claude-sonnet-4-20250514" },
            },
          })
        end,
      },
      display = {
        chat = {
          window = {
            layout = "vertical",
            width = 0.4,
          },
        },
      },
    },
  },
}
