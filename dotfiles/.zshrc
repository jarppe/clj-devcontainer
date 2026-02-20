#
# zsh stuff:
#

autoload -U colors && colors

#
# direnv:
#

eval "$(direnv hook zsh)"

#
# fzf:
#

source <(fzf --zsh)

#
# fd:
#

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
# Common aliases:
#

alias l='eza'
alias ll='eza -l'
alias lll='eza -la'
alias bat=batcat
alias fd=fdfind
alias lg=lazygit
alias m='bat -p'
alias agc='ag -U --clojure'
alias d=docker
alias dc='docker compose'
alias drun='docker run --rm -it'
alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias k=kubectl
alias ccc='claude --dangerously-skip-permissions'
