
-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█ 
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄ 

local gobject = require("gears.object")
local gtable  = require("gears.table")
local config  = require("cozyconf")
local gfs     = require("gears.filesystem")
local awful   = require("awful")
local strutil = require("utils.string")
local os      = os

local lfile = config.ledger.ledger_file
local bfile = config.ledger.budget_file
local afile = config.ledger.account_file

local ledger = {}
local instance = nil

---------------------------------------------------------------------

-- @method parse_assets
-- @brief Get asset balances: checking, savings, cash
-- Output looks like: (always in this order, I think)
--     $1718.83  Assets
--      $308.30    Cash
--      $252.93    Checking
--     $1157.60    Savings:Emergency Fund
-- TODO: More customization options - this is very specific to the way I have
-- my ledger set up
function ledger:parse_assets()
  local cmd = "ledger -f " .. lfile .. " balance checking savings cash --no-total"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local lines = strutil.split(stdout, "\r\n")
    local signal_names = { "total", "cash", "checking", "savings" }
    for i = 1, #lines do
      -- Remove all chars except numbers and decimal points
      local amount = lines[i]:gsub("[^0-9.]", "")
      local signal = "ready::" .. signal_names[i]
      self:emit_signal(signal, amount)
    end
  end)
end

-- @method parse_month_income
-- @brief Get income for the current month
function ledger:parse_month_income()
  local date = os.date("%m") .. "/01" -- Beginning of this month
  local cmd = "ledger -f " .. lfile .. " balance ^Income -b " .. date .. " | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local amount = stdout:gsub("[^0-9.]", "")
    self:emit_signal("ready::income", amount)
  end)
end

-- @method parse_month_expenses
-- @brief Get expenses for the current month
function ledger:parse_month_expenses()
  local date = os.date("%m") .. "/01" -- Beginning of this month
  local cmd = "ledger -f " .. lfile .. " balance ^Expense -b " .. date .. " | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local amount = stdout:gsub("[^0-9.]", "")
    self:emit_signal("ready::expenses", amount)
  end)
end

-- @method parse_recent_transactions
-- @brief Gets recent ledger transactions
function ledger:parse_recent_transactions()
  local cmd = "ledger -f " .. afile .. " -f " .. lfile .. " --pedantic csv | head -n 20"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Clean up the CSV so it's easier to parse
    local transactions = {}
    local lines = strutil.split(stdout, "\r\n")
    for i = 1, #lines do
      local fields = strutil.split(lines[i], ",")
      table.insert(transactions, fields)
    end

    self:emit_signal("ready::transactions", transactions)
  end)
end

--- @method get_budget
-- @brief Get budget information.
-- stdout looks something like this (no indentation):
--      Assets:Checking,($-669.86, $1160.00)
--      Expenses,($753.21, $-1160.00)
--      Expenses:Bills,($741.34, $-900.00)
--      Expenses:Education,(0, $-50.00)
--      Expenses:Food:Restaurants,($9.87, $-50.00)
-- We skip the 1st line, process the 2nd line separately as the total budget,
-- and then loop to process the rest of the budget entries.
function ledger:get_budget(month)
  month = month or os.date("%Y/%m/01")
  local files  = " -f " .. lfile .. " -f " .. bfile
  local format = " budget --budget-format '%A,%T\n'"
  local begin  = " --begin " .. month
  local cmd    = "ledger " .. files .. begin .. format .. " --no-total"

  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    print(stdout)

    local budget = {}
    local categories = strutil.split(stdout, "\r\n")

    -- TODO: Total budget

    -- Parse budget categories
    for i = 3, #categories do
      -- Split budget data string on commas: "Expenses:Education,(0, $-50.00)"
      -- 1st: category, 2nd: spent, 3rd: allocated
      local _fields = strutil.split(categories[i], ",")

      -- Now clean up the fields and put them into new array
      local fields = {}
      for j = 1, #_fields do
        local tmp, _ = _fields[j]:gsub("[)%(-%$]", "")

        -- Trimming the category string. Here are some sample budget categories:
        --    Expenses:Food:Restaurants
        --    Expenses:Food:Groceries
        --    Expenses:Bills
        --    Expenses:Transportation
        if j == 1 then
          local cnt = strutil.count(tmp, ':')

          -- If there's only one colon then take the string after it.
          if cnt == 1 then
            tmp = tmp:gsub(".*:", "")

          -- If there's multiple colons then take the string between the 1st and 2nd colons.
          else
            tmp = tmp:gsub("Expenses:", "")
            tmp = tmp:gsub(":.*", "")
          end

        else
          tmp = tonumber(tmp)
        end

        fields[#fields+1] = tmp
      end

      table.insert(budget, fields)
    end

    self:emit_signal("ready::budget", budget)
  end)

end

---------------------------------------------------------------------

function ledger:new()
end

local function new()
  local ret = gobject{}
  gtable.crush(ret, ledger, true)
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
