test -f /usr/share/cachyos-fish-config/cachyos-config.fish; and source /usr/share/cachyos-fish-config/cachyos-config.fish

# overwrite greeting
function fish_greeting
    # smth smth
end

# mise.run installs mise here; fish does not read ~/.profile, which adds it for bash
fish_add_path --path ~/.local/bin
mise activate fish | source
zoxide init fish | source

fish_config theme choose mellifluous

set -gx EDITOR nvim

# Over SSH there's no browser here, and Debian falls back to lynx. Print URLs
# instead; the local terminal opens them on click.
if set -q SSH_CONNECTION
    set -gx BROWSER echo
end

# Use the systemd user ssh-agent (Debian) if nothing else already provides one
if not set -q SSH_AUTH_SOCK; and test -S $XDG_RUNTIME_DIR/openssh_agent
    set -gx SSH_AUTH_SOCK $XDG_RUNTIME_DIR/openssh_agent
end
