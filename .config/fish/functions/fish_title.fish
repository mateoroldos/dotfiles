function fish_title
    if command -sq git
        set -l root (git rev-parse --show-toplevel 2>/dev/null)
        if test -n "$root"
            echo (path basename -- $root)
            return
        end
    end

    set -l parts
    for part in (string split "/" -- $PWD)
        if test -n "$part"
            set parts $parts $part
        end
    end

    set -l total (count $parts)
    if test $total -ge 3
        echo (string join "/" $parts[(math $total - 2)] $parts[(math $total - 1)] $parts[$total])
    else if test $total -gt 0
        echo (string join "/" $parts)
    else
        echo /
    end
end
