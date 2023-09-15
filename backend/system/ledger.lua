-- █░░ █▀▀ █▀▄ █▀▀ █▀▀ █▀█
-- █▄▄ ██▄ █▄▀ █▄█ ██▄ █▀▄

local gobject    = require("gears.object")
local gtable     = require("gears.table")
local config     = require("cozyconf")
local awful      = require("awful")
local strutil    = require("utils.string")
local os         = os

local lfile      = config.ledger.ledger_file
local bfile      = config.ledger.budget_file
local afile      = config.ledger.account_file

local LEDGER_CMD = "ledger -f " .. lfile .. " -f " .. afile .. " -f " .. bfile .. " "

local ledger     = {}
local instance   = nil

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
  local cmd = LEDGER_CMD .. " balance checking savings cash --no-total"
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

--- @method parse_month_income
-- @brief Get income for the current month
function ledger:parse_month_income()
  local date = os.date("%m") .. "/01" -- Beginning of this month
  local cmd = LEDGER_CMD .. " balance ^Income -b " .. date .. " | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local amount = stdout:gsub("[^0-9.]", "")
    self:emit_signal("ready::income", amount)
  end)
end

--- @method parse_month_expenses
-- @brief Get expenses for the current month
function ledger:parse_month_expenses()
  local date = os.date("%m") .. "/01" -- Beginning of this month
  local cmd = LEDGER_CMD .. " --cleared balance ^Expense -b " .. date .. " | head -n 1"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local amount = stdout:gsub("[^0-9.]", "")
    self:emit_signal("ready::expenses", amount)
  end)
end

--- @method parse_recent_transactions
-- @brief Gets recent ledger transactions using `ledger csv` command
function ledger:parse_recent_transactions()
  local cmd = LEDGER_CMD .. " csv ^expenses ^income --cleared | head -n 10"
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Clean up the CSV so it's easier to parse
    local transactions = {}
    local lines = strutil.split(stdout, "\r\n")
    for i = 1, #lines do
      local tmp = lines[i]:gsub("\"", "")
      local fields = strutil.split(tmp, ",")
      table.insert(transactions, fields)
    end
    self:emit_signal("ready::transactions", transactions)
  end)
end

--- @method parse_reimbursement_accounts
-- @brief Get information on who owes what. This only shows the amount owed.
--        See parse_reimbursement_data to get information on what the specific
--        transaction was.
function ledger:parse_reimbursement_accounts()
  local cmd = LEDGER_CMD .. " bal Liabilities Assets:Reimbursements --no-total --format \"%12(O)=%A\n\""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- sample stdout:
    --      $61.87=Assets:Reimbursements:Kassidy
    --  $-1,871.50=Liabilities:Bills
    --    $-709.00=Liabilities:Bills:Hospital
    --  $-1,162.50=Liabilities:Bills:Rent

    local lines = strutil.split(stdout, "\r\n")
    local data = {}
    for i = 1, #lines do
      if strutil.count(lines[i], ":") >= 2 then
        local tmp = lines[i]:gsub("%s", "")
        data[#data + 1] = strutil.split(tmp, "=")
      end
    end
    self:emit_signal("ready::reimbursements::accounts", data)
  end)
end

--- @method parse_reimbursement_data
-- @brief Get information on pending liability/reimbursement transaction data.
function ledger:parse_reimbursement_transactions()
  local cmd = LEDGER_CMD .. " --pending csv | grep \"Liabilities\\|Reimbursements\""
  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local lines = strutil.split(stdout, "\r\n")
    local tmp = {}

    for i = 1, #lines do
      tmp[i] = lines[i]:gsub('"', "")
      tmp[i] = strutil.split(tmp[i], ",")
    end

    self:emit_signal("ready::reimbursements::transactions", tmp)
  end)
end

--- @method get_budget
-- @brief Get budget information.
-- Sample stdout looks like this:
--      Expenses,($1005.29, $-970.00)
--      Expenses:Bills,($768.03, $-800.00)
--      Expenses:Food,($52.88, $-50.00)
--      Expenses:Food:Groceries,($14.16, 0)
--      Expenses:Food:Restaurants,($38.72, $-50.00)
--      Expenses:Household,(0, $-30.00)
--      Expenses:Personal,($147.55, $-50.00)
--      Expenses:Transportation,($36.83, $-40.00)
-- 2nd line is total budget. Following lines are budget entries.
function ledger:get_budget(month)
  month        = month or os.date("%Y/%m/01")

  local files  = " -f " .. lfile .. " -f " .. bfile
  local format = " budget --budget-format '%A,%T\n'"
  local begin  = " --begin " .. month
  local cmd    = "ledger " .. files .. begin .. format .. " --no-total | tail -n +2"

  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    local budget = {} -- Holds final data
    local budget_entries = strutil.split(stdout, "\r\n")
    local last_subcat_added = ""

    for i = 1, #budget_entries do
      -- Split budget data string on commas: "Expenses:Education,(0, $-50.00)"
      -- 1st: category, 2nd: spent, 3rd: allocated
      local _fields = strutil.split(budget_entries[i], ",")

      -- Now clean up the fields and put them into new array
      local fields = {}
      local category = ""
      local subcategory = ""

      for j = 1, #_fields do
        local tmp, _ = _fields[j]:gsub("[)%(-%$]", "")

        if j == 1 then
          tmp         = tmp:gsub("Expenses:", "")
          category    = tmp:gsub(":.*", "")
          subcategory = tmp:gsub(".*:", "")
          tmp         = subcategory
        else
          tmp = self:format(tonumber(tmp))
        end

        fields[#fields + 1] = tmp
      end

      if last_subcat_added == category then
        table.remove(budget, #budget)
      end
      last_subcat_added = subcategory

      budget[#budget + 1] = fields
    end

    if #budget > 0 then
      budget[1][1] = "Total"
      self:emit_signal("ready::budget", budget)
    end
  end)
end

function ledger:format(num)
  return string.format("%.2f", num)
end

--- @function balances_this_year
-- @brief Get a table of all balances this year. Data points are taken every 7 days
-- starting from January 1.
function ledger:balances_this_year()
  local SECONDS_PER_WEEK = 24 * 60 * 60 * 7
  local ts = os.time({ year = 2023, month = 1, day = 2, hour = 0, min = 0, sec = 0 })

  -- This chained command will write total assets to a new line, skip ahead 14 days,
  -- and then repeat. There may be a better command for this, but I couldn't find
  -- anything in the ledger docs.
  local cmd = ""
  while ts < os.time() do
    cmd = cmd .. " ledger -f " .. lfile .. " balance -e " .. os.date("%m/%d", ts) .. " | head -n 1 ; "
    ts = ts + SECONDS_PER_WEEK
  end

  awful.spawn.easy_async_with_shell(cmd, function(stdout)
    -- Clean stuff up
    local data = {}
    local tmp = strutil.split(stdout, "\r\n")
    for i = 1, #tmp do
      data[#data + 1] = tmp[i]:gsub("[^0-9.]", "")
    end
    self:emit_signal("ready::year_data", data)
  end)
end

---------------------------------------------------------------------

function ledger:new()
  self:emit_signal("refresh")
end

local function new()
  local ret = gobject {}
  gtable.crush(ret, ledger, true)
  ret:new()
  return ret
end

if not instance then instance = new() end

return instance
