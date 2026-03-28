abbr -a jjd --set-cursor 'jj describe -m "%"'
abbr -a jjdc 'jj describe -m "$(koji --stdout)"'
abbr -a jjn 'jj new'
abbr -a jjs 'jj stack'
abbr -a jjl 'jj log'
abbr -a jjc 'jj commit'
abbr -a jjcc 'jj commit -m "$(koji --stdout)"'
abbr -a jj- 'jj edit @-'
abbr -a jj+ 'jj edit @+'
abbr -a jjsq 'jj squash'

abbr -a diff 'tuicr -r @'
abbr -a y yazi

abbr -a w work

abbr -a bth bluetui

abbr -a ls "eza --icons --group-directories-first"

abbr -a cat bat

abbr -a pjs "jq '.scripts' package.json"

abbr -a cl clear

abbr -a ghb 'gh browse'
abbr -a ghbi 'gh browse --issues'
abbr -a ghbp "gh browse 'pulls/'"
abbr -a ghba 'gh browse --actions'
abbr -a ghbs 'gh browse --settings'
abbr -a ghbr 'gh browse --releases'
