if status is-interactive
    set -g fish_greeting ""
    # Commands to run in interactive sessions can go here
    zoxide init fish | source
    function work
        bash -lc 'source ~/.bash/work.sh; work "$@"' -- $argv
    end
end
