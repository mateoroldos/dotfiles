export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# LOAD NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# RUN NEOFETCH ON TERMINAL OPEN
neofetch

# WORK COMMAND CRATES ZELLIK SESSION WITH NVIM
work() {
  local session_name=$(basename "$PWD")
  local session_exists=$(zellij list-sessions | grep -w "$session_name")

  if [[ -z "$session_exists" ]]; then
    echo "Session '$session_name' does not exist. Creating a new session..."
    zellij --layout coding attach --create "$session_name"
  else
    echo "Session '$session_name' already exists."
  fi
}

# LIST ALL TODOS INSIDE TODO.md FILES INSIDE MY PROJECTS
todos() {
  local projects_dir="$HOME/Projects"
  local found_todos=false
  local mode="incomplete"  # default mode
  
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case $1 in
      --all|-A)
        mode="all"
        shift
        ;;
      --done|-D)
        mode="done"
        shift
        ;;
      *)
        echo "Unknown option: $1"
        echo "Usage: todos [--all|-A] [--done|-D]"
        return 1
        ;;
    esac
  done
  
  # Check if Projects directory exists
  if [[ ! -d "$projects_dir" ]]; then
    echo "Error: ~/Projects directory not found"
    return 1
  fi
  
  case $mode in
    "incomplete")
      echo "🔍 Scanning for incomplete TODOs in ~/Projects/..."
      ;;
    "done")
      echo "✅ Scanning for completed TODOs in ~/Projects/..."
      ;;
    "all")
      echo "📋 Scanning for all TODOs in ~/Projects/..."
      ;;
  esac
  
  # Loop through all client directories in ~/Projects
  for client_dir in "$projects_dir"/*; do
    if [[ -d "$client_dir" ]]; then
      local client_name=$(basename "$client_dir")
      
      # Loop through all repo directories within each client
      for repo_dir in "$client_dir"/*; do
        if [[ -d "$repo_dir" ]]; then
          local repo_name=$(basename "$repo_dir")
          local todo_file="$repo_dir/TODO.md"
          
          # Check if TODO.md exists in this repo
          if [[ -f "$todo_file" ]]; then
            echo "📁 Client: $client_name | Repo: $repo_name"
        
            case $mode in
              "incomplete")
                # Find incomplete todos (lines starting with - [ ] or * [ ])
                local todos_found=$(grep -n "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "$todo_file")
                
                if [[ -n "$todos_found" ]]; then
                  found_todos=true
                  echo "$todos_found" | while IFS=: read -r line_num todo_text; do
                    local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\][[:space:]]*//')
                    echo "  ☐ $clean_todo"
                  done
                else
                  echo "  ✅ No incomplete TODOs found"
                fi
                ;;
                
              "done")
                # Find completed todos (lines starting with - [x] or * [x])
                local todos_found=$(grep -n "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "$todo_file")
                
                if [[ -n "$todos_found" ]]; then
                  found_todos=true
                  echo "$todos_found" | while IFS=: read -r line_num todo_text; do
                    local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[xX]\][[:space:]]*//')
                    echo "  ✓ $clean_todo"
                  done
                else
                  echo "  ☐ No completed TODOs found"
                fi
                ;;
                
              "all")
                # Find all todos (both completed and incomplete)
                local todos_found=$(grep -n "^[[:space:]]*[-*][[:space:]]*\[" "$todo_file")
                
                if [[ -n "$todos_found" ]]; then
                  found_todos=true
                  echo "$todos_found" | while IFS=: read -r line_num todo_text; do
                    if [[ "$todo_text" =~ \[[xX]\] ]]; then
                      # Completed todo
                      local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[xX]\][[:space:]]*//')
                      echo "  ✓ $clean_todo"
                    else
                      # Incomplete todo
                      local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\][[:space:]]*//')
                      echo "  ☐ $clean_todo"
                    fi
                  done
                else
                  echo "  📝 No TODOs found"
                fi
                ;;
            esac
            echo
          fi
        fi
      done
    fi
  done
  
  case $mode in
    "incomplete")
      if [[ "$found_todos" == false ]]; then
        echo "🎉 No incomplete TODOs found in any projects!"
      fi
      ;;
    "done")
      if [[ "$found_todos" == false ]]; then
        echo "📝 No completed TODOs found in any projects!"
      fi
      ;;
    "all")
      if [[ "$found_todos" == false ]]; then
        echo "📝 No TODOs found in any projects!"
      fi
      ;;
  esac
}

# MAKES A LIST OF ALL CLIENTS AND IT'S REPOS
clients() {
  local projects_dir="$HOME/Projects"
  
  # Check if Projects directory exists
  if [[ ! -d "$projects_dir" ]]; then
    echo "Error: ~/Projects directory not found"
    return 1
  fi
  
  echo "🏢 Clients and their repositories:"
  echo "=" | tr '=' '=' | head -c 40; echo
  
  local total_clients=0
  local total_repos=0
  
  # Loop through all client directories in ~/Projects
  for client_dir in "$projects_dir"/*; do
    if [[ -d "$client_dir" ]]; then
      local client_name=$(basename "$client_dir")
      echo "📊 Client: $client_name"
      
      local client_repos=0
      
      # Loop through all repo directories within each client
      for repo_dir in "$client_dir"/*; do
        if [[ -d "$repo_dir" ]]; then
          local repo_name=$(basename "$repo_dir")
          local todo_file="$repo_dir/TODO.md"
          
          # Check if TODO.md exists and count todos
          if [[ -f "$todo_file" ]]; then
            local incomplete_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "$todo_file" 2>/dev/null)
            local completed_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "$todo_file" 2>/dev/null)
            
            # Ensure counts are numbers (default to 0 if empty)
            incomplete_count=${incomplete_count:-0}
            completed_count=${completed_count:-0}
            
            local total_count=$((incomplete_count + completed_count))
            
            if [[ $total_count -gt 0 ]]; then
              echo "  └── 📁 $repo_name (TODOs: $incomplete_count pending, $completed_count done)"
            else
              echo "  └── 📁 $repo_name (No TODO.md or no TODOs)"
            fi
          else
            echo "  └── 📁 $repo_name (No TODO.md)"
          fi
          
          client_repos=$((client_repos + 1))
          total_repos=$((total_repos + 1))
        fi
      done
      
      echo "  └── Total repositories: $client_repos"
      echo
      total_clients=$((total_clients + 1))
    fi
  done
  
  echo "📊 Summary:"
  echo "  Total clients: $total_clients"
  echo "  Total repositories: $total_repos"
}
