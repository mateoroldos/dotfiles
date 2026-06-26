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

  config.action("gh.pr", function()
    local change_id = context.change_id()
    if not change_id or change_id == "" then
      flash({ text = "No revision selected", error = true })
      return
    end

    local out, err = jj("log", "-r", change_id, "--no-graph",
      "-T", 'local_bookmarks.map(|b| b.name()).join("\\n")')
    if err then
      flash({ text = err, error = true })
      return
    end

    local bookmarks = split_lines(out)
    if #bookmarks == 0 then
      flash({ text = "No bookmark on this revision (b to create one)", error = true })
      return
    end

    local bookmark = bookmarks[1]
    if #bookmarks > 1 then
      bookmark = choose({ title = "Open PR for", options = bookmarks })
      if not bookmark then
        return
      end
    end

    local quoted = shell_quote(bookmark)
    exec_shell("jj git push -b " .. quoted
      .. "; and begin; gh pr view " .. quoted .. " --web; or gh pr create --web --head " .. quoted .. "; end")
  end, {
    key = "alt+p",
    scope = "revisions",
    desc = "open/create PR",
  })
end
