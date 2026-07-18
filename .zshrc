# Add deno completions to search path
if [[ ":$FPATH:" != *":/home/shunsei-pop/.zsh/completions:"* ]]; then export FPATH="/home/shunsei-pop/.zsh/completions:$FPATH"; fi
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git 
    colored-man-pages 
    command-not-found 
    last-working-dir 
    zsh-interactive-cd
    zsh-autosuggestions
    direnv
)

# Start herdr for interactive shells, but not when already inside a
# multiplexer (tmux) or inside a herdr pane (HERDR_ENV=1). The HERDR_ENV
# guard is required so panes herdr spawns don't recursively launch herdr.
if [[ -t 0 ]] && [ -z "$TMUX" ] && [ -z "$HERDR_ENV" ]; then
  herdr
  exit  # Exit shell when herdr exits
fi

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run alias.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

alias mongo="mongo --port 27018"
alias vim="nvim"

if [[ -t 0 ]]; then
  echo "As-salamualaikum!" | figlet -w 150 -f slant | lolcat
  echo "Today is:             $(date +%A', '%B' '%e', '%Y' ('%Z')')"
  echo "Your Private IP is:   $(hostname -I | awk '{print $1}')"
fi

export NODE_ENV=development
export DENO_INSTALL="$HOME/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

export PGUSER=postgres

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GIT_EDITOR=nvim

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
export PATH="$PNPM_HOME:$PATH"
# pnpm end

export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/elixir/bin:$HOME/julia/bin:$HOME/ngrok/bin"
export PATH="$PATH:/usr/local/go/bin"
export PATH="$PATH:$HOME/go/bin"
export PATH="$PATH:$HOME/.cargo/bin"
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/prisma-fmt/prisma-engines/target/release"

export ERL_AFLAGS="-kernel shell_history enabled"

# add Pulumi to the PATH
export PATH=$PATH:$HOME/.pulumi/bin

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Turso
export PATH="$HOME/.turso:$PATH"

# flyctl
export FLYCTL_INSTALL="$HOME/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

# AWS
# export AWS_PROFILE=litespace_dev

# Flutter
export PATH="$HOME/development/flutter/bin:$PATH"

# Android Studio
export PATH="$HOME/Android/Sdk/platform-tools:$PATH"

# Granted CLI
alias assume="source assume"

alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
alias claude-config='/usr/bin/git --git-dir=$HOME/.claude-config.git/ --work-tree=$HOME'

## Use the same autocomplete for `config` cmd above as for git
compdef config=git

# OpenVPN FFAI
alias vpn='openvpn3 session-start --config ~/Desktop/sufyan-new.ovpn'
alias cvpn='openvpn3 sessions-list | grep "Path:" | awk "{print \$2}" | xargs -I {} openvpn3 session-manage --disconnect --path {}'

# Dagger CLI (CI) completion
autoload -U compinit
compinit -i

# Claude editor
EDITOR=nvim

# place this after nvm initialization!
autoload -U add-zsh-hook

# Automatically switches node version using nvm
# to the one specified in .nvmrc file, if any
load-nvmrc() {
  local nvmrc_path
  nvmrc_path="$(nvm_find_nvmrc)"

  if [ -n "$nvmrc_path" ]; then
    local nvmrc_node_version
    nvmrc_node_version=$(nvm version "$(cat "${nvmrc_path}")")

    if [ "$nvmrc_node_version" = "N/A" ]; then
      nvm install
    elif [ "$nvmrc_node_version" != "$(nvm version)" ]; then
      nvm use
    fi
  elif [ -n "$(PWD=$OLDPWD nvm_find_nvmrc)" ] && [ "$(nvm version)" != "$(nvm version default)" ]; then
    echo "Reverting to nvm default version"
    nvm use default
  fi
}

add-zsh-hook chpwd load-nvmrc
load-nvmrc

export PULUMI_CONFIG_PASSPHRASE=""

## Prompts signing into 1password every time 
## a new terminal is opened which is annoying.
# OP_PERSONAL_ACCOUNT="my.1password.com"
#
# # Needed for avante.nvim to perform web search
# export BRAVE_API_KEY="$(op read 'op://Private/Brave Search API Key/api key' --account "$OP_PERSONAL_ACCOUNT" 2>/dev/null || echo '')"
# export ANTHROPIC_API_KEY="$(op read 'op://Private/Anthropic/api-key' --account "$OP_PERSONAL_ACCOUNT" 2>/dev/null || echo '')"

uuid_to_mongo_bin() {
  local base64uuid
  base64uuid=$(node -e "console.log(Buffer.from(process.argv[1].replace(/-/g, ''), 'hex').toString('base64'))" "$1")
  echo "{ _id: BinData(3, \"$base64uuid\") }"
}

base64_to_uuid() {
  local base64uuid="$1"
  local hex uuid

  # Decode the base64 string to hex using Node.js
  hex=$(node -e "console.log(Buffer.from(process.argv[1], 'base64').toString('hex'))" "$base64uuid")

  # Insert hyphens to format as UUID (8-4-4-4-12)
  uuid="${hex:0:8}-${hex:8:4}-${hex:12:4}-${hex:16:4}-${hex:20:12}"

  echo "$uuid"
}

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

# opencode
export PATH=$HOME/.opencode/bin:$PATH

# vanta
export PATH=/var/vanta:$PATH

# Ensure SHELL is set to zsh
export SHELL=/usr/bin/zsh
export SSH_AUTH_SOCK=~/.1password/agent.sock

alias ffai='cd ~/Projects/ffai'
alias web-client='cd ~/Projects/ffai/web-client'
alias pathways='cd ~/Projects/ffai/ffai-pathways'

alias projects='cd ~/Projects'
alias prj='projects'
alias prjs='projects'
alias p='projects'

alias vault='cd ~/Documents/Obsidian\ Vault'
alias v='vault'
alias ob='vault'
alias ov='vault'

alias tcsm='$HOME/.claude/scripts/tmux-claude-session-manager'

cdwt() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || { echo "cdwt: not in a git repo" >&2; return 1; }
  local wt_dir="$root/.claude/worktrees"
  [[ -d "$wt_dir" ]] || { echo "cdwt: $wt_dir does not exist" >&2; return 1; }
  cd "$wt_dir${1:+/$1}"
}

# View a PR branch as unstaged local changes (for a local diff viewer).
# Leaves HEAD detached at the base, all PR changes unstaged in the worktree.
# Usage: pr-unstage <pr-branch> [base]   (base defaults to origin's default branch)
pr-unstage() {
  local branch="$1" base="$2"
  [[ -n "$branch" ]] || { echo "usage: pr-unstage <pr-branch> [base]" >&2; return 1; }
  git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "pr-unstage: not in a git repo" >&2; return 1; }
  if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "pr-unstage: working tree not clean — commit or stash first" >&2; return 1
  fi
  git fetch origin || return 1
  if [[ -z "$base" ]]; then
    base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
    base=${base:-origin/main}
  fi
  git rev-parse --verify --quiet "$base" >/dev/null || base="origin/$base"
  git rev-parse --verify --quiet "$base" >/dev/null || { echo "pr-unstage: base not found" >&2; return 1; }
  git switch --detach "$branch" 2>/dev/null \
    || git switch --detach "origin/$branch" 2>/dev/null \
    || { echo "pr-unstage: branch '$branch' not found" >&2; return 1; }
  git reset --soft "$base" || return 1   # HEAD -> base; index + worktree keep PR tree (staged)
  git reset || return 1                  # unstage -> PR diff as unstaged changes
  git add -N . 2>/dev/null               # surface new files in `git diff`
  echo "pr-unstage: $branch vs $base — changes unstaged, HEAD detached at base. Run 'git switch -' to leave."
}

# Run the video-transcriber (whisper-rs) on a YouTube URL or local file, from any dir.
# Output (.txt + .srt) lands in ./out of the current directory. Defaults: large-v3, Arabic.
# Requires the release binary to be built first: see ~/Projects/video-transcriber/CLAUDE.md
transcribe() {
  /home/shunsei-pop/Projects/video-transcriber/target/release/video-transcriber "$@"
}

# pyenv (Python version management — e.g. ffai-pathways needs 3.10 via .python-version)
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

# asdf (erlang/elixir version manager)
export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

# Pi
export PATH="/home/shunsei-pop/.local/share/pi-node/node-v22.22.3-linux-x64/bin:$PATH"

export EDITOR=nvim
. "/home/shunsei-pop/.deno/env"
