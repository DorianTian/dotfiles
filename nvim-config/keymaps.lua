-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ══════════════════════════════════════════════════════════
-- 通用映射（Neovim / VSCode / Cursor 三端一致）
-- ══════════════════════════════════════════════════════════

-- jk 退出插入模式
map("i", "jk", "<esc>", { desc = "Exit insert mode" })

-- ; 进入命令模式
map("n", ";", ":", { desc = "Command mode" })

if vim.g.vscode then
  -- ════════════════════════════════════════════════════════
  -- VSCode / Cursor 环境
  -- 使用 vim.fn.VSCodeNotify（始终可用，不依赖 require("vscode")）
  -- ════════════════════════════════════════════════════════
  local function call(action)
    vim.fn.VSCodeNotify(action)
  end

  -- ── 行移动 ──
  map("n", "<A-j>", function() call("editor.action.moveLinesDownAction") end, { desc = "Move line down" })
  map("n", "<A-k>", function() call("editor.action.moveLinesUpAction") end, { desc = "Move line up" })
  map("v", "<A-j>", function() call("editor.action.moveLinesDownAction") end, { desc = "Move line down" })
  map("v", "<A-k>", function() call("editor.action.moveLinesUpAction") end, { desc = "Move line up" })

  -- ── 保存 ──
  map({ "n", "i", "v" }, "<C-s>", function() call("workbench.action.files.save") end, { desc = "Save file" })

  -- ── LSP 跳转 ──
  map("n", "gd", function() call("editor.action.revealDefinition") end, { desc = "Go to definition" })
  map("n", "gD", function() call("editor.action.peekDefinition") end, { desc = "Peek definition" })
  map("n", "gr", function() call("editor.action.goToReferences") end, { desc = "Go to references" })
  map("n", "gi", function() call("editor.action.goToImplementation") end, { desc = "Go to implementation" })
  map("n", "gy", function() call("editor.action.goToTypeDefinition") end, { desc = "Go to type definition" })
  map("n", "K", function() call("editor.action.showHover") end, { desc = "Hover info" })
  map("n", "<leader>rn", function() call("editor.action.rename") end, { desc = "Rename symbol" })
  map("n", "<leader>ca", function() call("editor.action.quickFix") end, { desc = "Code action" })
  map("v", "<leader>ca", function() call("editor.action.quickFix") end, { desc = "Code action" })
  map("n", "<leader>fm", function() call("editor.action.formatDocument") end, { desc = "Format document" })
  map("n", "]d", function() call("editor.action.marker.next") end, { desc = "Next diagnostic" })
  map("n", "[d", function() call("editor.action.marker.prev") end, { desc = "Prev diagnostic" })

  -- ── 文件（对标 Telescope <leader>f）──
  map("n", "<leader>ff", function() call("workbench.action.quickOpen") end, { desc = "Find files" })
  map("n", "<leader>fb", function() call("workbench.action.showAllEditors") end, { desc = "Buffers" })
  map("n", "<leader>fr", function() call("workbench.action.openRecent") end, { desc = "Recent" })
  map("n", "<leader>fc", function() call("workbench.action.openSettings") end, { desc = "Find config" })

  -- ── 搜索（对标 Telescope <leader>s）──
  map("n", "<leader>sg", function() call("workbench.action.findInFiles") end, { desc = "Grep" })
  map("n", "<leader>sw", function() call("editor.action.addSelectionToNextFindMatch") end, { desc = "Search word under cursor" })
  map("n", "<leader>sb", function() call("workbench.action.quickTextSearch") end, { desc = "Buffer lines" })
  map("n", "<leader>sd", function() call("workbench.actions.view.problems") end, { desc = "Diagnostics" })
  map("n", "<leader>ss", function() call("workbench.action.gotoSymbol") end, { desc = "Goto symbol (document)" })
  map("n", "<leader>sS", function() call("workbench.action.showAllSymbols") end, { desc = "Goto symbol (workspace)" })
  map("n", "<leader>sk", function() call("workbench.action.openGlobalKeybindings") end, { desc = "Keymaps" })
  map("n", "<leader>sh", function() call("workbench.action.showCommands") end, { desc = "Help / Commands" })
  map("n", "<leader>sm", function() call("workbench.action.showAllEditorsByMostRecentlyUsed") end, { desc = "Marks / Recent editors" })
  map("n", "<leader>sr", function() call("editor.action.startFindReplaceAction") end, { desc = "Search and replace" })
  map("n", "<leader>sR", function() call("workbench.action.replaceInFiles") end, { desc = "Search and replace (workspace)" })
  map("n", "<leader>sc", function() call("workbench.action.showCommands") end, { desc = "Command history" })
  map("n", "<leader>st", function() call("workbench.action.showAllSymbols") end, { desc = "Todo" })
  map("n", "<leader>/", function() call("workbench.action.findInFiles") end, { desc = "Search in project" })

  -- ── 文件树 / 侧边栏（对标 Neo-tree）──
  map("n", "<leader>e", function() call("workbench.action.toggleSidebarVisibility") end, { desc = "Toggle sidebar" })
  map("n", "<leader>E", function() call("workbench.files.action.showActiveFileInExplorer") end, { desc = "Reveal file in explorer" })

  -- ── 窗口导航（对标 tmux-navigator）──
  map("n", "<C-h>", function() call("workbench.action.navigateLeft") end, { desc = "Navigate left" })
  map("n", "<C-j>", function() call("workbench.action.navigateDown") end, { desc = "Navigate down" })
  map("n", "<C-k>", function() call("workbench.action.navigateUp") end, { desc = "Navigate up" })
  map("n", "<C-l>", function() call("workbench.action.navigateRight") end, { desc = "Navigate right" })

  -- ── Buffer 切换 ──
  map("n", "H", function() call("workbench.action.previousEditor") end, { desc = "Prev buffer" })
  map("n", "L", function() call("workbench.action.nextEditor") end, { desc = "Next buffer" })
  map("n", "<leader>bd", function() call("workbench.action.closeActiveEditor") end, { desc = "Close buffer" })

  -- ── Harpoon 等价（编辑器索引跳转）──
  map("n", "<leader>1", function() call("workbench.action.openEditorAtIndex1") end, { desc = "Editor 1" })
  map("n", "<leader>2", function() call("workbench.action.openEditorAtIndex2") end, { desc = "Editor 2" })
  map("n", "<leader>3", function() call("workbench.action.openEditorAtIndex3") end, { desc = "Editor 3" })
  map("n", "<leader>4", function() call("workbench.action.openEditorAtIndex4") end, { desc = "Editor 4" })

  -- ── 终端（对标 ToggleTerm）──
  map("n", "<C-\\>", function() call("workbench.action.terminal.toggleTerminal") end, { desc = "Toggle terminal" })

  -- ── Git（对标 gitsigns / diffview / neogit）──
  map("n", "<leader>gB", function() call("gitlens.toggleFileBlame") end, { desc = "Toggle file blame" })
  map("n", "<leader>gd", function() call("workbench.view.scm") end, { desc = "Source control" })
  map("n", "<leader>gp", function() call("editor.action.dirtydiff.next") end, { desc = "Next change" })
  map("n", "<leader>gh", function() call("timeline.focus") end, { desc = "File history" })
  map("n", "<leader>gn", function() call("workbench.view.scm") end, { desc = "Git status" })
  map("n", "]c", function() call("workbench.action.editor.nextChange") end, { desc = "Next git change" })
  map("n", "[c", function() call("workbench.action.editor.previousChange") end, { desc = "Prev git change" })

  -- ── Debug（对标 nvim-dap）──
  map("n", "<leader>db", function() call("editor.debug.action.toggleBreakpoint") end, { desc = "Toggle breakpoint" })
  map("n", "<leader>dB", function() call("editor.debug.action.conditionalBreakpoint") end, { desc = "Conditional breakpoint" })
  map("n", "<leader>dc", function() call("workbench.action.debug.continue") end, { desc = "Continue" })
  map("n", "<leader>do", function() call("workbench.action.debug.stepOver") end, { desc = "Step over" })
  map("n", "<leader>di", function() call("workbench.action.debug.stepInto") end, { desc = "Step into" })
  map("n", "<leader>dO", function() call("workbench.action.debug.stepOut") end, { desc = "Step out" })
  map("n", "<leader>dt", function() call("workbench.action.debug.stop") end, { desc = "Terminate" })
  map("n", "<leader>dr", function() call("workbench.action.debug.restart") end, { desc = "Restart" })
  map("n", "<leader>du", function() call("workbench.debug.action.toggleRepl") end, { desc = "Toggle REPL" })

  -- ── Test（对标 neotest）──
  map("n", "<leader>tt", function() call("testing.runAtCursor") end, { desc = "Run nearest test" })
  map("n", "<leader>tf", function() call("testing.runCurrentFile") end, { desc = "Run file tests" })
  map("n", "<leader>ts", function() call("testing.viewAsTree") end, { desc = "Test summary" })
  map("n", "<leader>td", function() call("testing.debugAtCursor") end, { desc = "Debug nearest test" })

  -- ── Database（对标 vim-dadbod）──
  map("n", "<leader>Dt", function() call("database-client.showDatabasePanel") end, { desc = "Toggle DB panel" })

  -- ── Go 专用（对标 gopher.nvim）──
  map("n", "<leader>cgt", function() call("go.add.tags") end, { desc = "Add Go tags" })
  map("n", "<leader>cgr", function() call("go.remove.tags") end, { desc = "Remove Go tags" })
  map("n", "<leader>cge", function() call("editor.action.quickFix") end, { desc = "Generate if err" })

else
  -- ════════════════════════════════════════════════════════
  -- 原生 Neovim 环境
  -- ════════════════════════════════════════════════════════

  -- 保存
  map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

  -- Alt+j/k 移动行
  map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
  map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
  map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
  map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
  map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
  map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })
end
