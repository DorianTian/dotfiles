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
        opts = {},
      },

      -- flash.nvim: s 搜索跳转 + f/F/t/T 增强（原生支持 vscode-neovim）
      {
        "folke/flash.nvim",
        opts = {
          modes = {
            char = { enabled = true },  -- f/F/t/T 增强
            search = { enabled = false }, -- vscode 自带搜索，不覆盖
          },
        },
        keys = {
          { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
          { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
          { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
          { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        },
      },

      -- treesitter + textobjects（新版 API：不再用 nvim-treesitter.configs）
      {
        "nvim-treesitter/nvim-treesitter",
        dependencies = { "nvim-treesitter/nvim-treesitter-textobjects" },
        build = ":TSUpdate",
        config = function()
          require("nvim-treesitter").setup({
            ensure_installed = {
              "bash", "css", "go", "gomod", "html", "javascript", "json",
              "jsonc", "lua", "markdown", "python", "sql", "tsx",
              "typescript", "vue", "yaml",
            },
          })

          require("nvim-treesitter-textobjects").setup({
            select = { lookahead = true },
            move = { set_jumps = true },
          })

          local select = require("nvim-treesitter-textobjects.select")
          local move = require("nvim-treesitter-textobjects.move")
          local swap = require("nvim-treesitter-textobjects.swap")
          local map = vim.keymap.set

          -- select: af/if, ac/ic, aa/ia
          map({ "x", "o" }, "af", function() select.select_textobject("@function.outer") end, { desc = "a function" })
          map({ "x", "o" }, "if", function() select.select_textobject("@function.inner") end, { desc = "inner function" })
          map({ "x", "o" }, "ac", function() select.select_textobject("@class.outer") end, { desc = "a class" })
          map({ "x", "o" }, "ic", function() select.select_textobject("@class.inner") end, { desc = "inner class" })
          map({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer") end, { desc = "a argument" })
          map({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner") end, { desc = "inner argument" })

          -- move: [f/]f, [a/]a
          map({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer") end, { desc = "Next function" })
          map({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer") end, { desc = "Prev function" })
          map({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer") end, { desc = "Next function end" })
          map({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer") end, { desc = "Prev function end" })
          map({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.outer") end, { desc = "Next argument" })
          map({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.outer") end, { desc = "Prev argument" })

          -- swap: <leader>a / <leader>A
          map("n", "<leader>a", function() swap.swap_next("@parameter.inner") end, { desc = "Swap next arg" })
          map("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end, { desc = "Swap prev arg" })
        end,
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
      -- import LazyVim extras
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
