function fish_jj_prompt --description 'jj prompt segment'
    command -sq jj; or return 1
    jj root --quiet &>/dev/null; or return 1
    set -l jj_info (jj log \
        --ignore-working-copy \
        --no-graph \
        --color never \
        --revisions @ \
        --template '
            bookmarks.join(",") ++ "|" ++
            separate(" ",
                if(conflict,  label("conflict",  "⚡conflict")),
                if(divergent, label("divergent", "~divergent")),
                if(empty,     label("empty",     "∅")),
            )
        ' 2>/dev/null | string trim)
    test -n "$jj_info"; or return 1
    set -l parts (string split "|" $jj_info)
    set -l bookmark $parts[1]
    set -l state $parts[2]
    set -l shown_bookmark $bookmark
    set -l distance ""

    if test -z "$bookmark"
        # 1. look for nearest bookmark ABOVE @ (descendants) — primary
        set -l nearest_above (jj log \
            --ignore-working-copy \
            --no-graph \
            --color never \
            --limit 1 \
            --revisions 'descendants(@, 10) & bookmarks() & ~@' \
            --template 'change_id.shortest(4) ++ "|" ++ local_bookmarks.join(",") ++ "\n"' \
            2>/dev/null | string trim)
        # 2. look for nearest bookmark BELOW @ (ancestors on path to trunk) — fallback
        set -l nearest_below (jj log \
            --ignore-working-copy \
            --no-graph \
            --color never \
            --limit 1 \
            --revisions 'trunk()::@ & bookmarks() & ~@' \
            --template 'change_id.shortest(4) ++ "|" ++ local_bookmarks.join(",") ++ "\n"' \
            2>/dev/null | string trim)
        if test -n "$nearest_above"
            set -l near_parts (string split "|" $nearest_above)
            set -l near_id $near_parts[1]
            set -l near_name $near_parts[2]
            set -l count (jj log \
                --ignore-working-copy \
                --no-graph \
                --color never \
                --revisions "@..$near_id" \
                --template 'change_id ++ "\n"' \
                2>/dev/null | count)
            set shown_bookmark $near_name
            set distance "-$count"
        else if test -n "$nearest_below"
            set -l near_parts (string split "|" $nearest_below)
            set -l near_id $near_parts[1]
            set -l near_name $near_parts[2]
            set -l count (jj log \
                --ignore-working-copy \
                --no-graph \
                --color never \
                --revisions "$near_id..@" \
                --template 'change_id ++ "\n"' \
                2>/dev/null | count)
            set shown_bookmark $near_name
            set distance "+$count"
        else
            set shown_bookmark "·"
        end
    end

    set -l inner $shown_bookmark
    set -l suffix ""
    set -l colored_distance ""
    if test -n "$distance"
        set colored_distance (set_color --dim yellow)$distance
    end
    if test -n "$state"
        if string match -q "*∅*" -- $state
            set suffix " "(set_color green)"∅"(set_color normal)
        else if string match -q "*⚡conflict*" -- $state
            set suffix (set_color red)"⚡conflict"(set_color normal)
        else if string match -q "*~divergent*" -- $state
            set suffix (set_color yellow)"~divergent"(set_color normal)
        end
    end
    printf ' %s%s%s%s%s' (set_color normal; set_color yellow) $inner $colored_distance (set_color normal) $suffix
end
