return {
  -- Treesitter 语法高亮（前端相关语言）
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "bash",
        "css",
        "dockerfile",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "html",
        "javascript",
        "json",
        "jsonc",
        "lua",
        "markdown",
        "markdown_inline",
        "python",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "vue",
        "yaml",
      })

      -- 大文件保护：超过阈值自动关闭 treesitter highlight + indent
      -- 避免几千/上万行文件吃掉大量内存
      local max_filesize = 150 * 1024 -- 150KB
      local max_line_count = 5000

      local function should_disable(_, buf)
        -- 文件大小检查
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
        -- 行数检查（有些文件单行不长但行数多）
        if vim.api.nvim_buf_line_count(buf) > max_line_count then
          return true
        end
        return false
      end

      opts.highlight = opts.highlight or {}
      opts.highlight.disable = should_disable

      opts.indent = opts.indent or {}
      opts.indent.disable = should_disable
    end,
  },

  -- 自动闭合/重命名 HTML 标签
  {
    "windwp/nvim-ts-autotag",
    event = "InsertEnter",
    opts = {},
  },
}
