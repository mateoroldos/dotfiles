export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH
export PATH="/home/runguinator/.cache/.bun/bin:$PATH"

[ -f ~/.env ] && source ~/.env

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env)"

[ -f ~/.bash/work.sh ] && source ~/.bash/work.sh
