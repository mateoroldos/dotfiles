function fish_prompt --description 'Show a two-line prompt: path, vcs state, exit status'
    set -l last_status $status

    if set -q SSH_TTY; or fish_is_root_user
        printf '%s%s%s ' (set_color $fish_color_user) (prompt_login) (set_color normal)
    end

    __prompt_pwd
    fish_vcs_prompt

    test $last_status -ne 0
    and printf ' %s%s%s' (set_color $fish_color_error) $last_status (set_color normal)

    printf '\n%s❯%s ' (set_color --bold brblack) (set_color normal)
end
