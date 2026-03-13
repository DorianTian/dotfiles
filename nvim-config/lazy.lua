local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-- Leader 必须在 lazy.setup 之前设置（LazyVim 会自动设，但 VSCode 分支跳过了 LazyVim）
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

if vim.g.vscode then
  -- ══════════════════════════════════════════════════════════
  -- VSCode / Cursor 模式：只加载文本操作类插件
  -- ══════════════════════════════════════════════════════════

  -- 没有 LazyVim，需要手动加载 options 和 keymaps
  require("config.options")

  require("lazy").setup({
    spec = {
      -- surround: ys / ds / cs 三端一致
      {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
      },
    },
    defaults = { lazy = false },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip", "tarPlugin", "tohtml", "tutor", "zipPlugin",
          "netrwPlugin", "matchit",
        },
      },
    },
  })

  -- lazy.setup 之后加载 keymaps（确保 vscode 模块可用）
  require("config.keymaps")
else
  -- ══════════════════════════════════════════════════════════
  -- 原生 Neovim 模式：完整 LazyVim
  -- ══════════════════════════════════════════════════════════
  require("lazy").setup({
    spec = {
      -- add LazyVim and import its plugins
      { "LazyVim/LazyVim", import = "lazyvim.plugins" },
      -- import LazyVim extras（按需增删）
      { import = "lazyvim.plugins.extras.lang.typescript" },
      { import = "lazyvim.plugins.extras.lang.json" },
      { import = "lazyvim.plugins.extras.lang.go" },
      { import = "lazyvim.plugins.extras.lang.tailwind" },
      { import = "lazyvim.plugins.extras.lang.vue" },
      { import = "lazyvim.plugins.extras.lang.python" },
      { import = "lazyvim.plugins.extras.formatting.prettier" },
      { import = "lazyvim.plugins.extras.linting.eslint" },
      { import = "lazyvim.plugins.extras.ai.copilot" },
      -- import/override with your plugins
      { import = "plugins" },
    },
    defaults = {
      lazy = false,
      version = false,
    },
    install = { colorscheme = { "tokyonight", "habamax" } },
    checker = {
      enabled = true,
      notify = false,
    },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        },
      },
    },
  })
end
