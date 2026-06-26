function jjw --description 'Manage jj workspaces'
    set cmd $argv[1]

    if test -n "$cmd"
        set -e argv[1]
    end

    switch "$cmd"
        case new
            __jjw_new $argv
        case list ls
            __jjw_list $argv
        case cd
            __jjw_cd $argv
        case remove rm
            __jjw_remove $argv
        case root
            __jjw_root $argv
        case '' help -h --help
            __jjw_help
        case '*'
            echo "unknown command: $cmd" >&2
            __jjw_help
            return 1
    end
end

function __jjw_new
    if not command -q jj
        echo 'error: jj not found on PATH' >&2
        return 1
    end

    set name ''
    set from (pwd)
    set root ''

    while test (count $argv) -gt 0
        switch $argv[1]
            case --from
                if test (count $argv) -lt 2
                    echo 'error: --from requires a directory' >&2
                    return 1
                end
                set from $argv[2]
                set -e argv[1..2]
            case --root
                if test (count $argv) -lt 2
                    echo 'error: --root requires a directory' >&2
                    return 1
                end
                set root $argv[2]
                set -e argv[1..2]
            case -h --help
                echo 'usage: jjw new [name] [--from DIR] [--root DIR]'
                return 0
            case '--*'
                echo "unknown option: $argv[1]" >&2
                return 1
            case '*'
                if test -n "$name"
                    echo "unexpected argument: $argv[1]" >&2
                    return 1
                end
                set name $argv[1]
                set -e argv[1]
        end
    end

    set from (__jjw_realpath "$from"); or return 1

    if not test -e "$from/.jj"
        echo "error: not a jj workspace: $from" >&2
        return 1
    end

    if test -z "$name"
        set name (__jjw_generate_name)
    end

    if not string match -rq '^[A-Za-z0-9._/-]+$' -- "$name"
        echo 'error: name must match [A-Za-z0-9._/-]' >&2
        return 1
    end

    set root (__jjw_root --root "$root"); or return 1
    set repo (basename "$from")
    set slug (__jjw_slug "$name")
    set dest "$root/$repo/$slug"

    if test -e "$dest"
        echo "error: workspace already exists: $dest" >&2
        return 1
    end

    mkdir -p (dirname "$dest"); or return 1

    echo "+ jj workspace add --name $name $dest"
    command jj --repository "$from" workspace add --name "$name" "$dest"; or return 1

    echo "+ jj bookmark create $name -r @"
    command jj --repository "$dest" bookmark create "$name" -r @; or echo "warning: could not create bookmark: $name" >&2

    cd "$dest"
end

function __jjw_list
    set root ''

    while test (count $argv) -gt 0
        switch $argv[1]
            case --root
                if test (count $argv) -lt 2
                    echo 'error: --root requires a directory' >&2
                    return 1
                end
                set root $argv[2]
                set -e argv[1..2]
            case -h --help
                echo 'usage: jjw list [--root DIR]'
                return 0
            case '*'
                echo "unexpected argument: $argv[1]" >&2
                return 1
        end
    end

    set root (__jjw_root --root "$root"); or return 1

    if not test -d "$root"
        return 0
    end

    for repo in "$root"/*
        if test -d "$repo"
            for workspace in "$repo"/*
                if test -d "$workspace/.jj"
                    echo "$workspace"
                end
            end
        end
    end
end

function __jjw_cd
    set root ''

    while test (count $argv) -gt 0
        switch $argv[1]
            case --root
                if test (count $argv) -lt 2
                    echo 'error: --root requires a directory' >&2
                    return 1
                end
                set root $argv[2]
                set -e argv[1..2]
            case -h --help
                echo 'usage: jjw cd [--root DIR]'
                return 0
            case '*'
                echo "unexpected argument: $argv[1]" >&2
                return 1
        end
    end

    set choices (__jjw_list --root "$root")

    if test (count $choices) -eq 0
        echo 'no jj workspaces found' >&2
        return 1
    end

    if command -q fzf
        set choice (printf '%s\n' $choices | fzf --prompt='jj workspace> ')
    else
        printf '%s\n' $choices
        echo 'install fzf for interactive selection' >&2
        return 1
    end

    if test -z "$choice"
        return 1
    end

    cd "$choice"
end

function __jjw_remove
    if not command -q jj
        echo 'error: jj not found on PATH' >&2
        return 1
    end

    set yes 0

    while test (count $argv) -gt 0
        switch $argv[1]
            case --yes -y
                set yes 1
                set -e argv[1]
            case -h --help
                echo 'usage: jjw remove [--yes]'
                return 0
            case '*'
                echo "unexpected argument: $argv[1]" >&2
                return 1
        end
    end

    set cwd (__jjw_realpath (pwd)); or return 1

    if not test -e "$cwd/.jj"
        echo "error: not a jj workspace: $cwd" >&2
        return 1
    end

    if test -d "$cwd/.jj/repo"
        echo "error: refusing to remove main jj workspace: $cwd" >&2
        return 1
    end

    switch "$cwd"
        case / "$HOME"
            echo "error: refusing to remove unsafe path: $cwd" >&2
            return 1
    end

    if test $yes -ne 1
        read --prompt-str "remove jj workspace $cwd? [y/N] " answer
        if not string match -qir '^y(es)?$' -- "$answer"
            return 1
        end
    end

    set parent (dirname "$cwd")

    echo '+ jj workspace forget'
    command jj workspace forget; or return 1

    cd "$parent"; or return 1

    echo "+ rm -rf $cwd"
    rm -rf "$cwd"
end

function __jjw_root
    set root ''

    while test (count $argv) -gt 0
        switch $argv[1]
            case --root
                if test (count $argv) -lt 2
                    echo 'error: --root requires a directory' >&2
                    return 1
                end
                set root $argv[2]
                set -e argv[1..2]
            case '*'
                echo "unexpected argument: $argv[1]" >&2
                return 1
        end
    end

    if test -z "$root"
        set root "$JJ_WORKSPACE_ROOT"
    end

    if test -z "$root"
        set root "$HOME/jj-workspaces"
    end

    switch "$root"
        case '~'
            echo "$HOME"
        case '~/*'
            string replace '~' "$HOME" -- "$root"
        case '*'
            echo "$root"
    end
end

function __jjw_realpath
    set dir $argv[1]

    if test -z "$dir"
        echo 'error: missing directory' >&2
        return 1
    end

    if not test -d "$dir"
        echo "error: directory does not exist: $dir" >&2
        return 1
    end

    realpath "$dir"
end

function __jjw_generate_name
    set adjectives brave calm clear green lucky quiet rapid silver
    set nouns river cloud field forest harbor meadow stone valley
    set adjective (random choice $adjectives)
    set noun (random choice $nouns)
    set suffix (random 1000 9999)

    echo "workspace/$adjective-$noun-$suffix"
end

function __jjw_slug
    set name $argv[1]
    set slug (string lower -- "$name" | string replace -ra '[^a-z0-9]+' '-' | string trim -c '-')

    if test -z "$slug"
        echo workspace
    else
        echo "$slug"
    end
end

function __jjw_help
    echo 'usage: jjw <command> [options]'
    echo
    echo 'commands:'
    echo '  new [name] [--from DIR] [--root DIR]  create and cd into a workspace'
    echo '  list [--root DIR]                     list managed workspaces'
    echo '  cd [--root DIR]                       pick a workspace with fzf and cd into it'
    echo '  remove [--yes]                        forget and delete the current workspace'
    echo '  root                                  print the workspace root'
end
