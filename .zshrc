export PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"
export PATH=$HOME/.local/bin:$PATH

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

alias v="nvim"

# LOAD NVM
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# RUN NEOFETCH ON TERMINAL OPEN
neofetch

# Main function to show TODOs with optional flags
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

# Function to list all clients and their repositories
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

# Enhanced work function with TODO selection
work() {
  local session_name=$(basename "$PWD")
  local session_exists=$(zellij list-sessions | grep -w "$session_name")
  local client_name=""
  local repo_name=""
  
  # Try to detect if we're in a client/repo structure
  local current_path="$PWD"
  if [[ "$current_path" == */Projects/* ]]; then
    # Extract client and repo from path like ~/Projects/ClientA/repo1
    local relative_path=${current_path#*Projects/}
    client_name=$(echo "$relative_path" | cut -d'/' -f1)
    repo_name=$(echo "$relative_path" | cut -d'/' -f2)
  fi
  
  if [[ -z "$session_exists" ]]; then
    echo "Session '$session_name' does not exist. Creating a new session..."
    
    # Show relevant TODOs and let user select one
    if [[ -f "./TODO.md" ]]; then
      echo "\n📋 Current TODOs for this project:"
      local incomplete_todos=$(grep -n "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "./TODO.md")
      
      if [[ -n "$incomplete_todos" ]]; then
        local todo_array=()
        local counter=1
        
        # Store todos in a temp array for selection and display
        local temp_todos=()
        local counter=1
        
        while IFS=: read -r line_num todo_text; do
          local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\][[:space:]]*//')
          temp_todos+=("$clean_todo")
          echo "  $counter) $clean_todo"
          counter=$((counter + 1))
        done <<< "$incomplete_todos"
        
        echo "  $counter) 🛠️  Track time for general project work"
        echo "  $((counter + 1))) ➕ Create and track a new task"
        echo "  0) ⏭️  Don't track time"
        echo
        
        echo -n "📝 Select a TODO to track time for (0-$((counter + 1))): "
        read -r todo_choice
        
        local project_tag="${client_name:+$client_name.}$repo_name"
        
        if [[ "$todo_choice" =~ ^[1-9][0-9]*$ ]] && [[ $todo_choice -le ${#temp_todos[@]} ]]; then
          # Selected a specific TODO
          local selected_todo="${temp_todos[$todo_choice]}"
          echo "⏱️  Starting time tracking for: $selected_todo"
          timew start "$project_tag" "$selected_todo" 2>/dev/null || echo "Note: timewarrior not found"
          
        elif [[ "$todo_choice" == "$counter" ]]; then
          # General project work
          echo "⏱️  Starting time tracking for general project work"
          timew start "$project_tag" "general development" 2>/dev/null || echo "Note: timewarrior not found"
          
        elif [[ "$todo_choice" == "$((counter + 1))" ]]; then
          # Create new task
          echo -n "📋 Enter description for new task: "
          read -r new_task
          if [[ -n "$new_task" ]]; then
            echo "⏱️  Starting time tracking for: $new_task"
            timew start "$project_tag" "$new_task" 2>/dev/null || echo "Note: timewarrior not found"
            
            # Optionally add to TODO.md
            echo -n "📝 Add this task to TODO.md? (y/N): "
            read -r add_todo
            if [[ "$add_todo" =~ ^[Yy]$ ]]; then
              echo "- [ ] $new_task" >> "./TODO.md"
              echo "✅ Added to TODO.md"
            fi
          fi
          
        elif [[ "$todo_choice" == "0" ]]; then
          echo "⏭️  Skipping time tracking"
        else
          echo "❌ Invalid selection, skipping time tracking"
        fi
        
      else
        echo "  ✅ No pending TODOs!"
        echo -n "\n⏱️  Start time tracking? (y/N): "
        read -r start_tracking
        if [[ "$start_tracking" =~ ^[Yy]$ ]]; then
          local project_tag="${client_name:+$client_name.}$repo_name"
          echo "Starting timewarrior tracking for: $project_tag"
          timew start "$project_tag" "general development" 2>/dev/null || echo "Note: timewarrior not found"
        fi
      fi
      echo
    else
      echo "\n📋 No TODO.md found"
      echo -n "⏱️  Start time tracking for general project work? (y/N): "
      read -r start_tracking
      if [[ "$start_tracking" =~ ^[Yy]$ ]]; then
        local project_tag="${client_name:+$client_name.}$repo_name"
        echo "Starting timewarrior tracking for: $project_tag"
        timew start "$project_tag" "general development" 2>/dev/null || echo "Note: timewarrior not found"
      fi
    fi
    
    zellij --layout coding attach --create "$session_name"
  else
    echo "Session '$session_name' already exists."
    
    # Show current time tracking status
    if command -v timew >/dev/null 2>&1; then
      local active_tracking=$(timew get dom.active 2>/dev/null)
      if [[ "$active_tracking" == "1" ]]; then
        echo "⏱️  Time tracking is currently active"
        timew summary :ids 2>/dev/null | tail -n 5
      fi
    fi
  fi
}

# Function to stop work and show summary
stop() {
  local session_name=$(basename "$PWD")
  
  # Stop time tracking if active
  if command -v timew >/dev/null 2>&1; then
    local active_tracking=$(timew get dom.active 2>/dev/null)
    if [[ "$active_tracking" == "1" ]]; then
      echo "⏹️  Stopping time tracking..."
      timew stop 2>/dev/null
      echo "\n📊 Time summary for today:"
      timew summary :day 2>/dev/null | tail -n 10
    fi
  fi
  
  # Show TODO progress
  if [[ -f "./TODO.md" ]]; then
    echo "\n📋 Current TODO status:"
    local incomplete_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "./TODO.md" 2>/dev/null)
    local completed_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "./TODO.md" 2>/dev/null)
    incomplete_count=${incomplete_count:-0}
    completed_count=${completed_count:-0}
    
    echo "  ☐ Pending: $incomplete_count"
    echo "  ✓ Completed: $completed_count"
    
    if [[ $incomplete_count -gt 0 ]]; then
      echo "\n  Remaining tasks:"
      local incomplete_todos=$(grep -n "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "./TODO.md")
      echo "$incomplete_todos" | head -n 3 | while IFS=: read -r line_num todo_text; do
        local clean_todo=$(echo "$todo_text" | sed 's/^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\][[:space:]]*//')
        echo "    ☐ $clean_todo"
      done
      [[ $(echo "$incomplete_todos" | wc -l) -gt 3 ]] && echo "    ... and $((incomplete_count - 3)) more"
    fi
  fi
  
  echo "\n👋 Work session summary complete!"
}

# Function to track time for a specific task
track() {
  local task_description="$1"
  local client_name=""
  local repo_name=""
  
  if [[ -z "$task_description" ]]; then
    echo "Usage: track 'task description'"
    echo "Example: track 'fixing authentication bug'"
    return 1
  fi
  
  # Try to detect client/repo context
  local current_path="$PWD"
  if [[ "$current_path" == */Projects/* ]]; then
    local relative_path=${current_path#*Projects/}
    client_name=$(echo "$relative_path" | cut -d'/' -f1)
    repo_name=$(echo "$relative_path" | cut -d'/' -f2)
  fi
  
  if command -v timew >/dev/null 2>&1; then
    local project_tag="${client_name:+$client_name.}$repo_name"
    echo "🕐 Starting time tracking: $task_description"
    echo "   Project: $project_tag"
    timew start "$project_tag" "$task_description" 2>/dev/null || echo "Note: timewarrior error"
  else
    echo "❌ timewarrior not found. Install with: brew install timewarrior"
  fi
}

# Function to show current tracking status
status() {
  echo "📊 Current Status:"
  echo "=================="
  
  # Show current directory context
  local current_path="$PWD"
  if [[ "$current_path" == */Projects/* ]]; then
    local relative_path=${current_path#*Projects/}
    local client_name=$(echo "$relative_path" | cut -d'/' -f1)
    local repo_name=$(echo "$relative_path" | cut -d'/' -f2)
    echo "📁 Project: $client_name/$repo_name"
  else
    echo "📁 Current directory: $(basename "$PWD")"
  fi
  
  # Show zellij session status
  local session_name=$(basename "$PWD")
  local session_exists=$(zellij list-sessions | grep -w "$session_name")
  if [[ -n "$session_exists" ]]; then
    echo "🖥️  Zellij session: Active ($session_name)"
  else
    echo "🖥️  Zellij session: Not active"
  fi
  
  # Show time tracking status
  if command -v timew >/dev/null 2>&1; then
    local active_tracking=$(timew get dom.active 2>/dev/null)
    if [[ "$active_tracking" == "1" ]]; then
      echo "⏱️  Time tracking: Active"
      timew summary :ids 2>/dev/null | tail -n 3
    else
      echo "⏱️  Time tracking: Stopped"
    fi
  else
    echo "⏱️  Time tracking: timewarrior not installed"
  fi
  
  # Show TODO summary
  if [[ -f "./TODO.md" ]]; then
    local incomplete_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[[:space:]]\]" "./TODO.md" 2>/dev/null)
    local completed_count=$(grep -c "^[[:space:]]*[-*][[:space:]]*\[[xX]\]" "./TODO.md" 2>/dev/null)
    incomplete_count=${incomplete_count:-0}
    completed_count=${completed_count:-0}
    echo "📋 TODOs: $incomplete_count pending, $completed_count completed"
  else
    echo "📋 TODOs: No TODO.md file found"
  fi
}
