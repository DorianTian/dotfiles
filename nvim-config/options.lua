-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

local opt = vim.opt

-- 让 LSP 子进程（Node.js 等）正确使用本地代理，解决 jsonls schema 下载失败问题
-- Node.js 的 http 模块只认大写的 HTTPS_PROXY / HTTP_PROXY
local proxy = vim.env.https_proxy or vim.env.http_proxy
if proxy then
  vim.env.HTTP_PROXY = vim.env.HTTP_PROXY or proxy
  vim.env.HTTPS_PROXY = vim.env.HTTPS_PROXY or proxy
end

opt.scrolloff = 8 -- 光标距离顶部/底部保留 8 行
opt.relativenumber = true -- 相对行号
opt.wrap = false -- 不自动换行
opt.tabstop = 2 -- Tab 宽度 2
opt.shiftwidth = 2 -- 缩进宽度 2
opt.expandtab = true -- Tab 转空格
opt.cursorline = true -- 高亮当前行
opt.termguicolors = true -- 真彩色
opt.signcolumn = "yes" -- 始终显示符号列
opt.clipboard = "unnamedplus" -- 系统剪贴板共享
opt.undofile = true

if vim.g.vscode then opt.undofile = false end
