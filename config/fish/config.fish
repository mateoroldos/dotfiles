test -f /usr/share/cachyos-fish-config/cachyos-config.fish; and source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
function fish_greeting
    # smth smth
end

# mise.run installs mise here; fish does not read ~/.profile, which adds it for bash
fish_add_path --path ~/.local/bin
mise activate fish | source
zoxide init fish | source

fish_config theme choose cendre

set -gx EDITOR nvim
