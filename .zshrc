export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH

[ -f ~/.env ] && source ~/.env

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# LOAD NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

work() {
    local selection
    selection=$(find ~/Projects -mindepth 2 -maxdepth 2 -type d | \
        sed 's|.*/Projects/||' | \
        sort | \
        fzf --prompt="Select Project: " --height=40% --reverse)
    
    if [[ -n "$selection" ]]; then
        cd ~/Projects/"$selection"
        zellij --layout coding
    fi
}
