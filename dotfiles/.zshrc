#
# zsh stuff:
#

autoload -U colors && colors

#
# direnv:
#

eval "$(direnv hook zsh)"

#
# fzf
#

source <(fzf --zsh)

# -- Use fd instead of find --

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git --exclude .clj-kondo . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git --exclude .clj-kondo . "$1"
}

export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always --line-range :500 {}'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

# Advanced customization of fzf options via _fzf_comprun function
# - The first argument to the function is the name of the command.
# - You should make sure to pass the rest of the arguments to fzf.
_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo \$'{}"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "bat -n --color=always --line-range :500 {}" "$@" ;;
  esac
}

export FZF_DEFAULT_OPTS='--reverse'

#
# Prompt:
#

if [[ -n $NAMESPACE ]]; then
  export PS1="[%{$fg[blue]%}${NAMESPACE}%{$reset_color%}/%{$fg[blue]%}${POD_NAME}%{$reset_color%}] %{$fg[yellow]%}%~%{$reset_color%}"$'\n'"> "
elif [[ -n $SSH_CONNECTION ]]; then
  export PS1="[%{$fg[blue]%}%m%{$reset_color%}/%{$fg[blue]%}%n%{$reset_color%}] %{$fg[yellow]%}%~%{$reset_color%}"$'\n'"> "
else
  export PS1="%{$fg[yellow]%}%~%{$reset_color%} > "
fi

#
# Installation helpers:
#

export PATH=$PATH:$HOME/.local/bin

#
# Common aliases:
#

alias l='ls -F'
alias ll='ls -Fl'
alias lll='ls -Fla'
alias m='bat -p'
alias k=kubectl
alias d=docker
alias dc='docker compose'
alias lg=lazygit
alias agc='ag -U --clojure'
