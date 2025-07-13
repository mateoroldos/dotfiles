local luasnip = require("luasnip")
local s = luasnip.snippet
local t = luasnip.text_node
local i = luasnip.insert_node
local c = luasnip.choice_node
local f = luasnip.function_node

-- Use the current filename (without .md) as heading
local function filename_heading()
  local filename = vim.fn.expand("%:t:r") -- Get filename without extension
  if filename == "" then
    return "# " .. os.date("%Y-%m-%d") -- Fallback to date if no filename
  end
  return "# " .. filename
end

-- Get day-specific transitas
local function get_transitas()
  local day = os.date("%A")
  local transitas = {
    Monday = {
      "",
      "- [ ]",
    },
    Tuesday = {
      "",
      "- [ ]",
    },
    Wednesday = {
      "",
      "- [ ]",
    },
    Thursday = {
      "",
      "- [ ]",
    },
    Friday = {
      "",
      "- [ ]",
    },
  }

  -- Return a table of strings for LuaSnip
  return transitas[day] or { "", "- [ ] " }
end

-- Daily template snippet with day-dependent transitas
luasnip.add_snippets("all", {
  s("daily", {
    -- Header with current date
    f(filename_heading),
    t({ "", "", "" }),
    -- Morning Reset
    t({
      "🌅 **Morning Reset**",
      '"Work in public, teach everything you know, create everyday"',
      "",
      "1. **Inspire**",
      "- [ ] Review book notes",
      "- [ ] 20 min of course / reading",
      "",
      "2. **Clear** (5 min max)",
      "- [ ] WhatsApp 0",
      "- [ ] Email 0",
      "- [ ] Discord 0",
      "",
      "3. **Plan**",
      "- [ ] Review yesterday's unfinished tasks",
      "- [ ] Check calendar for meeting deadlines",
      "- [ ] Set the focus for the two blocks",
      "- [ ] Set the transa for today",
      "",
      "💼 **Today's Focus**",
      "",
      "**Client Communications:**",
      "- [ ] ",
    }),
    i(1),
    t({ "", "- [ ] " }),
    i(2),
    t({ "", "", "**Block 1:**", "- [ ] " }),
    i(3),
    t({ "", "", "**Lunch**", "", "**Transitas:**" }),
    f(get_transitas),
    t({ "", "", "**Quick Wins** (After lunch):", "- [ ] " }),
    i(4),
    t({ "", "- [ ] " }),
    i(5),
    t({ "", "", "**Block 2:**", "- [ ] " }),
    i(6),
    t({
      "",
      "",
      "🌙 **Evening Reset**",
      "",
      "1. **Clear**",
      "- [ ] Review what got accomplished in each block",
      "- [ ] Note any blockers or issues",
      "- [ ] Clear house",
    }),
    -- Add weekly reflection for Friday
    c(7, {
      t(""),
      t({ "", "- [ ] **Weekly reflection:** What went well? What to improve?" }),
    }),
    t({ "", "", "2. **Inspire**", "- [ ] Read 30 min" }),
  }),
})

-- Alternative snippet with empty transitas
luasnip.add_snippets("all", {
  s("dailyempty", {
    -- Header with current date
    f(filename_heading),
    t({ "", "", "" }),
    -- Morning Reset
    t({
      "🌅 **Morning Reset**",
      '"Work in public, teach everything you know, create everyday"',
      "",
      "1. **Inspire**",
      "- [ ] Review book notes",
      "- [ ] Review RSS and Instapaper",
      "- [ ] 20 min of course / reading",
      "",
      "2. **Clear** (5 min max)",
      "- [ ] WhatsApp 0",
      "- [ ] Email 0",
      "- [ ] Discord 0",
      "",
      "3. **Plan**",
      "- [ ] Review yesterday's unfinished tasks",
      "- [ ] Check calendar for meeting deadlines",
      "- [ ] Set the focus for the two blocks",
      "",
      "💼 **Today's Focus**",
      "",
      "**Client Communications:**",
      "- [ ] ",
    }),
    i(1),
    t({ "", "- [ ] " }),
    i(2),
    t({ "", "", "**Block 1:**", "- [ ] " }),
    i(3),
    t({ "", "", "**Lunch**", "", "**Transitas:**", "- [ ] " }),
    i(4),
    t({ "", "- [ ] " }),
    i(5),
    t({ "", "", "**Quick Wins** (After lunch):", "- [ ] " }),
    i(6),
    t({ "", "- [ ] " }),
    i(7),
    t({ "", "", "**Block 2:**", "- [ ] " }),
    i(8),
    t({
      "",
      "",
      "🌙 **Evening Reset**",
      "",
      "1. **Clear**",
      "- [ ] Review what got accomplished in each block",
      "- [ ] Note any blockers or issues",
      "- [ ] Clear house",
      "",
      "2. **Inspire**",
      "- [ ] Read 30 min",
    }),
  }),
})
