set -gx PATH $HOME/.npm-global/bin $PATH

if status is-interactive
    set -g fish_greeting ""
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    function work
        bash -lc 'source ~/.bash/work.sh; work "$@"' -- $argv
    end

    if type -q mise
        mise activate fish | source
    end
end

# Generated for envman. Do not edit.
test -s ~/.config/envman/load.fish; and source ~/.config/envman/load.fish
