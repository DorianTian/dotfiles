-- Keymaps: 三端统一（Neovim / VSCode / Cursor）
-- 对标 LazyVim 全键位: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

local map = vim.keymap.set

-- ══════════════════════════════════════════════════════════
-- 通用映射（三端一致）
-- ══════════════════════════════════════════════════════════
map("i", "jk", "<esc>", { desc = "Exit insert mode" })
map("n", ";", ":", { desc = "Command mode" })

if vim.g.vscode then
  -- ════════════════════════════════════════════════════════
  -- VSCode / Cursor 环境
  -- ════════════════════════════════════════════════════════

  -- API: vim.fn.VSCodeNotify 始终可用（无参数调用）
  -- require("vscode").action 支持传参（用 pcall 保护）
  local notify = vim.fn.VSCodeNotify

  local has_vscode_mod, vscode_mod = pcall(require, "vscode")
  local function action_with_args(cmd, opts)
    if has_vscode_mod then
      vscode_mod.action(cmd, opts)
    else
      notify(cmd)
    end
  end

  -- ── H/L 行首行尾（与原生 Neovim 分支一致）──
  map({ "n", "v", "o" }, "H", "^", { desc = "Go to first non-blank character" })
  map({ "n", "v", "o" }, "L", "$", { desc = "Go to end of line" })

  -- ── 行移动（<A-j/k>）──
  map("n", "<A-j>", function() notify("editor.action.moveLinesDownAction") end, { desc = "Move line down" })
  map("n", "<A-k>", function() notify("editor.action.moveLinesUpAction") end, { desc = "Move line up" })
  map("v", "<A-j>", function() notify("editor.action.moveLinesDownAction") end, { desc = "Move line down" })
  map("v", "<A-k>", function() notify("editor.action.moveLinesUpAction") end, { desc = "Move line up" })

  -- ── 保存 ──
  map({ "n", "i", "v" }, "<C-s>", function() notify("workbench.action.files.save") end, { desc = "Save file" })

  -- ── 清除搜索高亮 ──
  map("n", "<esc>", "<cmd>noh<cr><esc>", { desc = "Clear hlsearch" })

  -- ── 折叠 ──
  map("n", "za", function() notify("editor.toggleFold") end, { desc = "Toggle fold" })
  map("n", "zo", function() notify("editor.unfold") end, { desc = "Open fold" })
  map("n", "zc", function() notify("editor.fold") end, { desc = "Close fold" })
  map("n", "zO", function() notify("editor.unfoldRecursively") end, { desc = "Open fold recursively" })
  map("n", "zC", function() notify("editor.foldRecursively") end, { desc = "Close fold recursively" })
  map("n", "zR", function() notify("editor.unfoldAll") end, { desc = "Open all folds" })
  map("n", "zM", function() notify("editor.foldAll") end, { desc = "Close all folds" })

  -- ══════════════════════════════════════════════════════════
  -- LSP
  -- ══════════════════════════════════════════════════════════
  -- 删除 Neovim 0.11+ 默认的 gr* 映射，避免 gr 延迟
  pcall(vim.keymap.del, "n", "grn")
  pcall(vim.keymap.del, "n", "grr")
  pcall(vim.keymap.del, "n", "gra")
  pcall(vim.keymap.del, "n", "gri")

  map("n", "gd", function() notify("editor.action.revealDefinition") end, { desc = "Go to definition" })
  map("n", "gD", function() notify("editor.action.peekDefinition") end, { desc = "Peek definition" })
  map("n", "gr", function() notify("editor.action.goToReferences") end, { desc = "Go to references" })
  map("n", "gi", function() notify("editor.action.goToImplementation") end, { desc = "Go to implementation" })
  map("n", "gy", function() notify("editor.action.goToTypeDefinition") end, { desc = "Go to type definition" })
  map("n", "gK", function() notify("editor.action.triggerParameterHints") end, { desc = "Signature help" })
  map("n", "K", function() notify("editor.action.showHover") end, { desc = "Hover info" })
  map("n", "]d", function() notify("editor.action.marker.next") end, { desc = "Next diagnostic" })
  map("n", "[d", function() notify("editor.action.marker.prev") end, { desc = "Prev diagnostic" })
  map("n", "]e", function() notify("editor.action.marker.next") end, { desc = "Next error" })
  map("n", "[e", function() notify("editor.action.marker.prev") end, { desc = "Prev error" })
  map("n", "]w", function() notify("editor.action.marker.next") end, { desc = "Next warning" })
  map("n", "[w", function() notify("editor.action.marker.prev") end, { desc = "Prev warning" })

  -- ── 符号/函数导航 ──
  -- [f/]f, af/if, aa/ia 等由 treesitter-textobjects + mini.ai 提供（lazy.lua vscode 分支已加载）
  -- <leader>ss → workbench.action.gotoSymbol（当前文件所有 symbol 列表）

  -- ══════════════════════════════════════════════════════════
  -- Code（<leader>c 组）
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>rn", function() notify("editor.action.rename") end, { desc = "Rename symbol" })
  map("n", "<leader>ca", function() notify("editor.action.quickFix") end, { desc = "Code action" })
  map("v", "<leader>ca", function() notify("editor.action.quickFix") end, { desc = "Code action" })
  map("n", "<leader>cf", function() notify("editor.action.formatDocument") end, { desc = "Format document" })
  map("v", "<leader>cf", function() notify("editor.action.formatSelection") end, { desc = "Format selection" })
  map("n", "<leader>co", function() notify("editor.action.organizeImports") end, { desc = "Organize imports" })
  map("n", "<leader>cM", function() notify("editor.action.sourceAction") end, { desc = "Source action" })
  map("n", "<leader>cr", function() notify("editor.action.rename") end, { desc = "Rename" })
  map("n", "<leader>cR", function() notify("editor.action.refactor") end, { desc = "Refactor" })

  -- ══════════════════════════════════════════════════════════
  -- 搜索（<leader>s 组）
  -- ══════════════════════════════════════════════════════════
  -- 当前文件搜索光标下单词（vim 原生，n/N 直接可用）
  map("n", "<leader>sw", "*N", { desc = "Search word under cursor" })
  map("v", "<leader>sw", function()
    vim.cmd('noau normal! "vy')
    vim.fn.setreg("/", "\\V" .. vim.fn.escape(vim.fn.getreg("v"), "/\\"))
    vim.cmd("set hlsearch")
  end, { desc = "Search selection" })
  -- 项目级搜索（带参数）
  map("n", "<leader>sW", function()
    local word = vim.fn.expand("<cword>")
    action_with_args("workbench.action.findInFiles", { args = { query = word } })
  end, { desc = "Search word in project" })
  map("n", "<leader>sg", function()
    action_with_args("workbench.action.findInFiles", { args = { query = "" } })
  end, { desc = "Grep (project)" })
  map("v", "<leader>sg", function()
    vim.cmd('noau normal! "vy')
    local text = vim.fn.getreg("v")
    action_with_args("workbench.action.findInFiles", { args = { query = text } })
  end, { desc = "Grep selection (project)" })
  map("n", "<leader>/", function()
    action_with_args("workbench.action.findInFiles", { args = { query = "" } })
  end, { desc = "Search in project" })
  map("n", "<leader>sb", function() notify("workbench.action.quickTextSearch") end, { desc = "Buffer search" })
  map("n", "<leader>sd", function() notify("workbench.actions.view.problems") end, { desc = "Diagnostics" })
  map("n", "<leader>ss", function() notify("workbench.action.gotoSymbol") end, { desc = "Goto symbol (document)" })
  map("n", "<leader>sS", function() notify("workbench.action.showAllSymbols") end, { desc = "Goto symbol (workspace)" })
  map("n", "<leader>sk", function() notify("workbench.action.openGlobalKeybindings") end, { desc = "Keymaps" })
  map("n", "<leader>sh", function() notify("workbench.action.showCommands") end, { desc = "Help / Commands" })
  map("n", "<leader>sm", function() notify("workbench.action.showAllEditorsByMostRecentlyUsed") end, { desc = "Recent editors" })
  map("n", "<leader>sr", function() notify("editor.action.startFindReplaceAction") end, { desc = "Search and replace" })
  map("n", "<leader>sR", function() notify("workbench.action.replaceInFiles") end, { desc = "Replace in files" })
  map("n", "<leader>sc", function() notify("workbench.action.showCommands") end, { desc = "Commands" })

  -- ══════════════════════════════════════════════════════════
  -- 文件（<leader>f 组）
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>ff", function() notify("workbench.action.quickOpen") end, { desc = "Find files" })
  map("n", "<leader>fb", function() notify("workbench.action.showAllEditors") end, { desc = "Buffers" })
  map("n", "<leader>fr", function() notify("workbench.action.openRecent") end, { desc = "Recent" })
  map("n", "<leader>fc", function() notify("workbench.action.openSettings") end, { desc = "Settings" })
  map("n", "<leader>fn", function() notify("workbench.action.files.newUntitledFile") end, { desc = "New file" })
  map("n", "<leader>fp", function() notify("copyRelativeFilePath") end, { desc = "Copy relative path" })
  map("n", "<leader>fP", function() notify("copyFilePath") end, { desc = "Copy absolute path" })
  map("n", "<leader>ft", function() notify("workbench.action.terminal.new") end, { desc = "New terminal" })

  -- ══════════════════════════════════════════════════════════
  -- 文件树 / 侧边栏
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>e", function() notify("workbench.action.toggleSidebarVisibility") end, { desc = "Toggle sidebar" })
  map("n", "<leader>E", function() notify("workbench.files.action.showActiveFileInExplorer") end, { desc = "Reveal file in explorer" })

  -- ══════════════════════════════════════════════════════════
  -- Buffer（<leader>b 组 + H/L/[b/]b）
  -- ══════════════════════════════════════════════════════════
  -- H/L 已映射为行首/行尾（原生 Neovim 区），buffer 切换用 [b/]b
  map("n", "[b", function() notify("workbench.action.previousEditor") end, { desc = "Prev buffer" })
  map("n", "]b", function() notify("workbench.action.nextEditor") end, { desc = "Next buffer" })
  map("n", "<leader>bd", function() notify("workbench.action.closeActiveEditor") end, { desc = "Close buffer" })
  map("n", "<leader>bo", function() notify("workbench.action.closeOtherEditors") end, { desc = "Close other buffers" })
  map("n", "<leader>bD", function() notify("workbench.action.closeAllEditors") end, { desc = "Close all buffers" })
  map("n", "<leader>bp", function() notify("workbench.action.pinEditor") end, { desc = "Pin buffer" })
  map("n", "<leader>bP", function() notify("workbench.action.unpinEditor") end, { desc = "Unpin buffer" })
  map("n", "<leader>1", function() notify("workbench.action.openEditorAtIndex1") end, { desc = "Editor 1" })
  map("n", "<leader>2", function() notify("workbench.action.openEditorAtIndex2") end, { desc = "Editor 2" })
  map("n", "<leader>3", function() notify("workbench.action.openEditorAtIndex3") end, { desc = "Editor 3" })
  map("n", "<leader>4", function() notify("workbench.action.openEditorAtIndex4") end, { desc = "Editor 4" })

  -- ══════════════════════════════════════════════════════════
  -- Window（<leader>w 组）
  -- 注意：<C-h/j/k/l> 由 keybindings.json 直接处理，不经过 neovim
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>wd", function() notify("workbench.action.closeEditorsInGroup") end, { desc = "Close window" })
  map("n", "<leader>w-", function() notify("workbench.action.splitEditorDown") end, { desc = "Split below" })
  map("n", "<leader>w|", function() notify("workbench.action.splitEditorRight") end, { desc = "Split right" })
  map("n", "<leader>ws", function() notify("workbench.action.splitEditorDown") end, { desc = "Split below" })
  map("n", "<leader>wv", function() notify("workbench.action.splitEditorRight") end, { desc = "Split right" })
  map("n", "<leader>wo", function() notify("workbench.action.closeEditorsInOtherGroups") end, { desc = "Close other windows" })
  map("n", "<leader>ww", function() notify("workbench.action.focusNextGroup") end, { desc = "Next window" })
  map("n", "<leader>w=", function() notify("workbench.action.evenEditorWidths") end, { desc = "Equal window widths" })

  -- ══════════════════════════════════════════════════════════
  -- Tab（<leader><tab> 组）
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader><tab><tab>", function() notify("workbench.action.quickOpenPreviousRecentlyUsedEditor") end, { desc = "Switch to other tab" })
  map("n", "<leader><tab>d", function() notify("workbench.action.closeActiveEditor") end, { desc = "Close tab" })
  map("n", "<leader><tab>o", function() notify("workbench.action.closeOtherEditors") end, { desc = "Close other tabs" })
  map("n", "<leader><tab>l", function() notify("workbench.action.lastEditorInGroup") end, { desc = "Last tab" })
  map("n", "<leader><tab>f", function() notify("workbench.action.firstEditorInGroup") end, { desc = "First tab" })

  -- ══════════════════════════════════════════════════════════
  -- Quickfix / Trouble（<leader>x 组 + [q/]q）
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>xx", function() notify("workbench.actions.view.problems") end, { desc = "Toggle diagnostics" })
  map("n", "<leader>xq", function() notify("workbench.actions.view.problems") end, { desc = "Quickfix list" })
  map("n", "[q", function() notify("editor.action.marker.prev") end, { desc = "Prev quickfix" })
  map("n", "]q", function() notify("editor.action.marker.next") end, { desc = "Next quickfix" })

  -- ══════════════════════════════════════════════════════════
  -- UI Toggles（<leader>u 组）
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>uw", function() notify("editor.action.toggleWordWrap") end, { desc = "Toggle word wrap" })
  map("n", "<leader>ul", function() notify("editor.action.toggleRenderWhitespace") end, { desc = "Toggle whitespace" })
  map("n", "<leader>um", function() notify("editor.action.toggleMinimap") end, { desc = "Toggle minimap" })
  map("n", "<leader>us", function() notify("editor.action.toggleStickyScroll") end, { desc = "Toggle sticky scroll" })
  map("n", "<leader>ub", function() notify("breadcrumbs.toggle") end, { desc = "Toggle breadcrumbs" })
  map("n", "<leader>uz", function() notify("workbench.action.toggleZenMode") end, { desc = "Toggle zen mode" })
  map("n", "<leader>uZ", function() notify("workbench.action.toggleFullScreen") end, { desc = "Toggle fullscreen" })

  -- ══════════════════════════════════════════════════════════
  -- Git
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>gg", function() notify("workbench.view.scm") end, { desc = "Git status" })
  map("n", "<leader>gB", function() notify("gitlens.toggleFileBlame") end, { desc = "Toggle file blame" })
  map("n", "<leader>gd", function() notify("git.openChange") end, { desc = "Diff current file" })
  map("n", "<leader>gh", function() notify("timeline.focus") end, { desc = "File history" })
  map("n", "<leader>gl", function() notify("gitlens.showGraph") end, { desc = "Git log / graph" })
  map("n", "]c", function() notify("workbench.action.editor.nextChange") end, { desc = "Next git change" })
  map("n", "[c", function() notify("workbench.action.editor.previousChange") end, { desc = "Prev git change" })
  map("n", "]h", function() notify("workbench.action.editor.nextChange") end, { desc = "Next hunk" })
  map("n", "[h", function() notify("workbench.action.editor.previousChange") end, { desc = "Prev hunk" })
  map("n", "<leader>ghs", function() notify("git.stageSelectedRanges") end, { desc = "Stage hunk" })
  map("n", "<leader>ghu", function() notify("git.unstageSelectedRanges") end, { desc = "Unstage hunk" })
  map("n", "<leader>ghr", function() notify("git.revertSelectedRanges") end, { desc = "Revert hunk" })

  -- ══════════════════════════════════════════════════════════
  -- Debug
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>db", function() notify("editor.debug.action.toggleBreakpoint") end, { desc = "Toggle breakpoint" })
  map("n", "<leader>dB", function() notify("editor.debug.action.conditionalBreakpoint") end, { desc = "Conditional breakpoint" })
  map("n", "<leader>dc", function() notify("workbench.action.debug.continue") end, { desc = "Continue" })
  map("n", "<leader>do", function() notify("workbench.action.debug.stepOver") end, { desc = "Step over" })
  map("n", "<leader>di", function() notify("workbench.action.debug.stepInto") end, { desc = "Step into" })
  map("n", "<leader>dO", function() notify("workbench.action.debug.stepOut") end, { desc = "Step out" })
  map("n", "<leader>dt", function() notify("workbench.action.debug.stop") end, { desc = "Terminate" })
  map("n", "<leader>dr", function() notify("workbench.action.debug.restart") end, { desc = "Restart" })
  map("n", "<leader>du", function() notify("workbench.debug.action.toggleRepl") end, { desc = "Toggle REPL" })
  map("n", "<leader>dw", function() notify("workbench.debug.action.focusWatchView") end, { desc = "Watch" })
  map("n", "<leader>ds", function() notify("workbench.debug.action.focusCallStackView") end, { desc = "Call stack" })

  -- ══════════════════════════════════════════════════════════
  -- Test
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>tt", function() notify("testing.runAtCursor") end, { desc = "Run nearest test" })
  map("n", "<leader>tf", function() notify("testing.runCurrentFile") end, { desc = "Run file tests" })
  map("n", "<leader>ts", function() notify("testing.viewAsTree") end, { desc = "Test summary" })
  map("n", "<leader>td", function() notify("testing.debugAtCursor") end, { desc = "Debug nearest test" })
  map("n", "<leader>tl", function() notify("testing.reRunLastRun") end, { desc = "Re-run last test" })
  map("n", "<leader>to", function() notify("testing.showMostRecentOutput") end, { desc = "Test output" })

  -- ══════════════════════════════════════════════════════════
  -- Database / Go / 杂项
  -- ══════════════════════════════════════════════════════════
  map("n", "<leader>Dt", function() notify("database-client.showDatabasePanel") end, { desc = "Toggle DB panel" })
  map("n", "<leader>cgt", function() notify("go.add.tags") end, { desc = "Add Go tags" })
  map("n", "<leader>cgr", function() notify("go.remove.tags") end, { desc = "Remove Go tags" })
  map("n", "<leader>cge", function() notify("editor.action.quickFix") end, { desc = "Generate if err" })
  map("n", "<leader>l", function() notify("workbench.action.showCommands") end, { desc = "Command palette" })
  map("n", "<leader>L", function() notify("workbench.action.openGlobalKeybindings") end, { desc = "Keybindings" })
  map("n", "<leader>qq", function() notify("workbench.action.closeWindow") end, { desc = "Quit" })

else
  -- ════════════════════════════════════════════════════════
  -- 原生 Neovim 环境
  -- ════════════════════════════════════════════════════════
  -- 覆盖 LazyVim 默认的 H/L buffer 切换，映射为行首/行尾
  map({ "n", "v", "o" }, "H", "^", { desc = "Go to first non-blank character" })
  map({ "n", "v", "o" }, "L", "$", { desc = "Go to end of line" })

  map({ "n", "i", "v" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

  map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
  map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
  map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
  map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
  map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move line down" })
  map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move line up" })

  vim.keymap.del("n", "<leader>bd")
  map("n", "<leader>x", function() Snacks.bufdelete() end, { desc = "Close buffer" })

  map("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics" })
  map("n", "<leader>td", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Buffer diagnostics" })

  map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save" })
  map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

  map("n", "<ESC>", "<cmd>noh<cr>", { desc = "Clear search highlight" })
end
