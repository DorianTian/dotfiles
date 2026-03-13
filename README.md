# Cursor / VSCode + vscode-neovim 完整配置

> Vim editing feel 100% 一致 + `<leader>` 键触发 VSCode 等价操作。三端统一：Terminal Neovim / Cursor / VSCode。

## 架构

```
cursor_vscode_config/
├── cursor-config/
│   ├── settings.json       # 编辑器外观 + 行为 + 格式化 + 扩展配置
│   └── keybindings.json    # Ctrl/Alt 组合键（VSCode 层，不经过 neovim）
├── nvim-config/
│   ├── lazy.lua            # VSCode 模式只加载 surround，终端加载完整 LazyVim
│   ├── keymaps.lua         # 80+ 统一快捷键（vim.g.vscode 双分支）
│   └── options.lua         # 三端共享选项
├── formatter/              # 统一代码格式化配置
│   ├── .prettierrc.js      # Prettier 主配置（React/Vue overrides）
│   ├── .prettierignore     # Prettier 忽略规则
│   ├── eslint.config.js    # 标准 ESLint 基线（无 ESLint 的项目使用）
│   ├── ruff.toml           # Python ruff 格式化 + lint
│   ├── sql-formatter.json  # SQL 格式化
│   ├── .editorconfig       # 通用编辑器基线
│   ├── vscode/settings.json# VS Code / Cursor 推荐配置
│   ├── setup.sh            # 一键安装脚本
│   ├── index.js            # npm 包入口（shareable config）
│   └── package.json        # npm 包定义
├── .prettierrc             # 全局 Prettier 配置（旧）
├── install.sh              # 一键安装脚本
├── SKILL.md                # Claude Code skill 定义
└── README.md
```

### 为什么某些键在 keybindings.json 而不在 keymaps.lua？

| 按键 | 原因 |
|------|------|
| `Ctrl+h/j/k/l` | VSCode/macOS 在 neovim 之前拦截 Ctrl 组合键 |
| `Alt+j/k` | macOS Alt 产生死键（∆/˚），neovim 收不到 |
| `Ctrl+/`、`Ctrl+\` | 终端切换，需要 VSCode 直接处理 |

---

## Quick Start

### 方式一：一键脚本

```bash
git clone git@github.com:DorianTian/cursor_vscode_config.git
cd cursor_vscode_config

# Cursor
./install.sh cursor

# VSCode
./install.sh code
```

脚本会：安装字体 → 安装扩展 → 备份现有配置 → 复制新配置。

### 方式二：手动配置

#### 1. 安装字体

```bash
brew install --cask font-maple-mono font-victor-mono font-jetbrains-mono
```

#### 2. 安装扩展

```bash
# Theme & Icons
cursor --install-extension dracula-theme.theme-dracula
cursor --install-extension nickcernis.jetbrains-icon-theme-2024
cursor --install-extension antfu.icons-carbon

# Neovim
cursor --install-extension asvetliakov.vscode-neovim

# Git / Diagnostics / Formatters
cursor --install-extension eamodio.gitlens
cursor --install-extension usernamehw.errorlens
cursor --install-extension esbenp.prettier-vscode
cursor --install-extension dbaeumer.vscode-eslint

# Languages
cursor --install-extension Vue.volar
cursor --install-extension golang.go
cursor --install-extension redhat.vscode-yaml
```

#### 3. 复制配置文件

```bash
# Cursor (macOS)
cp cursor-config/settings.json ~/Library/Application\ Support/Cursor/User/settings.json
cp cursor-config/keybindings.json ~/Library/Application\ Support/Cursor/User/keybindings.json

# VSCode (macOS)
cp cursor-config/settings.json ~/Library/Application\ Support/Code/User/settings.json
cp cursor-config/keybindings.json ~/Library/Application\ Support/Code/User/keybindings.json

# Neovim
cp nvim-config/*.lua ~/.config/nvim/lua/config/

# Prettier
cp .prettierrc ~/
```

#### 4. 按需调整

- `settings.json` 中 `http.proxy`（按需取消注释）
- `go.alternateTools.dlv` 路径（`which dlv`）
- `vscode-neovim.neovimExecutablePaths.darwin`（`which nvim`）

---

## 外观

| 项目 | 选择 |
|------|------|
| 主题 | Dracula Theme |
| 图标 | JetBrains Icon Theme |
| Product Icons | Carbon |
| 编辑器字体 | Maple Mono (16px) |
| 终端字体 | Maple Mono (14px) |
| 侧边栏 | 右侧 |
| 斜体 | comment / keyword / this / attribute |

---

## 快捷键速查表

> `<leader>` = 空格键。所有 `<leader>` 开头的键在 keymaps.lua 定义，通过 neovim 触发 VSCode action。

### Vim 基础

| 键 | 功能 | 记忆 |
|----|------|------|
| `jk` | 退出 Insert | **j**ust **k**idding |
| `;` | 命令模式 | 比 `:` 少按一个 Shift |
| `Esc` | 清除搜索高亮 | — |
| `Ctrl+s` | 保存 | — |

### LSP

| 键 | 功能 | 记忆 |
|----|------|------|
| `gd` | 跳转定义 | **g**o to **d**efinition |
| `gD` | Peek 定义 | **g**o **D**eep (peek) |
| `gr` | 查找引用 | **g**o to **r**eferences |
| `gi` | 跳转实现 | **g**o to **i**mplementation |
| `gy` | 跳转类型定义 | **g**o to t**y**pe |
| `gK` | 签名帮助 | — |
| `K` | 悬浮文档 | Vim 原生 |
| `]d` / `[d` | 下/上一个诊断 | **d**iagnostic |
| `]e` / `[e` | 下/上一个错误 | **e**rror |
| `]w` / `[w` | 下/上一个警告 | **w**arning |

### Code（`<leader>c` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>rn` | 重命名 | **r**e**n**ame |
| `<leader>ca` | Code Action | **c**ode **a**ction |
| `<leader>cf` | 格式化 | **c**ode **f**ormat |
| `<leader>co` | 整理 imports | **c**ode **o**rganize |
| `<leader>cr` | 重命名 | **c**ode **r**ename |
| `<leader>cR` | 重构 | **c**ode **R**efactor |
| `<leader>cM` | Source action | **c**ode **M**ore |

### 搜索（`<leader>s` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>sw` | 搜索光标下单词（n/N 导航） | **s**earch **w**ord |
| `<leader>sW` | 项目搜索光标下单词 | **s**earch **W**ord (project) |
| `<leader>sg` | 全局搜索 | **s**earch **g**rep |
| `<leader>/` | 全局搜索（别名） | — |
| `<leader>sb` | Buffer 内搜索 | **s**earch **b**uffer |
| `<leader>sd` | 诊断面板 | **s**earch **d**iagnostics |
| `<leader>ss` | 当前文件 Symbol | **s**earch **s**ymbol |
| `<leader>sS` | 工作区 Symbol | **s**earch **S**ymbol (workspace) |
| `<leader>sr` | 搜索替换 | **s**earch **r**eplace |
| `<leader>sR` | 全局替换 | **s**earch **R**eplace (project) |
| `<leader>sh` | 命令面板 | **s**earch **h**elp |
| `<leader>sk` | 查看快捷键 | **s**earch **k**eymaps |
| `<leader>sm` | 最近编辑器 | **s**earch **m**ru |
| `<leader>sc` | 命令面板 | **s**earch **c**ommands |

### 文件（`<leader>f` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>ff` | 搜索文件 | **f**ind **f**iles |
| `<leader>fb` | 所有 Buffer | **f**ind **b**uffers |
| `<leader>fr` | 最近文件 | **f**ind **r**ecent |
| `<leader>fc` | 打开设置 | **f**ind **c**onfig |
| `<leader>fn` | 新文件 | **f**ile **n**ew |
| `<leader>fp` | 复制相对路径 | **f**ile **p**ath |
| `<leader>fP` | 复制绝对路径 | **f**ile **P**ath (absolute) |
| `<leader>ft` | 新终端 | **f**ile **t**erminal |

### 文件树 / 侧边栏

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>e` | 切换侧边栏 | **e**xplorer |
| `<leader>E` | 在资源管理器中定位当前文件 | **E**xplorer reveal |

### Buffer（`<leader>b` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `H` / `L` | 上/下一个 Tab | Vim 原生 motion 复用 |
| `[b` / `]b` | 上/下一个 Buffer | **b**uffer |
| `<leader>bd` | 关闭 Buffer | **b**uffer **d**elete |
| `<leader>bo` | 关闭其他 | **b**uffer **o**nly |
| `<leader>bD` | 关闭所有 | **b**uffer **D**estroy all |
| `<leader>bp` / `bP` | Pin / Unpin | **b**uffer **p**in |
| `<leader>1-4` | 跳转编辑器 1-4 | 数字直达 |

### 窗口（`<leader>w` 组 + `Ctrl+hjkl`）

| 键 | 功能 | 记忆 |
|----|------|------|
| `Ctrl+h/j/k/l` | 窗口导航 | Vim 方向键 |
| `<leader>wd` | 关闭当前窗口 | **w**indow **d**elete |
| `<leader>w-` / `ws` | 水平分屏 | — / **w**indow **s**plit |
| `<leader>w\|` / `wv` | 垂直分屏 | — / **w**indow **v**ertical |
| `<leader>wo` | 关闭其他窗口 | **w**indow **o**nly |
| `<leader>ww` | 下一个窗口 | **w**indow **w**indow |
| `<leader>w=` | 等宽窗口 | **w**indow **=**equal |

### Tab（`<leader><tab>` 组）

| 键 | 功能 |
|----|------|
| `<leader><tab><tab>` | 切换到上一个 Tab |
| `<leader><tab>d` | 关闭 Tab |
| `<leader><tab>o` | 关闭其他 Tab |
| `<leader><tab>l` | 最后一个 Tab |
| `<leader><tab>f` | 第一个 Tab |

### Quickfix（`<leader>x` 组）

| 键 | 功能 |
|----|------|
| `<leader>xx` | 诊断面板 |
| `<leader>xq` | Quickfix 列表 |
| `[q` / `]q` | 上/下一个 Quickfix |

### UI Toggles（`<leader>u` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>uw` | 切换自动换行 | **u**i **w**rap |
| `<leader>ul` | 切换空白字符 | **u**i white**l**ine |
| `<leader>um` | 切换 Minimap | **u**i **m**inimap |
| `<leader>us` | 切换 Sticky Scroll | **u**i **s**ticky |
| `<leader>ub` | 切换面包屑 | **u**i **b**readcrumbs |
| `<leader>uz` | Zen Mode | **u**i **z**en |
| `<leader>uZ` | 全屏 | **u**i **Z**oom |

### Git（`<leader>g` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>gg` | Git 状态 | **g**it **g**o |
| `<leader>gB` | 文件 Blame | **g**it **B**lame |
| `<leader>gd` | Diff 当前文件 | **g**it **d**iff |
| `<leader>gh` | 文件历史 | **g**it **h**istory |
| `<leader>gl` | Git 日志图 | **g**it **l**og |
| `]c` / `[c` | 下/上一个变更 | **c**hange |
| `]h` / `[h` | 下/上一个 Hunk | **h**unk |
| `<leader>ghs` | Stage Hunk | **g**it **h**unk **s**tage |
| `<leader>ghu` | Unstage Hunk | **g**it **h**unk **u**nstage |
| `<leader>ghr` | Revert Hunk | **g**it **h**unk **r**evert |

### Debug（`<leader>d` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>db` | 断点 | **d**ebug **b**reakpoint |
| `<leader>dB` | 条件断点 | **d**ebug **B**reakpoint (conditional) |
| `<leader>dc` | 继续 | **d**ebug **c**ontinue |
| `<leader>do` | 步过 | **d**ebug step **o**ver |
| `<leader>di` | 步入 | **d**ebug step **i**nto |
| `<leader>dO` | 步出 | **d**ebug step **O**ut |
| `<leader>dt` | 终止 | **d**ebug **t**erminate |
| `<leader>dr` | 重启 | **d**ebug **r**estart |
| `<leader>du` | REPL | **d**ebug **u**i (repl) |
| `<leader>dw` | Watch | **d**ebug **w**atch |
| `<leader>ds` | Call Stack | **d**ebug **s**tack |

### Test（`<leader>t` 组）

| 键 | 功能 | 记忆 |
|----|------|------|
| `<leader>tt` | 运行当前测试 | **t**est **t**his |
| `<leader>tf` | 运行文件测试 | **t**est **f**ile |
| `<leader>ts` | 测试概览 | **t**est **s**ummary |
| `<leader>td` | 调试测试 | **t**est **d**ebug |
| `<leader>tl` | 重跑上次测试 | **t**est **l**ast |
| `<leader>to` | 测试输出 | **t**est **o**utput |

### 终端

| 键 | 功能 |
|----|------|
| `Ctrl+/` | 切换终端 |
| `Ctrl+\` | 切换终端（备选） |
| `<leader>ft` | 新建终端 |

### 杂项

| 键 | 功能 |
|----|------|
| `Alt+j/k` | 移动行（上/下） |
| `ys` / `ds` / `cs` | Surround 操作（nvim-surround） |
| `<leader>l` | 命令面板 |
| `<leader>L` | 快捷键设置 |
| `<leader>qq` | 退出 |
| `<leader>Dt` | 数据库面板 |
| `<leader>cgt` | Go: 添加 tags |
| `<leader>cgr` | Go: 移除 tags |

---

## 已知限制

| LazyVim 功能 | VSCode 状态 | 替代方案 |
|-------------|-------------|----------|
| `[f` / `]f` 函数跳转 | 无等价命令 | `<leader>ss` 打开 Symbol 列表 |
| Telescope 浮窗 | 无法复现 | VSCode Quick Open / 命令面板 |
| Neo-tree 文件树 | 无法复现 | `<leader>e` 侧边栏 |
| which-key 提示 | 无法复现 | 查看本文档 |
| Treesitter textobjects | 部分支持 | 内置的 `vaf` 等不可用 |

---

## 维护

- **添加快捷键**：`keymaps.lua` 的 `vim.g.vscode` 两个分支各加一份
- **Ctrl/Alt 组合键**：加在 `keybindings.json`（VSCode 会拦截）
- **添加插件**：只加到 `~/.config/nvim/lua/plugins/`，VSCode 模式自动跳过
- **换主题**：改 `settings.json` 的 `colorTheme` + `iconTheme`，同时更新 `tokenColorCustomizations` 的 scope 名
- **遇到 `nvim_win_set_cursor` 错误**：`Cmd+Shift+P` → `Neovim: Restart`

---

## 统一代码格式化配置

Enterprise-grade code formatting setup covering frontend, backend, and database languages.

### Supported Languages & Tools

| Language | Formatter | Linter | Reference Standard |
|---|---|---|---|
| JavaScript / TypeScript | Prettier | ESLint | Airbnb + Google Style |
| React (JSX/TSX) | Prettier | ESLint + react-hooks | Airbnb React Style Guide |
| Vue (SFC) | Prettier | ESLint + eslint-plugin-vue | Vue Official Style Guide (A+B) |
| CSS / SCSS / Less | Prettier | — | Google HTML/CSS Style |
| HTML | Prettier | — | Google HTML/CSS Style |
| JSON / YAML / Markdown | Prettier | — | — |
| Go | gofmt + goimports | golangci-lint | Go Official Standard |
| Python | ruff format | ruff check | Black-compatible + PEP 8 |
| SQL | sql-formatter | — | Generic SQL, keywords UPPER |

### Formatter Quick Start

```bash
cd cursor_vscode_config
./setup.sh
```

The setup script will:
1. Install all npm dependencies (Prettier, ESLint, plugins)
2. Install ruff (Python) and goimports (Go) if missing
3. Symlink config files to `$HOME`
4. Merge VS Code / Cursor editor settings
5. Validate all tools are available

### Usage as Shareable npm Config

In your project's `package.json`:

```json
{
  "prettier": "@dorian/prettier-config"
}
```

Or extend in `.prettierrc.js`:

```js
const baseConfig = require('@dorian/prettier-config');
module.exports = {
  ...baseConfig,
  printWidth: 100, // override as needed
};
```

### ESLint Integration

**Projects WITH existing ESLint config:**

```bash
npm install -D eslint-config-prettier
```

Add as the LAST entry in your ESLint config:

```js
// eslint.config.js (flat config)
const prettierConfig = require('eslint-config-prettier');
module.exports = [...yourExistingConfig, prettierConfig];
```

```js
// .eslintrc.js (legacy format)
module.exports = {
  extends: [...yourExistingExtends, 'prettier'],
};
```

**Projects WITHOUT ESLint config:**

Copy the standard baseline:

```bash
cp eslint.config.js your-project/
npm install -D eslint @eslint/js typescript-eslint eslint-config-prettier \
  eslint-plugin-react eslint-plugin-react-hooks eslint-plugin-vue vue-eslint-parser globals
```

### CLI Commands

```bash
# Format
npx prettier --write "src/**/*.{js,ts,jsx,tsx,vue,css,scss,html}"
ruff format .
gofmt -w . && goimports -w .

# Check
npx prettier --check .
npx eslint .
ruff check .

# Combined
npm run check
```

### Key Design Decisions

**React vs Vue attribute formatting:**
- **Vue**: `singleAttributePerLine: true` — Vue Official Style Guide (Priority B) requires each attribute on its own line
- **React**: `singleAttributePerLine: false` — React community convention lets `printWidth` decide natural line breaks

**JSX quotes:**
JSX uses double quotes (`jsxSingleQuote: false`) while JS uses single quotes — consistent with HTML conventions and Airbnb React Style Guide.

**ESLint + Prettier coexistence:**
Prettier handles ALL formatting. ESLint handles code quality only. `eslint-config-prettier` disables every ESLint rule that would conflict with Prettier. Existing project ESLint rules always take priority.

### Formatter File Structure

```
.prettierrc.js       — Prettier config with per-language overrides
.prettierignore      — Files excluded from formatting
.editorconfig        — Universal editor baseline (cross-IDE)
eslint.config.js     — Standard ESLint baseline (for new projects)
ruff.toml            — Python ruff format + lint config
sql-formatter.json   — SQL formatting rules
vscode/settings.json — VS Code / Cursor recommended settings
setup.sh             — One-click local environment setup
index.js             — npm package entry (shareable config)
```

### Recommended VS Code / Cursor Extensions

- [Prettier](https://marketplace.visualstudio.com/items?itemName=esbenp.prettier-vscode)
- [ESLint](https://marketplace.visualstudio.com/items?itemName=dbaeumer.vscode-eslint)
- [Ruff](https://marketplace.visualstudio.com/items?itemName=charliermarsh.ruff)
- [Go](https://marketplace.visualstudio.com/items?itemName=golang.go)
- [EditorConfig](https://marketplace.visualstudio.com/items?itemName=EditorConfig.EditorConfig)

## License

MIT
