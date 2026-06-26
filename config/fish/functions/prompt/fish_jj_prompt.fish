function fish_jj_prompt --description 'Show the current jj change'
    command -sq jj
    or return 1

    # Returning non-zero outside a jj repo is what lets fish_vcs_prompt fall through to git.
    command jj log \
        --revisions @ \
        --limit 1 \
        --ignore-working-copy \
        --no-pager \
        --no-graph \
        --color always \
        --template '
            surround(
                " ",
                "",
                separate(
                    " ",
                    separate(
                        "·",
                        bookmarks.map(|bookmark| label("bookmark", bookmark.name())).join(","),
                        label("change_id", change_id.shortest(4)),
                    ),
                    if(!empty, label("prompt_dirty", "●")),
                    if(conflict, label("conflict", "×")),
                    if(divergent, label("divergent", "⇡")),
                    if(hidden, label("hidden", "◌")),
                ),
            )
        ' 2>/dev/null
end
