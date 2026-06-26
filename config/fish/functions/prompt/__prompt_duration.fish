function __prompt_duration --description 'Format milliseconds as 1h2m3s, dropping empty units'
    set -l ms $argv[1]
    set -l out

    set -l hours (math --scale=0 "$ms / 3600000")
    set -l mins (math --scale=0 "$ms / 60000 % 60")
    set -l secs (math --scale=1 "$ms / 1000 % 60")

    test $hours -gt 0; and set -a out $hours"h"
    test $mins -gt 0; and set -a out $mins"m"
    test $secs -gt 0; and set -a out $secs"s"

    string join '' $out
end
