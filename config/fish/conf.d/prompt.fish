# Fish autoloads functions from $fish_function_path but does not recurse into
# subdirectories, so functions/prompt/ has to be registered as its own entry.
# Prepend: it must outrank the fish_prompt fish ships in /usr/share/fish/functions.

contains -- $__fish_config_dir/functions/prompt $fish_function_path
or set -p fish_function_path $__fish_config_dir/functions/prompt
