# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ========== Environment Variables ==========
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export EDITOR="nvim"
export VISUAL="nvim"

# ========== PATH ==========
export PATH="/Library/TeX/texbin:$PATH"
export PATH=$PATH:/usr/local/go/bin
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# ========== NVM ==========
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# ========== Proxy ==========
export http_proxy=http://127.0.0.1:6152
export https_proxy=http://127.0.0.1:6152
# export all_proxy=socks5://127.0.0.1:6153
unset all_proxy

# ========== Oh-My-Zsh ==========
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# zsh-completions fpath (must be before source oh-my-zsh.sh)
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

plugins=(
  git                       # git aliases & completions
  zsh-autosuggestions       # fish-like autosuggestions
  zsh-syntax-highlighting   # real-time syntax highlighting
  zsh-completions           # additional completion definitions
  zsh-history-substring-search  # history substring search
  you-should-use            # reminds you of existing aliases
  extract                   # extract any archive with `x`
  z                         # directory jumping via frecency
  colored-man-pages         # colorful man pages
  command-not-found         # suggest package when command not found
  sudo                      # press ESC twice to add sudo
  copypath                  # copy current path to clipboard
  copyfile                  # copy file content to clipboard
  web-search                # search from terminal
  aliases                   # alias management
  docker                    # docker completions
)

source $ZSH/oh-my-zsh.sh

# ========== Completion System ==========
FPATH=$(brew --prefix)/share/zsh-completions:$FPATH

zstyle ':completion:*' menu select                           # arrow key selection menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"      # colored completion list
zstyle ':completion:*' group-name ''                          # group by category
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches --%f'
zstyle ':completion:*' rehash true                            # auto-detect new commands
zstyle ':completion:*' use-cache on                           # enable completion cache
zstyle ':completion:*' cache-path ~/.zsh/cache

# ========== Auto-suggestion Config ==========
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#808080,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20

# ========== Syntax Highlighting Config ==========
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[alias]='fg=green,bold'
ZSH_HIGHLIGHT_STYLES[builtin]='fg=cyan,bold'
ZSH_HIGHLIGHT_STYLES[function]='fg=magenta,bold'
ZSH_HIGHLIGHT_STYLES[path]='fg=cyan,underline'
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=yellow'
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[redirection]='fg=blue,bold'
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=red,bold'
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor)

# ========== History ==========
HISTFILE=~/.zsh_history
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt EXTENDED_HISTORY

# ========== Zsh Options ==========
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt CORRECT
setopt INTERACTIVE_COMMENTS
setopt NO_BEEP

# ========== Key Bindings ==========
bindkey '^[[A' history-search-backward   # Up arrow: search history backward
bindkey '^[[B' history-search-forward    # Down arrow: search history forward
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^W' backward-kill-word
bindkey '^ ' autosuggest-accept          # Ctrl+Space: accept auto-suggestion
bindkey '^F' forward-word                # Ctrl+F: move forward one word

# ========== FZF (Catppuccin Macchiato) ==========
source <(fzf --zsh)

export FZF_DEFAULT_OPTS="
  --height=60% --layout=reverse --border=rounded
  --info=inline --margin=1 --padding=1
  --color=bg+:#1e1e1e,bg:#000000,spinner:#f5e0dc,hl:#f38ba8
  --color=fg:#e0e0e0,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc
  --color=marker:#f5e0dc,fg+:#ffffff,prompt:#cba6f7,hl+:#f38ba8
  --prompt='  ' --pointer='▶' --marker='✓'
  --preview-window='right:60%:wrap'
"

export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always --level=2 {}'"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'

# ========== Modern Tool Aliases ==========
# eza (ls replacement)
alias ls='eza --icons --group-directories-first'
alias ll='eza -lah --icons --group-directories-first --git'
alias la='eza -a --icons --group-directories-first'
alias lt='eza --tree --level=3 --icons'
alias llt='eza -lah --tree --level=2 --icons --git'

# bat (cat replacement)
alias cat='bat --paging=never'
alias catp='bat --plain'
export BAT_THEME="Catppuccin Mocha"
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# delta (git diff beautifier)
export GIT_PAGER="delta"

# zoxide (cd replacement)
eval "$(zoxide init zsh)"
alias cd='z'

# grep
alias grep='grep --color=auto'

# ========== Git Aliases ==========
alias gst='git status'
alias glp='git log --oneline --graph --decorate'
alias glo='git log --oneline -20'
alias gs='git switch'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gd='git diff'
alias gds='git diff --staged'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch'
alias gba='git branch -a'
alias grb='git rebase'
alias gco='git checkout'
alias gcp='git cherry-pick'
alias gss='git stash'
alias gsp='git stash pop'

# ========== Neovim ==========
alias v="nvim"
alias vi="nvim"

# ========== Yazi (terminal file manager) ==========
# Wrapper: quit yazi → auto cd to the directory you navigated to
function y() {
  local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
  yazi "$@" --cwd-file="$tmp"
  if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}

# ========== Codex ==========
alias codex="nocorrect codex"

# ========== AWS (Ask Dorian) ==========
export EC2_HOST="13.214.45.162"
export EC2_KEY="$HOME/Downloads/aix-ops-hub-key.pem"
export RDS_HOST="ask-dorian-db.cboq4wuogzyb.ap-southeast-1.rds.amazonaws.com"

alias ad-server='ssh -i $EC2_KEY ubuntu@$EC2_HOST'
alias ad-db='ssh -i $EC2_KEY -t ubuntu@$EC2_HOST "psql \"host=$RDS_HOST port=5432 dbname=ask_dorian user=dorian sslmode=verify-full sslrootcert=/certs/global-bundle.pem\""'
alias ad-tunnel='ssh -i $EC2_KEY -L 5432:$RDS_HOST:5432 -N ubuntu@$EC2_HOST'
alias ad-db-local='psql "host=localhost port=5432 dbname=ask_dorian user=dorian sslmode=require"'

# ========== Utility Aliases & Functions ==========
alias reload='source ~/.zshrc'
alias cls='clear'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -pv'
alias ports='lsof -i -P -n | grep LISTEN'
alias myip='curl -s ifconfig.me'
alias weather='curl -s wttr.in'
alias path='echo $PATH | tr ":" "\n" | nl'
alias h='history | tail -50'

mkcd() { mkdir -p "$1" && cd "$1"; }
ff()   { fd --type f --hidden "$@"; }
fgr()  { rg --color=always -n "$@"; }

# ========== thefuck ==========
eval $(thefuck --alias)

# ========== Claude Code ==========
unset CLAUDECODE

# ========== Powerlevel10k ==========
# Theme is loaded by Oh-My-Zsh via ZSH_THEME setting
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Added by Antigravity
export PATH="/Users/tianqiyin/.antigravity/antigravity/bin:$PATH"
