#!/usr/bin/env bash
# ===========================================================================
# Unified Code Formatting — One-Click Setup Script
#
# Installs and configures:
#   - Prettier (JS/TS/React/Vue/CSS/HTML/JSON/YAML/Markdown/SQL)
#   - ESLint + eslint-config-prettier (code quality + conflict resolution)
#   - ruff (Python formatting + linting)
#   - gofmt + goimports (Go formatting)
#   - sql-formatter (SQL CLI formatting)
#   - EditorConfig
#   - VS Code / Cursor settings
# ===========================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Colors & helpers
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $*"; }
success() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() {
  echo -e "${RED}[ERROR]${NC} $*"
  exit 1
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# 1. Check prerequisites
# ---------------------------------------------------------------------------
info "Checking prerequisites..."

# Node.js
if ! command -v node &>/dev/null; then
  error "Node.js not found. Install via: curl -fsSL https://fnm.vercel.app/install | bash && fnm install --lts"
fi
NODE_VER=$(node -v)
info "  Node.js: $NODE_VER"

# npm
if ! command -v npm &>/dev/null; then
  error "npm not found."
fi
info "  npm: $(npm -v)"

# ---------------------------------------------------------------------------
# 2. Install npm dependencies
# ---------------------------------------------------------------------------
info "Installing npm dependencies..."
cd "$SCRIPT_DIR"
npm install
success "npm dependencies installed."

# ---------------------------------------------------------------------------
# 3. Install / check ruff (Python)
# ---------------------------------------------------------------------------
info "Checking ruff (Python formatter + linter)..."
if command -v ruff &>/dev/null; then
  success "  ruff: $(ruff --version)"
else
  info "  Installing ruff..."
  if command -v pip3 &>/dev/null; then
    pip3 install ruff --quiet
  elif command -v pipx &>/dev/null; then
    pipx install ruff
  elif command -v brew &>/dev/null; then
    brew install ruff
  else
    warn "  Could not install ruff automatically. Install manually: pip3 install ruff"
  fi
  if command -v ruff &>/dev/null; then
    success "  ruff: $(ruff --version)"
  fi
fi

# ---------------------------------------------------------------------------
# 4. Check Go tools
# ---------------------------------------------------------------------------
info "Checking Go tools..."
if command -v go &>/dev/null; then
  success "  go: $(go version | awk '{print $3}')"
  if ! command -v goimports &>/dev/null; then
    info "  Installing goimports..."
    go install golang.org/x/tools/cmd/goimports@latest
  fi
  if command -v goimports &>/dev/null; then
    success "  goimports: installed"
  fi
else
  warn "  Go not found. Skipping Go tools. Install from: https://go.dev/dl/"
fi

# ---------------------------------------------------------------------------
# 5. Symlink config files to $HOME (backup existing)
# ---------------------------------------------------------------------------
info "Setting up config symlinks..."

link_config() {
  local src="$1"
  local dst="$2"

  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local backup="${dst}.backup.$(date +%Y%m%d%H%M%S)"
    warn "  Backing up existing $dst -> $backup"
    mv "$dst" "$backup"
  elif [ -L "$dst" ]; then
    rm "$dst"
  fi

  ln -s "$src" "$dst"
  success "  $dst -> $src"
}

link_config "$SCRIPT_DIR/.prettierrc.js" "$HOME/.prettierrc.js"
link_config "$SCRIPT_DIR/.prettierignore" "$HOME/.prettierignore"
link_config "$SCRIPT_DIR/.editorconfig" "$HOME/.editorconfig"
link_config "$SCRIPT_DIR/ruff.toml" "$HOME/ruff.toml"

# Remove old .prettierrc (JSON format) if it conflicts
if [ -f "$HOME/.prettierrc" ] && [ ! -L "$HOME/.prettierrc" ]; then
  backup="$HOME/.prettierrc.backup.$(date +%Y%m%d%H%M%S)"
  warn "  Moving old $HOME/.prettierrc -> $backup (replaced by .prettierrc.js)"
  mv "$HOME/.prettierrc" "$backup"
fi

# ---------------------------------------------------------------------------
# 6. Copy VS Code / Cursor settings
# ---------------------------------------------------------------------------
info "Setting up VS Code / Cursor settings..."

copy_vscode_settings() {
  local target_dir="$1"
  local name="$2"

  if [ -d "$target_dir" ]; then
    local settings_file="$target_dir/settings.json"
    if [ -f "$settings_file" ]; then
      local backup="${settings_file}.backup.$(date +%Y%m%d%H%M%S)"
      warn "  Backing up existing $name settings -> $backup"
      cp "$settings_file" "$backup"
    fi

    # Merge: read existing settings and our settings, our settings take precedence
    if [ -f "$settings_file" ] && command -v node &>/dev/null; then
      node -e "
                const fs = require('fs');
                const stripJsonComments = (str) => str.replace(/\/\/.*$/gm, '').replace(/\/\*[\s\S]*?\*\//g, '');
                let existing = {};
                try { existing = JSON.parse(stripJsonComments(fs.readFileSync('$settings_file', 'utf8'))); } catch(e) {}
                const ours = JSON.parse(stripJsonComments(fs.readFileSync('$SCRIPT_DIR/vscode/settings.json', 'utf8')));
                const merged = { ...existing, ...ours };
                fs.writeFileSync('$settings_file', JSON.stringify(merged, null, 2) + '\n');
            "
      success "  Merged settings into $name"
    else
      mkdir -p "$target_dir"
      cp "$SCRIPT_DIR/vscode/settings.json" "$settings_file"
      success "  Copied settings to $name"
    fi
  else
    info "  $name config dir not found, skipping: $target_dir"
  fi
}

# macOS paths
if [[ "$OSTYPE" == "darwin"* ]]; then
  copy_vscode_settings "$HOME/Library/Application Support/Code/User" "VS Code"
  copy_vscode_settings "$HOME/Library/Application Support/Cursor/User" "Cursor"
# Linux paths
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
  copy_vscode_settings "$HOME/.config/Code/User" "VS Code"
  copy_vscode_settings "$HOME/.config/Cursor/User" "Cursor"
fi

# ---------------------------------------------------------------------------
# 7. ESLint integration guidance
# ---------------------------------------------------------------------------
echo ""
info "=========================================="
info "ESLint Integration Guide"
info "=========================================="
echo ""
info "For projects WITH existing ESLint config:"
info "  1. Install: npm install -D eslint-config-prettier"
info "  2. Add 'eslint-config-prettier' as the LAST item in your config:"
info ""
info "     // eslint.config.js (flat config)"
info "     const prettierConfig = require('eslint-config-prettier');"
info "     module.exports = [ ...yourConfig, prettierConfig ];"
info ""
info "     // .eslintrc.js (legacy)"
info "     { extends: [...yourExtends, 'prettier'] }"
echo ""
info "For projects WITHOUT ESLint config:"
info "  Copy the standard config from this repo:"
info "  cp $SCRIPT_DIR/eslint.config.js your-project/"
echo ""

# ---------------------------------------------------------------------------
# 8. Validation
# ---------------------------------------------------------------------------
info "Validating installation..."

PASS=true

check_tool() {
  local name="$1"
  local cmd="$2"
  if eval "$cmd" &>/dev/null; then
    success "  $name"
  else
    warn "  $name — not available"
    PASS=false
  fi
}

check_tool "prettier" "npx prettier --version"
check_tool "eslint" "npx eslint --version"
check_tool "sql-formatter" "npx sql-formatter --version"
check_tool "ruff" "ruff --version"
check_tool "gofmt" "gofmt -h"

echo ""
if [ "$PASS" = true ]; then
  success "=========================================="
  success "All tools configured successfully!"
  success "=========================================="
else
  warn "=========================================="
  warn "Setup complete with warnings. Check above."
  warn "=========================================="
fi

echo ""
info "Quick start:"
info "  Format JS/TS/Vue/React : npx prettier --write \"src/**/*.{js,ts,jsx,tsx,vue,css,scss,html}\""
info "  Format Python          : ruff format ."
info "  Format Go              : gofmt -w . && goimports -w ."
info "  Format SQL             : npx sql-formatter --config $SCRIPT_DIR/sql-formatter.json < input.sql"
info "  Lint (ESLint)          : npx eslint ."
info "  Check all              : npm run check"
echo ""
