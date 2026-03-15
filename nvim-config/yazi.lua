-- yazi.nvim: use yazi as file explorer in terminal neovim
-- replaces snacks explorer with yazi for richer preview (markdown/image/video)
if vim.g.vscode then
  return {}
end

return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader>e", "<cmd>Yazi<cr>", desc = "Yazi (current file dir)" },
      { "<leader>E", "<cmd>Yazi cwd<cr>", desc = "Yazi (project root)" },
    },
    opts = {
      open_for_directories = true,
      floating_window_scaling_factor = 0.85,
      yazi_floating_window_border = "rounded",
    },
  },
}
