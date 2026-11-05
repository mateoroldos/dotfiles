function fish_prompt --description 'Show a two-line prompt: path, vcs state, exit status'
    set -l last_status $status
    set -l arrow_color --bold brblack

    # A blank line between commands, but not above the first prompt.
    set -q __prompt_shown
    and echo
    set -g __prompt_shown

    if set -q SSH_TTY; or fish_is_root_user
        printf '%s%s%s ' (set_color $fish_color_user) (prompt_login) (set_color normal)
    end

    __prompt_pwd
    # fish 4.0's fish_vcs_prompt never tries jj, so ask jj first.
    fish_jj_prompt
    or fish_git_prompt

    if test $last_status -ne 0
        printf ' %s%s%s' (set_color $fish_color_error) $last_status (set_color normal)
        set arrow_color $fish_color_error
    end

    printf '\n%s❯%s ' (set_color $arrow_color) (set_color normal)
end
