function spy --description 'Clone a GitHub repo into ~/Code and cd into it'
    set url $argv[1]

    if test -z "$url"
        echo "usage: spy <github-url>"
        return 1
    end

    if not string match -rq '^https?://github\.com/[^/]+/[^/]+' -- "$url"
        echo "not a github url"
        return 1
    end

    set owner (string replace -r 'https?://github\.com/([^/]+)/[^/]+.*' '$1' -- "$url")
    set repo (string replace -r 'https?://github\.com/[^/]+/([^/]+).*' '$1' -- "$url")
    set repo (string replace -r '\.git$' '' -- "$repo")
    set target "$HOME/Code/$owner/$repo"

    if not test -d "$target"
        mkdir -p (dirname "$target")
        gh repo clone "https://github.com/$owner/$repo" "$target"
    end

    cd "$target"
end
