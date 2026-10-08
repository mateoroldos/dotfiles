local function shell_quote(value)
  return string.format("%q", value)
end

local function join(values, separator)
  local result = ""
  for index, value in ipairs(values) do
    if index > 1 then
      result = result .. separator
    end
    result = result .. value
  end
  return result
end

local function selected_or_current_revset()
  local selected = context.checked_change_ids()
  if #selected > 0 then
    return join(selected, "|")
  end

  local change_id = context.change_id()
  if not change_id or change_id == "" then
    return nil
  end

  return change_id
end

local function open_tuicr_for_revset(path)
  local revset = selected_or_current_revset()
  if not revset then
    flash({ text = "No revision selected", error = true })
    return
  end

  local command = "tuicr -r " .. shell_quote(revset)
  if path and path ~= "" then
    command = command .. " --path " .. shell_quote(path)
  end

  exec_shell(command)
end

-- gh runs through `jj util exec` so jjui can run it in the background.
local function gh(...)
  jj_async("util", "exec", "--", "gh", ...)
end

-- Bookmarks on this revision or stacked above it, nearest first.
local function stack_bookmarks(change_id)
  local out = jj("log", "-r", "(" .. change_id .. ":: & bookmarks()) ~ ::trunk()",
    "--no-graph", "--reversed",
    "-T", 'local_bookmarks.map(|b| b.name() ++ "\\n").join("")')
  return split_lines(out or "")
end

-- The given bookmarks that exist on a remote, as a set.
local function pushed_bookmarks(bookmarks)
  local pushed = {}
  if #bookmarks == 0 then
    return pushed
  end

  local args = { "bookmark", "list", "--all-remotes", "-T", 'if(remote, remote ++ " " ++ name ++ "\\n")' }
  for _, bookmark in ipairs(bookmarks) do
    table.insert(args, "exact:" .. bookmark)
  end

  local out = jj(args)
  for _, line in ipairs(split_lines(out or "")) do
    local remote, name = line:match("^(%S+) (%S+)$")
    if remote and remote ~= "git" then
      pushed[name] = true
    end
  end

  return pushed
end

-- Open PRs keyed by head branch.
local function open_prs()
  local out = jj("util", "exec", "--", "gh", "pr", "list", "--state", "open", "-L", "200",
    "--json", "headRefName,number,url", "-q", '.[] | "\\(.headRefName) \\(.number) \\(.url)"')

  local prs = {}
  for _, line in ipairs(split_lines(out or "")) do
    local branch, number, url = line:match("^(%S+) (%S+) (%S+)$")
    if branch then
      prs[branch] = { number = number, url = url }
    end
  end

  return prs
end

-- The revision's full commit ID if a remote bookmark contains it.
local function pushed_commit(change_id)
  local out = jj("log", "-r", change_id .. " & ::remote_bookmarks()", "--no-graph", "-T", "commit_id")
  if not out or out == "" then
    return nil
  end

  return out
end

local function github_items(change_id)
  local items = {}
  local bookmarks = stack_bookmarks(change_id)
  local pushed = pushed_bookmarks(bookmarks)
  local prs = next(pushed) and open_prs() or {}

  for _, bookmark in ipairs(bookmarks) do
    local pr = prs[bookmark]
    if pr then
      table.insert(items, {
        label = "Open PR #" .. pr.number .. " · " .. bookmark,
        run = function()
          gh("pr", "view", pr.number, "--web")
        end,
      })
      table.insert(items, {
        label = "Copy PR URL · " .. bookmark,
        run = function()
          copy_to_clipboard(pr.url)
          flash("Copied: " .. pr.url)
        end,
      })
    else
      table.insert(items, {
        label = "Create PR · " .. bookmark,
        run = function()
          jj_async("git", "push", "-b", bookmark)
          gh("pr", "create", "--web", "--head", bookmark)
        end,
      })
    end

    if pushed[bookmark] then
      table.insert(items, {
        label = "Browse branch · " .. bookmark,
        run = function()
          gh("browse", "-b", bookmark)
        end,
      })
    end
  end

  local commit_id = pushed_commit(change_id)
  if commit_id then
    table.insert(items, {
      label = "Browse commit · " .. commit_id:sub(1, 8),
      run = function()
        gh("browse", commit_id)
      end,
    })
  end

  table.insert(items, {
    label = "Open repo",
    run = function()
      gh("browse")
    end,
  })

  return items
end

function setup(config)
  config.action("tuicr.open-revisions", function()
    open_tuicr_for_revset(nil)
  end, {
    key = "t",
    scope = "revisions",
    desc = "tuicr",
  })

  config.action("tuicr.open-file", function()
    local file = context.file()
    if not file or file == "" then
      flash({ text = "No file selected", error = true })
      return
    end

    open_tuicr_for_revset(file)
  end, {
    key = "t",
    scope = "revisions.details",
    desc = "tuicr file",
  })

  config.action("tuicr.open-working-copy", function()
    exec_shell("tuicr -w")
  end, {
    key = "alt+w",
    scope = "revisions",
    desc = "tuicr working copy",
  })

  config.action("gh.menu", function()
    local change_id = context.change_id()
    if not change_id or change_id == "" then
      flash({ text = "No revision selected", error = true })
      return
    end

    local items = github_items(change_id)

    -- choose() sizes the popup to its longest label, so pad them.
    local labels = {}
    for index, item in ipairs(items) do
      labels[index] = string.format("%-48s", item.label)
    end

    local choice = choose({ title = "GitHub", options = labels })
    for index, label in ipairs(labels) do
      if label == choice then
        items[index].run()
      end
    end
  end, {
    key = "shift+h",
    scope = "revisions",
    desc = "github",
  })
end
