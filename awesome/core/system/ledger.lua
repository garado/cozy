
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

-- Object for interfacing with Ledger and interacting with Ledger files.

local gobject = require("gears.object")
local gtable = require("gears.table")
local awful = require("awful")
local config = require("config")
local ledger_file = config.ledger.ledger_file

local ledger = { }
local instance = nil

-- TODO: add error checking for improperly formatted ledger entries

--- Call Ledger command to get account balances.
function ledger:parse_account_balances()
  local cmd = "ledger -f " .. ledger_file .. " balance checking savings"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)

    -- Split output into lines
    for str in string.gmatch(stdout, "([^\n]+)") do

      -- Look for lines containing "Assets" "Checking" and "Savings"
      local str_assets = string.find(str, "Assets")
      local str_checking  = string.find(str, "Checking")
      local str_savings = string.find(str, "Savings")

      -- Remove everything except # $ . from string
      local str_stripped = string.gsub(str, "[^0-9$.]", "")
      if str_assets ~= nil then
        self._private.total = str_stripped
      elseif str_checking ~= nil then
        self._private.checking = str_stripped
      elseif str_savings ~= nil then
        self._private.savings = str_stripped
      end

    end -- end iter lines

    self:emit_signal("update::balances")

  end) -- end async
end -- end get_account_balances

--- Call Ledger command to get most recent transactions.
-- The Ledger command returns CSV.
-- @param amt The number of transactions to grab (default 10)
function ledger:parse_recent_transactions(amt)
  if not amt then amt = 10 end

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

      -- tmp is tokenized string (split on colons)
      local tmp = {}
      for j in string.gmatch(cat, "[^:]+") do
        tmp[#tmp + 1] = j
      end

      -- Keep only the top-level category
      if #tmp >= 2 then
        local top_category = tmp[2]
        if not month[top_category] then
          -- Need to remove dollar sign from the amount
          local amt = string.gsub(raw_entries[i][2], "[^0-9.]", "")
          month[top_category] = amt
          self._private.total_spent_this_month = self._private.total_spent_this_month + amt
        end
      end
    end

    self._private.monthly_breakdown = month

    self:emit_signal("update::month")
  end)
end

---------------------------------------------------------------------

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
