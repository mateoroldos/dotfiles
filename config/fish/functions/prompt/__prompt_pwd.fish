function __prompt_pwd --description 'Show the path anchored at the repo root, never abbreviated'
    if set -l root (__prompt_repo_root)
        printf '%s%s%s%s%s' \
            (set_color brblack) (path basename $root) \
            (set_color $fish_color_cwd) (string replace -- $root '' $PWD) \
            (set_color normal)
    else
        printf '%s%s%s' (set_color $fish_color_cwd) (string replace -- $HOME '~' $PWD) (set_color normal)
    end
end

# Walk up with builtins only — `jj workspace root` / `git rev-parse` would fork on every prompt.
function __prompt_repo_root --description 'Print the nearest ancestor holding .jj or .git'
    set -l dir $PWD
    while test $dir != /
        if test -d $dir/.jj -o -d $dir/.git
            echo $dir
            return 0
        end
        set dir (path dirname $dir)
    end
    return 1
end
