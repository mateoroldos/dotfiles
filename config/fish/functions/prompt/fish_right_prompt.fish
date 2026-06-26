function fish_right_prompt --description 'Show how long the last command took, once it is worth noticing'
    test $CMD_DURATION -lt 1000
    and return

    printf '%s%s%s' (set_color brblack) (__prompt_duration $CMD_DURATION) (set_color normal)
end
