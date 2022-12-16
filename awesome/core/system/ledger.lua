
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

-- For interfacing with Ledger and interacting with Ledger files.

local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")
local config = require("config")
local core = require("helpers.core")
local ledger_dir  = config.ledger.ledger_dir
local ledger_file = config.ledger.ledger_file
local budget_file = config.ledger.budget_file

local ledger = { }
local instance = nil

---------------------------------------------------------------------

-- TODO: add error checking for improperly formatted ledger entries

--- Call Ledger command to get account balances.
function ledger:parse_account_balances()
  local cmd = "ledger -f " .. ledger_file .. " balance checking savings --no-total"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)

    local lines = core.split("\r\n", stdout)
    for i = 1, #lines do

      -- Look for lines containing "Assets" "Checking" and "Savings"
      local str_assets = string.find(lines[i], "Assets")
      local str_checking  = string.find(lines[i], "Checking")
      local str_savings = string.find(lines[i], "Savings")

      -- Remove everything except # $ . from string
      local str_stripped = string.gsub(lines[i], "[^0-9$.]", "")
      if str_assets ~= nil then
        self._private.total = str_stripped
      elseif str_checking ~= nil then
        self._private.checking = str_stripped
      elseif str_savings ~= nil then
        self._private.savings = str_stripped
      end
    end

    self:emit_signal("update::balances")

  end) -- end async
end -- end get_account_balances

--- Call Ledger command to get most recent transactions.
-- The Ledger command returns CSV.
-- @param amt The number of transactions to grab (default 10)
function ledger:parse_recent_transactions(amt)
  if not amt then amt = 20 end

  local cmd = "ledger -f " .. ledger_file .. " csv expenses reimbursements income | head -" .. amt
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local transactions = {}

    -- Iterate over lines
    for line in string.gmatch(stdout, "([^\n]+)") do

      -- Parse fields by splitting on commas
      local t = { }
      for field in string.gmatch(line, "([^,]+)") do
        field = string.gsub(field, "\"", "")
        if field ~= "" and field ~= "$" then
          table.insert(t, field)
        end
      end

      -- Now fix up the formatting and store in object
      local date = t[1]
      local pattern = "(%d%d%d%d)/(%d%d)/(%d%d)"
      local xyear, xmon, xday = date:match(pattern)
      local ts = os.time({ year = xyear, month = xmon, day = xday })
      date = os.date("%m/%d", ts) .. " "

      local title = t[2]
      local category = t[3]
      local amount = string.format("%.2f", tonumber(t[4]))

      table.insert(transactions, { date, title, category, amount })
    end

    self._private.transactions = transactions
    self:emit_signal("update::transactions")
  end)
end

--- Call Ledger command to get information on how much was spent this month
-- per category.
function ledger:parse_transactions_this_month()
  local begin = " --begin " .. os.date("%Y/%m/01") .. " "
  local format = " --balance-format '%A,%T\n'"
  local cmd = "ledger -f " .. ledger_file .. " bal" .. begin .. "--no-total" .. format
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    self._private.total_spent_this_month = 0

    local raw_entries = {}

    local lines = { }
    for str in stdout:gmatch("[^\r\n]+") do
      lines[#lines + 1] = str
    end

    -- Split on commas to extract field from line
    for i = 1, #lines do
      local t = { }
      for field in string.gmatch(lines[i], "([^,]+)") do
        field = string.gsub(field, "\"", "")
        if field ~= "" and field ~= "$" and field ~= "Assets:Checking" and field ~= "Expenses" then
          t[#t + 1] = field
        end
      end

      -- Needs to have both the category and the amount
      if #t > 1 then
        raw_entries[#raw_entries + 1] = t
      end
    end

    -- The raw output from the loop above is flawed
    -- It includes the totals for top-level categories and subcategories, but
    -- I only want top-level
    -- (try the command yourself for this code to make more sense)
    -- this is kind of ugly but idk how to get what i want directly from ledger
    local month = {}
    for i = 1, #raw_entries do

      -- Get category
      local cat = raw_entries[i][1]
      local tmp = core.split(cat, ":")

      -- Keep only the top-level category
      if #tmp >= 2 then
        local top_category = tmp[2]
        if not month[top_category] then
          -- Remove dollar sign from the amount
          local amt = string.gsub(raw_entries[i][2], "[^0-9.]", "")
          month[top_category] = tonumber(amt)
          self._private.total_spent_this_month = self._private.total_spent_this_month + amt
        end
      end
    end

    self._private.monthly_breakdown = month

    self:emit_signal("update::month")
  end)
end

--- Call Ledger command to extract information on monthly budget.
function ledger:parse_budget(month)
  local files = " -f " .. ledger_file .. " -f " .. budget_file
  local format = " budget --budget-format '%A,%T\n'"
  local begin = " --begin " .. (month or os.date("%Y/%m/01"))
  local cmd = "ledger " .. files .. begin .. format .. " --no-total"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)

    local budget_entries  = {}
    local total_spent     = 0
    local total_budgeted  = 0
    self._private.budget  = {}

    -- Iterate over lines to extract information
    local lines = core.split("\r\n", stdout)
    for i = 1, #lines do
      local fields = core.split(",", lines[i])

      -- First bit is the category
      local category
      if fields[1] ~= "Assets:Checking" and fields[1] ~= "Expenses" then
        category = string.gsub(fields[1], "Expenses:", "")
        category = string.gsub(category, ":.*", "")
      end

      -- Second bit is the amount spent 
      local amt_spent_str = fields[2] and string.gsub(fields[2], "[^0-9.]", "") or "0"
      local amt_spent = tonumber(amt_spent_str) or 0

      -- Third bit is the amount budgeted
      local amt_budgeted_str = fields[3] and string.gsub(fields[3], "[^0-9.]", "") or "0"
      local amt_budgeted = tonumber(amt_budgeted_str) or 0


      if category and amt_spent and amt_budgeted then
        if not budget_entries[category] then
          budget_entries[category] = {}
          budget_entries[category][1] = amt_spent
          budget_entries[category][2] = amt_budgeted
          total_spent = total_spent + amt_spent
          total_budgeted = total_budgeted + total_budgeted
        end
      end
    end

    self._private.budget = budget_entries
    self._private.budget_total_spent    = total_spent
    self._private.budget_total_budgeted = total_budgeted
    self:emit_signal("update::budget")
  end)
end

--- Open Ledger files in new popup window.
function ledger:open_ledger()
  local cmd = "kitty sh -c 'nvim -p " .. ledger_dir .. "*'"
  -- awesome.emit_signal("dash::toggle")
  awful.spawn(cmd, {
    floating = true,
    geometry = {x=360, y=90, height=900, width=1200},
    placement = awful.placement.centered,
  })
end

---------------------------------------------------------------------

--- Return budget information.
-- @return A table containing budget information. Index into it with category name.
-- budget[cat][1] is the amount spent.
-- budget[cat][2] is the amount budgeted.
function ledger:get_budget()
  return self._private.budget
end

function ledger:get_budget_total_spent()
  return self._private.budget_total_spent
end

function ledger:get_budget_total_budgeted()
  return self._private.budget_total_budgeted
end

--- Return a given account balance.
-- @param account A string "checking" "savings" or "total"
-- @return Current balance in the account
function ledger:get_account_balance(account)
  if account == "checking" then
    return self._private.checking
  elseif account == "savings" then
    return self._private.savings
  elseif account == "total" then
    return self._private.total
  end
end

--- Get table of transactions.
function ledger:get_transactions()
  return self._private.transactions
end

--- Get overview of monthly spending.
-- @return A key-value table containing a top-level spending category and the amount spent on that category
function ledger:get_monthly_overview()
  return self._private.monthly_breakdown
end

--- Get total spent this month.
function ledger:get_total_spent_this_month()
  return self._private.total_spent_this_month
end

---------------------------------------------------------------------

function ledger:new()
  self:parse_account_balances()
  self:parse_recent_transactions()
  self:parse_transactions_this_month()
  self:parse_budget()
end

function ledger:reload()
  self:parse_account_balances()
  self:parse_recent_transactions()
  self:parse_transactions_this_month()
  self:parse_budget()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, ledger, true)
  ret._private = {}
  ret:new()
  return ret
end

if not instance then
  instance = new()
end

return instance
