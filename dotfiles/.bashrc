direnv allow .
eval "$(direnv hook bash)"

alias l='ls -F'
alias ll='ls -Fl'
alias lll='ls -Fla'
alias m='bat -p'
alias k=kubectl
alias d=docker
alias dc='docker compose'

export PS1="[\e[0;31m${NAMESPACE:-\?}\e[0m/\e[0;31m${POD_NAME:-\?}\e[0m]\n\e[0;32m\w\e[0m > "
