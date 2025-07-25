# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/home/shunsei/.oh-my-zsh"

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
)

# Start tmux if not already inside a tmux session
if [ -z "$TMUX" ]; then
  tmux
  exit  # Exit shell when tmux exits
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

echo "As-salamualaikum!" | figlet -w 150 -f slant | lolcat
echo "Today is:             $(date +%A', '%B' '%e', '%Y' ('%Z')')"
echo "Your Private IP is:   $(hostname -I | awk '{print $1}')"

export NODE_ENV=development
export DENO_INSTALL="/home/shunsei/.deno"
export PATH="$DENO_INSTALL/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export GIT_EDITOR=nvim

# pnpm
export PNPM_HOME="/home/shunsei/.local/share/pnpm"
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
[ -s "/home/shunsei/.bun/_bun" ] && source "/home/shunsei/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Turso
export PATH="/home/shunsei/.turso:$PATH"

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

alias config='/usr/bin/git --git-dir=/home/shunsei/.cfg/ --work-tree=/home/shunsei'

## Use the same autocomplete for `config` cmd above as for git
compdef config=git

# OpenVPN FFAI
alias vpn='openvpn3 session-start --config ~/Desktop/sufyan-new.ovpn'
alias cvpn='openvpn3 session-manage --disconnect --config ~/Desktop/sufyan-new.ovpn'

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

OP_PERSONAL_ACCOUNT="my.1password.com"

# Needed for avante.nvim to perform web search
export BRAVE_API_KEY="$(op read 'op://Private/Brave Search API Key/api key' --account "$OP_PERSONAL_ACCOUNT" 2>/dev/null || echo '')"
export ANTHROPIC_API_KEY="$(op read 'op://Private/Anthropic/api-key' --account "$OP_PERSONAL_ACCOUNT" 2>/dev/null || echo '')"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
