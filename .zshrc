# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="pixegami-agnoster"
preexec() {
  SECONDS=0
}
RPROMPT='$(if (( SECONDS > 5 )); then print -n "%F{green}${SECONDS}s%f  "; fi)%F{yellow} %*%f'


# source ~/powerlevel10k/powerlevel10k.zsh-theme
# # To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Set list of themes to load
# Setting this variable when ZSH_THEME=random
# cause zsh load theme from this variable instead of
# looking in ~/.oh-my-zsh/themes/
# An empty array have no effect
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

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
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  zsh-syntax-highlighting
  zsh-autosuggestions
  docker
  docker-compose
  kubectl
)

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
#

# Start in Insert mode by default
bindkey -v
# Map Ctrl+; to toggle between insert and normal mode
# function toggle_vi_mode() {
#   if [[ $KEYMAP == vicmd ]]; then
#     bindkey -v   # Switch to Insert Mode
#     echo "Insert Mode"
#   else
#     bindkey -v   # Switch to Normal Mode
#     echo "Normal Mode"
#   fi
# }

if command -v fcitx5 > /dev/null && ! pgrep -x "fcitx5" > /dev/null; then
    (fcitx5 &>/dev/null &)
fi

bindkey "^;" toggle_vi_mode
bindkey -M viins '\e' vi-cmd-mode 
bindkey -M vicmd '\e' vi-ins-mode
bindkey '^R' _history-complete-older   # Ctrl+R for older history
bindkey '^N' _history-complete-newer   # Ctrl+N for newer history

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/rsa_id"
# export SCRIPT_DIR="$HOME/.config/i3blocks/i3blocks/scripts"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export BROWSER=firefox

export EDITOR=nvim
export VISUAL=nvim

export GTK_USE_PORTAL=1
export PATH="$HOME/.local/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

[ -x /usr/bin/clang ] && export CC=/usr/bin/clang
export PATH="$PATH":"$HOME/.pub-cache/bin"

alias q='exit'
alias emulator=~/Android/Sdk/emulator/emulator
if [ -d "$HOME/Documents/flutter/flutter/bin" ]; then
    export PATH="$PATH:$HOME/Documents/flutter/flutter/bin"
    alias flutter="$HOME/Documents/flutter/flutter/bin/flutter"
elif [ -d "$HOME/flutter/bin" ]; then
    export PATH="$PATH:$HOME/flutter/bin"
fi

alias zshrc='nvim ~/.zshrc'
[ -f /opt/ros/lyrical/setup.zsh ] && source /opt/ros/lyrical/setup.zsh

