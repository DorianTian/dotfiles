#!/usr/bin/env bash
set -euo pipefail

# ══════════════════════════════════════════════════════════
# dotfiles — Symlink-based Configuration Installer
#
# Usage:
#   dotfiles                        # Interactive menu
#   dotfiles all                    # Full setup
#   dotfiles nvim ghostty zsh       # Specific modules
#   dotfiles --ide code all         # Use VSCode instead of Cursor
#   dotfiles --link                 # Register CLI command
#
# Modules:
#   fonts       Install fonts (Maple Mono, Victor Mono, JetBrains Mono, Nerd Font)
#   neovim      Install Neovim
#   extensions  Install IDE extensions (Dracula, GitLens, Prettier, ESLint...)
#   editor      Cursor/VSCode settings.json + keybindings.json
#   nvim        Neovim config (keymaps, lazy, options, plugins, colors)
#   yazi        Yazi terminal file manager + config
#   ghostty     Ghostty terminal + fonts + theme + config
#   zsh         .zshrc + .p10k.zsh + .zshrc.local template
#   formatters  .prettierrc, .editorconfig, ruff.toml, eslint.config.js
#   all         All modules
#
# All config files are SYMLINKED to this repo (not copied).
# Edit files in this repo → changes apply everywhere instantly.
# ══════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ── Colors ──
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC}   $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }

# ── Parse args ──
IDE="cursor"
MODULES=()
LINK=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --ide)  IDE="$2"; shift 2 ;;
    --link) LINK=true; shift ;;
    --help|-h)
      echo "Usage: dotfiles [--ide cursor|code] [--link] <modules...>"
      echo "  (none)    Interactive mode"
      echo "  all       Install everything"
      echo "  --link    Register CLI command (dotfiles)"
      exit 0
      ;;
    *) MODULES+=("$1"); shift ;;
  esac
done

# ── Interactive menu ──
if [[ ${#MODULES[@]} -eq 0 && "$LINK" == "false" ]]; then
  echo ""
  echo "══════════════════════════════════════════════════════════"
  echo "  dotfiles — Symlink-based Configuration Installer"
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
  echo "     7) ghostty      Ghostty terminal + fonts + theme + config"
  echo "     8) zsh          .zshrc + .p10k.zsh"
  echo "     9) formatters   .prettierrc, .editorconfig, ruff.toml, eslint"
  echo ""
  echo "     a) All modules"
  echo "     l) Register CLI command (dotfiles)"
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

# ── Expand all ──
if [[ " ${MODULES[*]} " == *" all "* ]]; then
  MODULES=(fonts neovim extensions editor nvim yazi ghostty zsh formatters)
fi

# ── Platform & paths ──
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

# ── Symlink utility ──
# Back up existing file (if not already a symlink), then create symlink
backup_and_link() {
  local src="$1"
  local dst="$2"
  local name="$(basename "$dst")"

  if [[ -e "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "${dst}.bak"
    success "Backed up $name → ${name}.bak"
  elif [[ -L "$dst" ]]; then
    rm "$dst"
  fi

  ln -sf "$src" "$dst"
  success "$name → $(basename "$(dirname "$src")")/$(basename "$src")"
}

# Symlink a directory (back up existing dir if not already a symlink)
link_dir() {
  local src="$1"
  local dst="$2"
  local name="$(basename "$dst")"

  if [[ -d "$dst" && ! -L "$dst" ]]; then
    mv "$dst" "${dst}.bak"
    success "Backed up $name/ → ${name}.bak/"
  elif [[ -L "$dst" ]]; then
    rm "$dst"
  fi

  ln -sf "$src" "$dst"
  success "$name/ → $(basename "$(dirname "$src")")/$(basename "$src")"
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
  info "▶ [editor] Symlinking Cursor/VSCode config..."
  mkdir -p "$SETTINGS_DIR"

  backup_and_link "$SCRIPT_DIR/cursor-config/settings.json" "$SETTINGS_DIR/settings.json"
  backup_and_link "$SCRIPT_DIR/cursor-config/keybindings.json" "$SETTINGS_DIR/keybindings.json"
}

# ══════════════════════════════════════════════════════════
# Module: nvim (config + plugins + colors)
# ══════════════════════════════════════════════════════════
install_nvim() {
  echo ""
  info "▶ [nvim] Symlinking Neovim config..."
  mkdir -p "$NVIM_CONFIG_DIR"

  # Config files → ~/.config/nvim/lua/config/
  for f in keymaps.lua lazy.lua options.lua autocmds.lua; do
    if [[ -f "$SCRIPT_DIR/nvim-config/$f" ]]; then
      backup_and_link "$SCRIPT_DIR/nvim-config/$f" "$NVIM_CONFIG_DIR/$f"
    fi
  done

  # Plugin files → ~/.config/nvim/lua/plugins/
  local NVIM_PLUGINS_DIR="$HOME/.config/nvim/lua/plugins"
  mkdir -p "$NVIM_PLUGINS_DIR"
  for plugin in ui.lua neo-tree.lua yazi.lua coding.lua formatting.lua git.lua go.lua vim-be-good.lua; do
    if [[ -f "$SCRIPT_DIR/nvim-config/$plugin" ]]; then
      backup_and_link "$SCRIPT_DIR/nvim-config/$plugin" "$NVIM_PLUGINS_DIR/$plugin"
    fi
  done

  # Colorscheme → ~/.config/nvim/colors/
  local NVIM_COLORS_DIR="$HOME/.config/nvim/colors"
  mkdir -p "$NVIM_COLORS_DIR"
  if [[ -f "$SCRIPT_DIR/nvim-config/colors/ghostty.lua" ]]; then
    backup_and_link "$SCRIPT_DIR/nvim-config/colors/ghostty.lua" "$NVIM_COLORS_DIR/ghostty.lua"
  fi
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

  # Symlink config files
  local YAZI_CONFIG_DIR="$HOME/.config/yazi"
  mkdir -p "$YAZI_CONFIG_DIR"

  for f in yazi.toml keymap.toml theme.toml; do
    if [[ -f "$SCRIPT_DIR/yazi-config/$f" ]]; then
      backup_and_link "$SCRIPT_DIR/yazi-config/$f" "$YAZI_CONFIG_DIR/$f"
    else
      warn "$f not found in repo, skipping"
    fi
  done

  # Symlink plugins directory
  if [[ -d "$SCRIPT_DIR/yazi-config/plugins" ]]; then
    link_dir "$SCRIPT_DIR/yazi-config/plugins" "$YAZI_CONFIG_DIR/plugins"
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

  # Install fonts used in Ghostty config
  if command -v brew &>/dev/null; then
    local ghostty_fonts=("font-jetbrains-mono-nerd-font" "font-lxgw-wenkai")
    for font in "${ghostty_fonts[@]}"; do
      if brew list --cask "$font" &>/dev/null 2>&1; then
        success "$font already installed"
      else
        info "  Installing $font..."
        brew install --cask "$font"
        success "$font installed"
      fi
    done
  else
    warn "Homebrew not found. Install fonts manually:"
    echo "    - JetBrains Mono Nerd Font: https://www.nerdfonts.com/"
    echo "    - LXGW WenKai: https://github.com/lxgw/LxgwWenKai"
  fi

  # Symlink config + themes
  local GHOSTTY_CONFIG_DIR="$HOME/.config/ghostty"
  mkdir -p "$GHOSTTY_CONFIG_DIR"

  if [[ -f "$SCRIPT_DIR/ghostty-config/config" ]]; then
    backup_and_link "$SCRIPT_DIR/ghostty-config/config" "$GHOSTTY_CONFIG_DIR/config"
  else
    warn "ghostty-config/config not found in repo, skipping"
  fi

  if [[ -d "$SCRIPT_DIR/ghostty-config/themes" ]]; then
    link_dir "$SCRIPT_DIR/ghostty-config/themes" "$GHOSTTY_CONFIG_DIR/themes"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: zsh (.zshrc + .p10k.zsh + .zshrc.local)
# ══════════════════════════════════════════════════════════
install_zsh() {
  echo ""
  info "▶ [zsh] Setting up Zsh config..."

  # Generate .zshrc.local from existing .zshrc (if needed)
  if [[ ! -f "$HOME/.zshrc.local" ]]; then
    if [[ -f "$HOME/.zshrc" && ! -L "$HOME/.zshrc" ]]; then
      # Extract machine-specific lines from existing .zshrc
      info "  Extracting machine-specific config to ~/.zshrc.local..."
      {
        echo "# ========== Machine-specific Config =========="
        echo "# Auto-extracted from .zshrc during dotfiles setup."
        echo "# Edit this file for machine-specific PATH, proxy, credentials."
        echo ""
        # Extract PATH entries (except common ones)
        grep -E '^export PATH=.*(TeX|go/bin|postgresql|mysql|antigravity)' "$HOME/.zshrc" 2>/dev/null || true
        echo ""
        # Extract proxy settings
        sed -n '/^# ========== Proxy/,/^$/p' "$HOME/.zshrc" 2>/dev/null || true
        echo ""
        # Extract project-specific aliases (AWS, etc.)
        sed -n '/^# ========== AWS/,/^$/p' "$HOME/.zshrc" 2>/dev/null || true
        # Antigravity
        grep -E 'antigravity' "$HOME/.zshrc" 2>/dev/null | grep -v '^#' || true
      } > "$HOME/.zshrc.local"
      success "~/.zshrc.local created (extracted from existing .zshrc)"
      warn "  ⚠ VERIFY: Review ~/.zshrc.local to ensure all PATH/proxy settings are correct"
      warn "  ⚠ BACKUP: Old .zshrc saved as ~/.zshrc.bak — check if anything was missed"
    else
      # New machine — copy template
      cp "$SCRIPT_DIR/zsh-config/.zshrc.local.template" "$HOME/.zshrc.local"
      success "~/.zshrc.local created from template"
      warn "  ⚠ ACTION REQUIRED: Edit ~/.zshrc.local with your machine-specific PATH/proxy"
    fi
  else
    success "~/.zshrc.local already exists, keeping as-is"
  fi

  # Symlink .zshrc
  if [[ -f "$SCRIPT_DIR/zsh-config/.zshrc" ]]; then
    backup_and_link "$SCRIPT_DIR/zsh-config/.zshrc" "$HOME/.zshrc"
  else
    warn "zsh-config/.zshrc not found in repo, skipping"
  fi

  # Symlink .p10k.zsh
  if [[ -f "$SCRIPT_DIR/zsh-config/.p10k.zsh" ]]; then
    backup_and_link "$SCRIPT_DIR/zsh-config/.p10k.zsh" "$HOME/.p10k.zsh"
  else
    warn "zsh-config/.p10k.zsh not found in repo, skipping"
  fi
}

# ══════════════════════════════════════════════════════════
# Module: formatters (.prettierrc, .editorconfig, ruff, eslint)
# ══════════════════════════════════════════════════════════
install_formatters() {
  echo ""
  info "▶ [formatters] Symlinking formatting configs..."

  # Global config files → $HOME
  local global_files=(".prettierrc" ".editorconfig" "ruff.toml")
  for f in "${global_files[@]}"; do
    if [[ -f "$SCRIPT_DIR/$f" ]]; then
      backup_and_link "$SCRIPT_DIR/$f" "$HOME/$f"
    else
      warn "$f not found in repo, skipping"
    fi
  done

  # eslint.config.js — per-project, just show path
  if [[ -f "$SCRIPT_DIR/eslint.config.js" ]]; then
    success "eslint.config.js available at: $SCRIPT_DIR/eslint.config.js"
    info "  Copy to your project: cp $SCRIPT_DIR/eslint.config.js <project-dir>/"
  fi

  # sql-formatter.json
  if [[ -f "$SCRIPT_DIR/sql-formatter.json" ]]; then
    backup_and_link "$SCRIPT_DIR/sql-formatter.json" "$HOME/sql-formatter.json"
  fi
}

# ══════════════════════════════════════════════════════════
# Execute selected modules
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
      warn "Unknown module: $mod (available: fonts neovim extensions editor nvim yazi ghostty zsh formatters all)"
      ;;
  esac
done

# ── Register CLI command ──
if [[ "$LINK" == "true" ]]; then
  echo ""
  info "▶ Registering CLI command..."
  mkdir -p "$HOME/.local/bin"
  ln -sf "$SCRIPT_DIR/install.sh" "$HOME/.local/bin/dotfiles"
  success "dotfiles → $SCRIPT_DIR/install.sh"
  if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    warn "~/.local/bin is not in PATH. Add to ~/.zshrc.local:"
    echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
  fi
fi

# ── Done ──
echo ""
echo "══════════════════════════════════════════════════════════"
if [[ ${#MODULES[@]} -gt 0 ]]; then
  success "Done! Symlinked modules: ${MODULES[*]}"
fi
[[ "$LINK" == "true" ]] && success "CLI registered: dotfiles"
echo ""
echo "  Notes:"
echo "    - All configs are symlinked to: $SCRIPT_DIR"
echo "    - Edit files in the repo → changes apply instantly"
echo "    - Machine-specific config: ~/.zshrc.local"
echo "    - Restart apps to apply changes"
echo "══════════════════════════════════════════════════════════"
echo ""
