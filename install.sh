#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════
# ide-config — Cursor / VSCode + vscode-neovim 模块化配置安装脚本
#
# 用法:
#   ide-config                      # 交互式菜单
#   ide-config all                  # 全量安装
#   ide-config editor nvim          # 只装指定模块
#   ide-config --ide code all       # 指定 VSCode
#   ide-config --link               # 注册 CLI 命令
#
# 可用模块:
#   fonts       安装字体（Maple Mono, Victor Mono, JetBrains Mono, Nerd Font）
#   neovim      安装 Neovim
#   extensions  安装 IDE 扩展（Dracula, GitLens, Prettier, ESLint...）
#   editor      复制 settings.json + keybindings.json
#   nvim        复制 keymaps.lua + lazy.lua + options.lua
#   yazi        安装 Yazi 终端文件管理器 + 复制配置
#   ghostty     安装 Ghostty 终端 + LXGW WenKai Mono 字体 + 复制配置
#   zsh         复制 .zshrc + .p10k.zsh
#   formatters  复制 .prettierrc, .editorconfig, ruff.toml, eslint.config.js
#   all         以上全部
# ══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── 颜色 ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

# ── 解析参数 ──
IDE="cursor"
MODULES=()
LINK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide)
      IDE="$2"
      shift 2
      ;;
    --link)
      LINK=true
      shift
      ;;
    --help|-h)
      echo "Usage: ide-config [--ide cursor|code] [--link] <modules...>"
      echo ""
      echo "  (none)       Interactive mode"
      echo "  all          Install everything"
      echo "  --link       Register CLI command (ide-config)"
      echo "  --help       Show this help"
      exit 0
      ;;
    *)
      MODULES+=("$1")
      shift
      ;;
  esac
done

# ── 无参数时交互式菜单 ──
if [[ ${#MODULES[@]} -eq 0 && "$LINK" == "false" ]]; then
  echo ""
  echo "══════════════════════════════════════════════════════════"
  echo "  ide-config — IDE Configuration Installer"
  echo "══════════════════════════════════════════════════════════"
  echo ""
  echo "  Select modules to install:"
  echo ""
  echo "     1) fonts        Maple Mono, Victor Mono, JetBrains Mono, Nerd Font"
  echo "     2) neovim       Install Neovim"
  echo "     3) extensions   IDE extensions (Dracula, GitLens, Prettier...)"
  echo "     4) editor       settings.json + keybindings.json"
  echo "     5) nvim         keymaps.lua + lazy.lua + options.lua + plugins"
  echo "     6) yazi         Yazi file manager + config"
  echo "     7) ghostty      Ghostty terminal + LXGW WenKai font + config"
  echo "     8) zsh          .zshrc + .p10k.zsh"
  echo "     9) formatters   .prettierrc, .editorconfig, ruff.toml, eslint"
  echo ""
  echo "     a) All modules"
  echo "     l) Register CLI command (ide-config)"
  echo "     f) Full setup (all + CLI)"
  echo ""
  printf "  IDE [cursor/code] (default: cursor): "
  read -r ide_choice
  [[ -n "$ide_choice" ]] && IDE="$ide_choice"
  echo ""
  printf "  Enter choices (e.g. 4 5 9, or a for all): "
  read -r choices

  ALL_MODULES=(fonts neovim extensions editor nvim yazi ghostty zsh formatters)
  for choice in $choices; do
    case "$choice" in
      1) MODULES+=(fonts) ;;
      2) MODULES+=(neovim) ;;
      3) MODULES+=(extensions) ;;
      4) MODULES+=(editor) ;;
      5) MODULES+=(nvim) ;;
      6) MODULES+=(yazi) ;;
      7) MODULES+=(ghostty) ;;
      8) MODULES+=(zsh) ;;
      9) MODULES+=(formatters) ;;
      a) MODULES=("${ALL_MODULES[@]}") ;;
      l) LINK=true ;;
      f) MODULES=("${ALL_MODULES[@]}"); LINK=true ;;
      *) echo "  ⚠ Unknown option: $choice" ;;
    esac
  done
  echo ""
fi

# ── 展开 all ──
if [[ " ${MODULES[*]} " == *" all "* ]]; then
  MODULES=(fonts neovim extensions editor nvim yazi ghostty zsh formatters)
fi

# ── 检测平台 & 路径 ──
OS="$(uname -s)"
case "$OS" in
  Darwin)
    if [[ "$IDE" == "cursor" ]]; then
      SETTINGS_DIR="$HOME/Library/Application Support/Cursor/User"
      CLI_CMD="cursor"
    else
      SETTINGS_DIR="$HOME/Library/Application Support/Code/User"
      CLI_CMD="code"
    fi
    ;;
  Linux)
    if [[ "$IDE" == "cursor" ]]; then
      SETTINGS_DIR="$HOME/.config/Cursor/User"
      CLI_CMD="cursor"
    else
      SETTINGS_DIR="$HOME/.config/Code/User"
      CLI_CMD="code"
    fi
    ;;
  *)
    echo "Unsupported platform: $OS"
    exit 1
    ;;
esac

NVIM_CONFIG_DIR="$HOME/.config/nvim/lua/config"

echo ""
echo "══════════════════════════════════════════════════════════"
echo "  IDE:     $IDE | Platform: $OS"
echo "  Modules: ${MODULES[*]}"
echo "══════════════════════════════════════════════════════════"

# ── 备份工具函数 ──
backup_and_copy() {
  local src="$1"
  local dst="$2"
  local name="$(basename "$dst")"

  if [[ -f "$dst" ]]; then
    cp "$dst" "${dst}.bak"
    success "Backed up $name → ${name}.bak"
  fi
  cp "$src" "$dst"
  success "$name"
}

# ══════════════════════════════════════════════════════════
# Module: fonts
# ══════════════════════════════════════════════════════════
install_fonts() {
  echo ""
  info "▶ [fonts] Installing fonts..."
  if command -v brew &>/dev/null; then
    brew install --cask font-maple-mono font-victor-mono font-jetbrains-mono font-jetbrains-mono-nerd-font 2>/dev/null || true
    success "Fonts installed (or already present)"
  else
    warn "Homebrew not found. Install fonts manually:"
    echo "    - Maple Mono: https://github.com/subframe7536/maple-font"
    echo "    - Victor Mono: https://rubjo.github.io/victor-mono/"
    echo "    - JetBrains Mono: https://www.jetbrains.com/lp/mono/"
    echo "    - JetBrains Mono Nerd Font: https://www.nerdfonts.com/"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: neovim
# ══════════════════════════════════════════════════════════
install_neovim() {
  echo ""
  info "▶ [neovim] Checking Neovim..."
  if command -v nvim &>/dev/null; then
    success "Neovim found: $(nvim --version | head -1)"
  else
    info "Installing Neovim..."
    if command -v brew &>/dev/null; then
      brew install neovim
      success "Neovim installed"
    else
      warn "Please install Neovim manually: https://neovim.io"
    fi
  fi
}

# ══════════════════════════════════════════════════════════
# Module: extensions
# ══════════════════════════════════════════════════════════
install_extensions() {
  echo ""
  info "▶ [extensions] Installing IDE extensions..."
  if command -v "$CLI_CMD" &>/dev/null; then
    EXTENSIONS=(
      # Theme & Icons
      "dracula-theme.theme-dracula"
      "nickcernis.jetbrains-icon-theme-2024"
      "antfu.icons-carbon"
      # Neovim
      "asvetliakov.vscode-neovim"
      # Git
      "eamodio.gitlens"
      # Diagnostics
      "usernamehw.errorlens"
      # Formatters
      "esbenp.prettier-vscode"
      "dbaeumer.vscode-eslint"
      "charliermarsh.ruff"
      # Languages
      "Vue.volar"
      "golang.go"
      "redhat.vscode-yaml"
    )
    for ext in "${EXTENSIONS[@]}"; do
      info "  Installing $ext..."
      "$CLI_CMD" --install-extension "$ext" --force 2>/dev/null || true
    done
    success "Extensions installed"
  else
    warn "'$CLI_CMD' CLI not found. Install extensions manually."
  fi
}

# ══════════════════════════════════════════════════════════
# Module: editor (settings.json + keybindings.json)
# ══════════════════════════════════════════════════════════
install_editor() {
  echo ""
  info "▶ [editor] Copying Cursor/VSCode config..."
  mkdir -p "$SETTINGS_DIR"

  backup_and_copy "$SCRIPT_DIR/cursor-config/settings.json" "$SETTINGS_DIR/settings.json"
  backup_and_copy "$SCRIPT_DIR/cursor-config/keybindings.json" "$SETTINGS_DIR/keybindings.json"
}

# ══════════════════════════════════════════════════════════
# Module: nvim (keymaps.lua + lazy.lua + options.lua)
# ══════════════════════════════════════════════════════════
install_nvim() {
  echo ""
  info "▶ [nvim] Copying Neovim config..."
  mkdir -p "$NVIM_CONFIG_DIR"

  for f in keymaps.lua lazy.lua options.lua autocmds.lua; do
    if [[ -f "$SCRIPT_DIR/nvim-config/$f" ]]; then
      backup_and_copy "$SCRIPT_DIR/nvim-config/$f" "$NVIM_CONFIG_DIR/$f"
    fi
  done

  # Terminal-only neovim plugins (skipped in VSCode)
  local NVIM_PLUGINS_DIR="$HOME/.config/nvim/lua/plugins"
  mkdir -p "$NVIM_PLUGINS_DIR"
  for plugin in ui.lua neo-tree.lua yazi.lua coding.lua formatting.lua git.lua go.lua vim-be-good.lua; do
    if [[ -f "$SCRIPT_DIR/nvim-config/$plugin" ]]; then
      backup_and_copy "$SCRIPT_DIR/nvim-config/$plugin" "$NVIM_PLUGINS_DIR/$plugin"
    fi
  done
}

# ══════════════════════════════════════════════════════════
# Module: yazi (terminal file manager + config)
# ══════════════════════════════════════════════════════════
install_yazi() {
  echo ""
  info "▶ [yazi] Setting up Yazi file manager..."

  # Install yazi and preview dependencies
  if command -v brew &>/dev/null; then
    local yazi_pkgs=("yazi" "ffmpeg" "sevenzip" "poppler" "chafa")
    for pkg in "${yazi_pkgs[@]}"; do
      if command -v "$pkg" &>/dev/null || brew list "$pkg" &>/dev/null 2>&1; then
        success "$pkg already installed"
      else
        info "  Installing $pkg..."
        brew install "$pkg" 2>/dev/null || true
      fi
    done
  else
    warn "Homebrew not found. Install manually: brew install yazi ffmpeg sevenzip poppler"
  fi

  # Install glow for markdown preview
  if ! command -v glow &>/dev/null; then
    info "  Installing glow (markdown renderer)..."
    brew install glow 2>/dev/null || true
  else
    success "glow already installed"
  fi

  # Copy config files
  local YAZI_CONFIG_DIR="$HOME/.config/yazi"
  mkdir -p "$YAZI_CONFIG_DIR"

  for f in yazi.toml keymap.toml theme.toml; do
    if [[ -f "$SCRIPT_DIR/yazi-config/$f" ]]; then
      backup_and_copy "$SCRIPT_DIR/yazi-config/$f" "$YAZI_CONFIG_DIR/$f"
    else
      warn "$f not found in repo, skipping"
    fi
  done

  # Copy glow plugin for markdown preview
  if [[ -d "$SCRIPT_DIR/yazi-config/plugins/glow.yazi" ]]; then
    mkdir -p "$YAZI_CONFIG_DIR/plugins/glow.yazi"
    cp "$SCRIPT_DIR/yazi-config/plugins/glow.yazi/main.lua" "$YAZI_CONFIG_DIR/plugins/glow.yazi/main.lua"
    success "glow.yazi plugin"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: ghostty (terminal emulator + config)
# ══════════════════════════════════════════════════════════
install_ghostty() {
  echo ""
  info "▶ [ghostty] Setting up Ghostty terminal..."

  # Install Ghostty
  if [[ -d "/Applications/Ghostty.app" ]]; then
    success "Ghostty already installed"
  elif command -v brew &>/dev/null; then
    info "  Installing Ghostty..."
    brew install --cask ghostty
    success "Ghostty installed"
  else
    warn "Homebrew not found. Download Ghostty from: https://ghostty.org/download"
  fi

  # Install LXGW WenKai Mono font (Chinese fallback font used in config)
  if brew list --cask font-lxgw-wenkai-mono-tc &>/dev/null 2>&1; then
    success "font-lxgw-wenkai-mono-tc already installed"
  elif command -v brew &>/dev/null; then
    info "  Installing LXGW WenKai Mono TC font..."
    brew install --cask font-lxgw-wenkai-mono-tc
    success "font-lxgw-wenkai-mono-tc installed"
  else
    warn "Homebrew not found. Install LXGW WenKai Mono manually from: https://github.com/lxgw/LxgwWenkaiMono"
  fi

  # Copy config
  local GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
  mkdir -p "$GHOSTTY_CONFIG_DIR"

  if [[ -f "$SCRIPT_DIR/ghostty-config/config" ]]; then
    backup_and_copy "$SCRIPT_DIR/ghostty-config/config" "$GHOSTTY_CONFIG_DIR/config"
  else
    warn "ghostty-config/config not found in repo, skipping"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: zsh (.zshrc + Powerlevel10k config)
# ══════════════════════════════════════════════════════════
install_zsh() {
  echo ""
  info "▶ [zsh] Copying Zsh config..."

  if [[ -f "$SCRIPT_DIR/zsh-config/.zshrc" ]]; then
    backup_and_copy "$SCRIPT_DIR/zsh-config/.zshrc" "$HOME/.zshrc"
  else
    warn "zsh-config/.zshrc not found in repo, skipping"
  fi

  if [[ -f "$SCRIPT_DIR/zsh-config/.p10k.zsh" ]]; then
    backup_and_copy "$SCRIPT_DIR/zsh-config/.p10k.zsh" "$HOME/.p10k.zsh"
  else
    warn "zsh-config/.p10k.zsh not found in repo, skipping"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: formatters (.prettierrc, .editorconfig, ruff, eslint)
# ══════════════════════════════════════════════════════════
install_formatters() {
  echo ""
  info "▶ [formatters] Copying formatting configs..."

  # 全局配置文件 → $HOME
  local global_files=(".prettierrc" ".editorconfig" "ruff.toml")
  for f in "${global_files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$f" ]]; then
      backup_and_copy "$SCRIPT_DIR/$f" "$HOME/$f"
    else
      warn "$f not found in repo, skipping"
    fi
  done

  # eslint.config.js → 提示用户按项目复制
  if [[ -f "$SCRIPT_DIR/eslint.config.js" ]]; then
    success "eslint.config.js available at: $SCRIPT_DIR/eslint.config.js"
    info "  Copy to your project: cp $SCRIPT_DIR/eslint.config.js <project-dir>/"
  fi

  # sql-formatter.json
  if [[ -f "$SCRIPT_DIR/sql-formatter.json" ]]; then
    backup_and_copy "$SCRIPT_DIR/sql-formatter.json" "$HOME/sql-formatter.json"
  fi
}

# ══════════════════════════════════════════════════════════
# 执行选中的模块
# ══════════════════════════════════════════════════════════
for mod in "${MODULES[@]}"; do
  case "$mod" in
    fonts)      install_fonts ;;
    neovim)     install_neovim ;;
    extensions) install_extensions ;;
    editor)     install_editor ;;
    nvim)       install_nvim ;;
    yazi)       install_yazi ;;
    ghostty)    install_ghostty ;;
    zsh)        install_zsh ;;
    formatters) install_formatters ;;
    *)
      warn "Unknown module: $mod (available: fonts neovim extensions editor nvim yazi formatters all)"
      ;;
  esac
done

# ── Register CLI command ──
if [[ "$LINK" == "true" ]]; then
  echo ""
  info "▶ Registering CLI command..."
  mkdir -p "$HOME/.local/bin"
  ln -sf "$SCRIPT_DIR/install.sh" "$HOME/.local/bin/ide-config"
  success "ide-config → $SCRIPT_DIR/install.sh"
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "~/.local/bin is not in PATH. Add to ~/.zshrc:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi
fi

# ── 完成 ──
echo ""
echo "══════════════════════════════════════════════════════════"
if [[ ${#MODULES[@]} -gt 0 ]]; then
  success "Done! Installed modules: ${MODULES[*]}"
fi
[[ "$LINK" == "true" ]] && success "CLI registered: ide-config"
echo ""
echo "  Notes:"
echo "    - Restart $IDE to apply changes"
echo "    - settings.json: uncomment http.proxy if needed"
echo "    - Run 'which nvim' to verify neovim path in settings"
echo "══════════════════════════════════════════════════════════"
echo ""
