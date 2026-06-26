source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
function fish_greeting
    # smth smth
end

mise activate fish | source
zoxide init fish | source

fish_config theme choose cendre --color-theme=dark

set -gx EDITOR nvim
