export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH
export PATH="/home/runguinator/.cache/.bun/bin:$PATH"

[ -f ~/.env ] && source ~/.env

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(fnm env)"

# LOAD NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

work() {
    local selection
    selection=$(find ~/Projects -mindepth 2 -maxdepth 2 -type d | \
        sed 's|.*/Projects/||' | \
        sort | \
        fzf --prompt="Select Project: " --height=40% --reverse)
    
    if [[ -n "$selection" ]]; then
        cd ~/Projects/"$selection"
        zellij --layout coding
    fi
}

work-jj() {
    local mktemp_bin
    mktemp_bin=$(command -v mktemp 2>/dev/null)
    if [[ -z "$mktemp_bin" ]]; then
        echo "work-jj: mktemp not found in PATH" >&2
        return 1
    fi
    local zellij_bin
    zellij_bin=$(command -v zellij 2>/dev/null)
    if [[ -z "$zellij_bin" ]]; then
        echo "work-jj: zellij not found in PATH" >&2
        return 1
    fi
    local jj_bin
    jj_bin=$(command -v jj 2>/dev/null)
    if [[ -z "$jj_bin" ]]; then
        echo "work-jj: jj not found in PATH" >&2
        return 1
    fi
    local fzf_bin
    fzf_bin=$(command -v fzf 2>/dev/null)
    if [[ -z "$fzf_bin" ]]; then
        echo "work-jj: fzf not found in PATH" >&2
        return 1
    fi
    local zellij_sessions
    zellij_sessions=$("$zellij_bin" list-sessions --short 2>/dev/null)
    local -a all_sessions work_sessions
    if [[ -n "$zellij_sessions" ]]; then
        while IFS= read -r session; do
            [[ -z "$session" ]] && continue
            all_sessions+=("$session")
            [[ "$session" == work-* ]] && work_sessions+=("$session")
        done <<< "$zellij_sessions"
    fi
    if [[ -z "$ZELLIJ" ]]; then
        if (( ${#work_sessions[@]} > 0 )); then
            local -a attach_options
            local session tab_line session_tabs
            for session in "${work_sessions[@]}"; do
                session_tabs=""
                tab_line=$(ZELLIJ_SESSION_NAME="$session" "$zellij_bin" action query-tab-names 2>/dev/null)
                if [[ -n "$tab_line" ]]; then
                    session_tabs=$(printf "%s" "$tab_line" | tr '\n' ',' | sed 's/,/, /g; s/, $//')
                fi
                if [[ -n "$session_tabs" ]]; then
                    attach_options+=("${session} :: ${session_tabs}")
                else
                    attach_options+=("${session}")
                fi
            done
            local attach_choice
            attach_choice=$(printf "%s\n" "${attach_options[@]}" "NEW SESSION" | \
                "$fzf_bin" --prompt="Attach work session: " --height=40% --reverse)
            if [[ -n "$attach_choice" ]]; then
                if [[ "$attach_choice" == "NEW SESSION" ]]; then
                    attach_choice=""
                else
                local session_name="${attach_choice%% ::*}"
                "$zellij_bin" attach "$session_name"
                return $?
                fi
            fi
        fi
    fi
    local selection project project_dir
    local projects_root="$HOME/Projects"
    local project_base project_parent
    local -a project_list
    local candidate
    while IFS= read -r -d '' candidate; do
        if [[ -f "$candidate/.jj/repo" ]]; then
            continue
        fi
        local rel="${candidate#$projects_root/}"
        project_list+=("$rel")
    done < <(find "$projects_root" -mindepth 2 -maxdepth 2 -type d -print0)
    if (( ${#project_list[@]} == 0 )); then
        echo "work-jj: no projects found in $projects_root" >&2
        return 1
    fi
    selection=$(printf "%s\n" "${project_list[@]}" | \
        sort | \
        "$fzf_bin" --prompt="Select Project: " --height=40% --reverse)

    if [[ -z "$selection" ]]; then
        return
    fi

    project="$selection"
    project_dir=~/Projects/"$project"
    project_base="${project##*/}"
    project_parent="${project_dir%/*}"
    cd "$project_dir" || return

    if [[ ! -d ".jj" ]]; then
        "$jj_bin" git init >/dev/null 2>&1 || return
    fi

    local ws_lines
    local -a ws_names
    ws_lines=$("$jj_bin" workspace list 2>/dev/null)
    if [[ -n "$ws_lines" ]]; then
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local name="${line%%:*}"
            name="${name#\* }"
            [[ -z "$name" || "$name" == "$line" ]] && continue
            ws_names+=("$name")
        done <<< "$ws_lines"
    fi

    local -a options
    for name in "${ws_names[@]}"; do
        local display="$name"
        if [[ "$name" == "$project/"* ]]; then
            display="${project}/${name##*/}"
        elif [[ "$name" != "default" ]]; then
            display="${project}/${name}"
        fi
        options+=("${display}"$'\t'"${name}")
    done
    options+=("NEW TASK")

    local choice task_name workspace_name display_name task_dir_name is_new
    choice=$(printf "%s\n" "${options[@]}" | \
        "$fzf_bin" --prompt="Select Task: " --height=40% --reverse --delimiter=$'\t' --with-nth=1)
    if [[ -z "$choice" ]]; then
        return
    fi

    if [[ "$choice" == "NEW TASK" ]]; then
        read "task_name?Task name: "
        is_new=1
    else
        display_name="${choice%%$'\t'*}"
        workspace_name="${choice#*$'\t'}"
    fi

    if [[ -n "$is_new" ]]; then
        if [[ -z "$task_name" ]]; then
            return
        fi
        workspace_name="$task_name"
        display_name="${project}/${task_name}"
        task_dir_name="$task_name"
    else
        if [[ -z "$workspace_name" ]]; then
            return
        fi
        task_dir_name="${workspace_name##*/}"
    fi

    if [[ -z "$workspace_name" ]]; then
        return
    fi

    local workspace_dir=""
    if [[ "$workspace_name" == "default" ]]; then
        workspace_dir="$project_dir"
    elif [[ -d "$project_dir/$task_dir_name" ]]; then
        workspace_dir="$project_dir/$task_dir_name"
    elif [[ -d "$project_parent/${project_base}-${task_dir_name}" ]]; then
        workspace_dir="$project_parent/${project_base}-${task_dir_name}"
    else
        local repo_dir
        if [[ -d "$project_dir/.jj/repo" ]]; then
            repo_dir="$project_dir/.jj/repo"
        elif [[ -f "$project_dir/.jj/repo" ]]; then
            repo_dir=$(<"$project_dir/.jj/repo")
        fi
        if [[ -n "$repo_dir" ]]; then
            while IFS= read -r candidate; do
                local repo_ptr
                repo_ptr=$(<"$candidate")
                if [[ "$repo_ptr" == "$repo_dir" || "$repo_ptr" == "$repo_dir/" ]]; then
                    local candidate_dir="${candidate%/.jj/repo}"
                    if [[ "$candidate_dir" == */"$task_dir_name" ]]; then
                        workspace_dir="$candidate_dir"
                        break
                    fi
                fi
            done < <(find "$project_dir/.." -maxdepth 2 -type f -path '*/.jj/repo' 2>/dev/null)
        fi
    fi

    if [[ -z "$workspace_dir" ]]; then
        if [[ -n "$is_new" ]]; then
            workspace_dir="$project_parent/${project_base}-${task_dir_name}"
            "$jj_bin" workspace add --name "$workspace_name" "$workspace_dir" || return
        else
            echo "work-jj: workspace dir not found for $workspace_name" >&2
            return 1
        fi
    fi

    if [[ ! -d "$workspace_dir" ]]; then
        echo "work-jj: workspace dir not found: $workspace_dir" >&2
        return 1
    fi

    local tab_name="$display_name"
    local layout_src="$HOME/.config/zellij/layouts/coding-jj.kdl"
    local layout_dir layout_tmp
    if [[ ! -f "$layout_src" ]]; then
        echo "work-jj: layout not found: $layout_src" >&2
        return 1
    fi
    layout_dir=$("$mktemp_bin" -d)
    layout_tmp="$layout_dir/coding-jj.kdl"
    trap '[[ -n "$layout_dir" ]] && rm -rf "$layout_dir"' RETURN
    sed "s|__TAB_NAME__|$tab_name|g" "$layout_src" > "$layout_tmp"
    if [[ -n "$ZELLIJ" ]]; then
        cd "$workspace_dir" || return
        :
        if "$zellij_bin" action new-tab --name "$tab_name" --cwd "$workspace_dir" --layout "$layout_tmp" 2>/dev/null; then
            return 0
        fi
        if "$zellij_bin" action new-tab --name "$tab_name" --cwd "$workspace_dir" 2>/dev/null; then
            return 0
        fi
        "$zellij_bin" action new-tab --name "$tab_name" >/dev/null 2>&1 || return 1
        "$zellij_bin" action write-chars "cd \"$workspace_dir\"" >/dev/null 2>&1
        "$zellij_bin" action write-chars $'\n' >/dev/null 2>&1
        return 0
    fi
    local date_tag
    date_tag=$(date +%d-%b | tr 'A-Z' 'a-z')
    local session_base="work-${date_tag}"
    local session_name="$session_base"
    if (( ${#all_sessions[@]} > 0 )); then
        local suffix=2
        while (( ${all_sessions[(I)$session_name]} )); do
            session_name="${session_base}-${suffix}"
            suffix=$((suffix + 1))
        done
    fi

    cd "$workspace_dir" || return
    :
    echo "work-jj: launching zellij with layout: $layout_tmp" >&2
    "$zellij_bin" --session "$session_name" --new-session-with-layout "$layout_tmp"
    local zj_exit=$?
    if [[ $zj_exit -ne 0 ]]; then
        echo "work-jj: zellij failed (exit $zj_exit)" >&2
        return $zj_exit
    fi
}
