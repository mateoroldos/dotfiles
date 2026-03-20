#!/usr/bin/env bash

_work_session_name() {
    local project_dir="$1"
    local project_name="$2"
    local override_name="$3"
    local branch_name=""
    if [[ -n "$override_name" ]]; then
        branch_name="$override_name"
    elif [[ -d "$project_dir/.jj" ]]; then
        local jj_bin
        jj_bin=$(command -v jj 2>/dev/null)
        if [[ -n "$jj_bin" ]]; then
            local ws_line
            ws_line=$(cd "$project_dir" && "$jj_bin" workspace list 2>/dev/null | sed -n 's/^\* \([^:]*\):.*/\1/p' | head -n 1)
            if [[ -n "$ws_line" ]]; then
                branch_name="$ws_line"
            else
                branch_name="default"
            fi
        fi
    fi
    if [[ -z "$branch_name" ]]; then
        local git_bin
        git_bin=$(command -v git 2>/dev/null)
        if [[ -n "$git_bin" && -d "$project_dir/.git" ]]; then
            branch_name=$("$git_bin" -C "$project_dir" rev-parse --abbrev-ref HEAD 2>/dev/null || true)
            if [[ -z "$branch_name" || "$branch_name" == "HEAD" ]]; then
                branch_name=$("$git_bin" -C "$project_dir" rev-parse --short HEAD 2>/dev/null || true)
            fi
        fi
    fi
    if [[ -z "$branch_name" ]]; then
        branch_name="default"
    fi
    local raw_name="${project_name}-${branch_name}"
    raw_name=${raw_name//\//-}
    raw_name=${raw_name// /-}
    raw_name=$(printf "%s" "$raw_name" | sed 's/-\{2,\}/-/g; s/^-//; s/-$//')
    printf "%s" "$raw_name"
}

_work_collect_sessions() {
    declare -gA _WORK_SESSION_STATUS
    _WORK_SESSION_STATUS=()
    local zellij_bin
    zellij_bin=$(command -v zellij 2>/dev/null)
    if [[ -z "$zellij_bin" ]]; then
        return 0
    fi
    local line name session_status
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        line=$(printf "%s" "$line" | sed $'s/\x1b\[[0-9;]*m//g')
        name="${line%% *}"
        if [[ "$line" == *"(EXITED"* ]]; then
            session_status="EXITED"
        else
            session_status="ACTIVE"
        fi
        _WORK_SESSION_STATUS[$name]="$session_status"
    done <<< "$("$zellij_bin" list-sessions 2>/dev/null)"
}

_work_project_list() {
    _work_collect_sessions
    local candidate project_dir project_name session_name session_status display status_icon
    while IFS= read -r candidate; do
        project_dir=~/Projects/"$candidate"
        project_name="${project_dir##*/}"
        session_name=$(_work_session_name "$project_dir" "$project_name")
        session_status="${_WORK_SESSION_STATUS[$session_name]}"
        if [[ -z "$session_status" ]]; then
            session_status="NONE"
        fi
        case "$session_status" in
            ACTIVE) status_icon="" ;;
            EXITED) status_icon="" ;;
            *) status_icon="" ;;
        esac
        display="${candidate} ${status_icon}"
        printf "%s\t%s\t%s\t%s\n" "$display" "$project_dir" "$session_name" "$session_status"
    done < <(find ~/Projects -mindepth 2 -maxdepth 2 -type d | sed 's|.*/Projects/||' | sort)
    local dotfiles_dir=~/dotfiles
    local dotfiles_name="${dotfiles_dir##*/}"
    local dotfiles_session
    local dotfiles_status
    local dotfiles_icon
    dotfiles_session=$(_work_session_name "$dotfiles_dir" "$dotfiles_name")
    dotfiles_status="${_WORK_SESSION_STATUS[$dotfiles_session]}"
    if [[ -z "$dotfiles_status" ]]; then
        dotfiles_status="NONE"
    fi
    case "$dotfiles_status" in
        ACTIVE) dotfiles_icon="" ;;
        EXITED) dotfiles_icon="" ;;
        *) dotfiles_icon="" ;;
    esac
    printf "%s\t%s\t%s\t%s\n" "dotfiles ${dotfiles_icon}" "$dotfiles_dir" "$dotfiles_session" "$dotfiles_status"
}

_work_task_list() {
    local project_dir="$1"
    local project="$2"
    local project_base="$3"
    _work_collect_sessions
    local jj_bin
    jj_bin=$(command -v jj 2>/dev/null)
    if [[ -z "$jj_bin" ]]; then
        return 1
    fi
    local ws_lines
    local -a ws_names
    ws_lines=$(cd "$project_dir" && "$jj_bin" workspace list 2>/dev/null)
    if [[ -n "$ws_lines" ]]; then
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local name="${line%%:*}"
            name="${name#\* }"
            [[ -z "$name" || "$name" == "$line" ]] && continue
            ws_names+=("$name")
        done <<< "$ws_lines"
    fi
    local name display session_name session_status status_icon
    for name in "${ws_names[@]}"; do
        display="$name"
        if [[ "$name" == "$project/"* ]]; then
            display="${project}/${name##*/}"
        elif [[ "$name" != "default" ]]; then
            display="${project}/${name}"
        fi
        session_name=$(_work_session_name "$project_dir" "$project_base" "$name")
        session_status="${_WORK_SESSION_STATUS[$session_name]}"
        if [[ -z "$session_status" ]]; then
            session_status="NONE"
        fi
        case "$session_status" in
            ACTIVE) status_icon="" ;;
            EXITED) status_icon="" ;;
            *) status_icon="" ;;
        esac
        printf "%s\t%s\t%s\t%s\n" "${display} ${status_icon}" "$name" "$session_name" "$session_status"
    done
    printf "%s\t%s\t%s\t%s\n" "NEW TASK " "__NEW__" "-" "NONE"
}

_work_new_workspace() {
    local project_dir="$1"
    if [[ -z "$project_dir" ]]; then
        return 1
    fi
    if [[ ! -d "$project_dir/.jj" ]]; then
        echo "work: not a jj repo: $project_dir" >&2
        return 1
    fi
    local jj_bin
    jj_bin=$(command -v jj 2>/dev/null)
    if [[ -z "$jj_bin" ]]; then
        echo "work: jj not found in PATH" >&2
        return 1
    fi
    local zellij_bin
    zellij_bin=$(command -v zellij 2>/dev/null)
    if [[ -z "$zellij_bin" ]]; then
        echo "work: zellij not found in PATH" >&2
        return 1
    fi
    local project_name
    project_name="${project_dir##*/}"
    local workspace_name
    read -r -p "Workspace name: " workspace_name
    if [[ -z "$workspace_name" ]]; then
        return 0
    fi
    local workspace_dir
    workspace_dir="${project_dir%/*}/${project_name}@${workspace_name}"
    (cd "$project_dir" && "$jj_bin" workspace add --name "$workspace_name" "$workspace_dir") || return 1
    local session_name
    session_name=$(_work_session_name "$workspace_dir" "$project_name" "$workspace_name")
    _work_collect_sessions
    local session_status
    session_status="${_WORK_SESSION_STATUS[$session_name]}"
    if [[ "$session_status" == "ACTIVE" ]]; then
        echo "work: session already active: $session_name" >&2
        return 1
    fi
    if [[ "$session_status" == "EXITED" ]]; then
        echo "work: resurrecting session: $session_name" >&2
        "$zellij_bin" attach "$session_name"
        return $?
    fi
    cd "$workspace_dir" || return 1
    "$zellij_bin" --session "$session_name" --new-session-with-layout coding
}

_work_delete_workspace() {
    local project_dir="$1"
    if [[ -z "$project_dir" ]]; then
        return 1
    fi
    if [[ ! -d "$project_dir/.jj" ]]; then
        echo "work: not a jj repo: $project_dir" >&2
        return 1
    fi
    local jj_bin
    jj_bin=$(command -v jj 2>/dev/null)
    if [[ -z "$jj_bin" ]]; then
        echo "work: jj not found in PATH" >&2
        return 1
    fi
    local fzf_bin
    fzf_bin=$(command -v fzf 2>/dev/null)
    if [[ -z "$fzf_bin" ]]; then
        echo "work: fzf not found in PATH" >&2
        return 1
    fi
    local zellij_bin
    zellij_bin=$(command -v zellij 2>/dev/null)
    if [[ -z "$zellij_bin" ]]; then
        echo "work: zellij not found in PATH" >&2
        return 1
    fi
    local project_name
    project_name="${project_dir##*/}"
    local ws_lines
    local -a ws_names
    ws_lines=$(cd "$project_dir" && "$jj_bin" workspace list 2>/dev/null)
    if [[ -n "$ws_lines" ]]; then
        while IFS= read -r line; do
            [[ -z "$line" ]] && continue
            local name="${line%%:*}"
            name="${name#\* }"
            [[ -z "$name" || "$name" == "$line" ]] && continue
            ws_names+=("$name")
        done <<< "$ws_lines"
    fi
    if (( ${#ws_names[@]} == 0 )); then
        echo "work: no workspaces found" >&2
        return 1
    fi
    local workspace_name
    workspace_name=$(printf "%s\n" "${ws_names[@]}" | "$fzf_bin" --prompt="Select Workspace: " --height=40% --reverse)
    if [[ -z "$workspace_name" ]]; then
        return 0
    fi
    if [[ "$workspace_name" == "default" ]]; then
        echo "work: refusing to delete default workspace" >&2
        return 1
    fi
    local confirm_delete
    read -r -p "Type delete to confirm: " confirm_delete
    if [[ "$confirm_delete" != "delete" ]]; then
        echo "work: delete cancelled" >&2
        return 1
    fi
    local project_parent
    project_parent="${project_dir%/*}"
    local base_project_name
    if [[ "$project_name" == *"@${workspace_name}" ]]; then
        base_project_name="${project_name%@${workspace_name}}"
    else
        base_project_name="$project_name"
    fi
    local workspace_dir
    if [[ "$workspace_name" == "${base_project_name}@"* ]]; then
        workspace_dir="$project_parent/${workspace_name}"
    else
        workspace_dir="$project_parent/${base_project_name}@${workspace_name}"
    fi
    (cd "$project_dir" && "$jj_bin" workspace forget "$workspace_name") || return 1
    if [[ -d "$workspace_dir" ]]; then
        rm -rf "$workspace_dir" || return 1
        return 0
    fi
    local legacy_dir
    legacy_dir="$project_parent/${base_project_name}-${workspace_name}"
    if [[ -d "$legacy_dir" ]]; then
        rm -rf "$legacy_dir" || return 1
        return 0
    fi
    echo "work: workspace dir not found: $workspace_dir" >&2
    return 1
    local session_name
    session_name=$(_work_session_name "$workspace_dir" "$project_name" "$workspace_name")
    _work_collect_sessions
    local session_status
    session_status="${_WORK_SESSION_STATUS[$session_name]}"
    if [[ -n "$session_status" ]]; then
        if [[ "$session_status" == "ACTIVE" ]]; then
            "$zellij_bin" delete-session "$session_name" >/dev/null 2>&1 || true
        elif [[ "$session_status" == "EXITED" ]]; then
            "$zellij_bin" delete-session "$session_name" >/dev/null 2>&1 || true
        fi
    fi
}

work() {
    local selection
    local header_text
    header_text=""
    selection=$(_work_project_list | fzf --prompt="Select Project: " --height=40% --reverse --delimiter=$'\t' --with-nth=1 --ansi --expect=alt-enter,alt-d \
        --header="$header_text" \
        --preview "printf \"Work Zellij Session\\n\\n active    exited    none/new\\n\\nRepo: %s\\n\\n\\033[33mEnter: open or create session\\nAlt-Enter: create workspace\\nAlt-D: delete workspace\\nDel: delete exited session\\033[0m\\n\" {2}" \
        --preview-window=right:45%:wrap \
        --bind "del:execute-silent(sh -c 'if [ \"{4}\" = \"EXITED\" ]; then zellij delete-session \"{3}\"; fi')+reload(bash -lc 'source ~/.bash/work.sh; _work_project_list')")

    if [[ -n "$selection" ]]; then
        local key selection_line
        local project_dir project_name session_name session_status zellij_bin
        local display
        key="${selection%%$'\n'*}"
        selection_line="${selection#*$'\n'}"
        if [[ "$key" == "$selection" ]]; then
            key=""
            selection_line="$selection"
        fi
        IFS=$'\t' read -r display project_dir session_name session_status <<< "$selection_line"
        if [[ "$key" == "alt-enter" ]]; then
            _work_new_workspace "$project_dir"
            return $?
        fi
        if [[ "$key" == "alt-d" ]]; then
            _work_delete_workspace "$project_dir"
            return $?
        fi
        project_name="${project_dir##*/}"
        cd "$project_dir" || return
        _work_collect_sessions
        session_status="${_WORK_SESSION_STATUS[$session_name]}"
        zellij_bin=$(command -v zellij 2>/dev/null)
        if [[ -z "$zellij_bin" ]]; then
            return 1
        fi
        if [[ "$session_status" == "ACTIVE" ]]; then
            echo "work: session already active: $session_name" >&2
            return 1
        fi
        if [[ "$session_status" == "EXITED" ]]; then
            echo "work: resurrecting session: $session_name" >&2
            "$zellij_bin" attach "$session_name"
            return $?
        fi
        "$zellij_bin" --session "$session_name" --new-session-with-layout coding
    fi
}
