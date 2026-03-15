#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════
# Cursor / VSCode + vscode-neovim 模块化配置安装脚本
#
# 用法:
#   ./install.sh                    # 显示可用模块
#   ./install.sh all                # 全量安装
#   ./install.sh editor nvim        # 只装指定模块
#   ./install.sh --ide code all     # 指定 VSCode
#   ./install.sh --ide cursor editor nvim formatters
#
# 可用模块:
#   fonts       安装字体（Maple Mono, Victor Mono, JetBrains Mono, Nerd Font）
#   neovim      安装 Neovim
#   extensions  安装 IDE 扩展（Dracula, GitLens, Prettier, ESLint...）
#   editor      复制 settings.json + keybindings.json
#   nvim        复制 keymaps.lua + lazy.lua + options.lua
#   yazi        安装 Yazi 终端文件管理器 + 复制配置
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

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide)
      IDE="$2"
      shift 2
      ;;
    *)
      MODULES+=("$1")
      shift
      ;;
  esac
done

# ── 无参数时显示帮助 ──
if [[ ${#MODULES[@]} -eq 0 ]]; then
  echo ""
  echo "Usage: ./install.sh [--ide cursor|code] <module1> [module2] ..."
  echo ""
  echo "Available modules:"
  echo "  fonts       Install fonts (Maple Mono, Victor Mono, JetBrains Mono, Nerd Font)"
  echo "  neovim      Install Neovim"
  echo "  extensions  Install IDE extensions"
  echo "  editor      Copy settings.json + keybindings.json"
  echo "  nvim        Copy keymaps.lua + lazy.lua + options.lua"
  echo "  yazi        Install Yazi file manager + copy config"
  echo "  formatters  Copy .prettierrc, .editorconfig, ruff.toml, eslint.config.js"
  echo "  all         Install everything"
  echo ""
  echo "Examples:"
  echo "  ./install.sh all                    # Full install for Cursor"
  echo "  ./install.sh editor nvim            # Only editor + nvim configs"
  echo "  ./install.sh --ide code all         # Full install for VSCode"
  echo "  ./install.sh formatters             # Only formatting configs"
  echo ""
  exit 0
fi

# ── 展开 all ──
if [[ " ${MODULES[*]} " == *" all "* ]]; then
  MODULES=(fonts neovim extensions editor nvim yazi formatters)
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

  for f in keymaps.lua lazy.lua options.lua; do
    backup_and_copy "$SCRIPT_DIR/nvim-config/$f" "$NVIM_CONFIG_DIR/$f"
  done

  # Terminal-only neovim plugins (skipped in VSCode)
  local NVIM_PLUGINS_DIR="$HOME/.config/nvim/lua/plugins"
  mkdir -p "$NVIM_PLUGINS_DIR"
  for plugin in yazi.lua codecompanion.lua; do
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
    formatters) install_formatters ;;
    *)
      warn "Unknown module: $mod (available: fonts neovim extensions editor nvim yazi formatters all)"
      ;;
  esac
done

# ── 完成 ──
echo ""
echo "══════════════════════════════════════════════════════════"
success "Done! Installed modules: ${MODULES[*]}"
echo ""
echo "  Notes:"
echo "    - Restart $IDE to apply changes"
echo "    - settings.json: uncomment http.proxy if needed"
echo "    - Run 'which nvim' to verify neovim path in settings"
echo "══════════════════════════════════════════════════════════"
echo ""
