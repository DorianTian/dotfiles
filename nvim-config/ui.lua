return {
  {
    "Mofiqul/dracula.nvim",
    priority = 1000,
    opts = {
      transparent_bg = true,
      italic_comment = true,
      colors = {
        -- Match yazi Dracula theme exactly
        bg = "NONE",
        menu = "#21222C",
      },
      overrides = function(colors)
        return {
          -- Transparent backgrounds to match yazi/terminal
          Normal = { bg = "NONE" },
          NormalFloat = { bg = "#21222C" },
          SignColumn = { bg = "NONE" },
          LineNr = { bg = "NONE" },
          CursorLineNr = { bg = "NONE", fg = colors.cyan, bold = true },
          -- Snacks explorer sidebar
          SnacksPickerDir = { fg = colors.cyan },
          SnacksPickerFile = { fg = colors.fg },
        }
      end,
    },
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "dracula",
    },
  },
}
