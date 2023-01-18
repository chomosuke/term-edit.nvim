local config = require 'term-edit.config'
local coord = require 'term-edit.coord'
---@diagnostic disable: unused-local
local M = {
  callbacks = {},
}

---delay function f with vim.defer_fn by delay milliseconds
---@param f function
---@param delay? integer
function M.schedule(f, delay)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, delay or 0)
end

local callback_index = 0

---@param callback function
---@param defer_more function? will keep defering callback if this returns true
local function register_callback(callback, defer_more)
  callback_index = (callback_index + 1) % 1000
  defer_more = defer_more or function()
    return false
  end
  M.callbacks[callback_index] = function()
    local start_time = os.clock()
    local event_loop_elapsed = 0
    local function schedule_callback()
      if os.clock() > start_time + 1 then
        vim.notify('feedkeys callbacks leak', vim.log.levels.ERROR)
      end
      if event_loop_elapsed < config.opts.feedkeys_delay then
        event_loop_elapsed = event_loop_elapsed + 1
        M.schedule(schedule_callback)
      elseif defer_more() then
        event_loop_elapsed = 0
        M.schedule(schedule_callback)
      else
        callback()
      end
    end
    schedule_callback()
  end
end

local function call_callback()
  return 'lua require("term-edit.async").callbacks[' .. callback_index .. ']()'
end

---feedkeys and run callback after
---Assume start in terminal mode, will execute callback in terminal mode
---@param keys string
---@param callback function? called after the keys are fed
---@param opts? { moves?: boolean }
function M.feedkeys(keys, callback, opts)
  if callback then
    local old
    register_callback(callback, function()
      if not opts then
        return false
      end

      local current = coord.get_coord '.'
      local moved = not coord.equals(current, old)
      old = current

      -- wait till it doesn't move if the keys moves
      return opts.moves and moved
    end)
    keys = keys
      .. '<C-\\><C-n>' -- exit terminal mode
      .. '<cmd>' -- enter command mode
      .. 'startinsert | ' -- get back to terminal mode
      .. call_callback()
      .. '<CR>'
  end
  vim.api.nvim_input(keys)
end

---quit insert (terminal) mode
---@param callback? function
function M.quit_insert(callback)
  local keys = '<C-\\><C-n>' -- exit terminal mode
  if callback then
    register_callback(callback)
    keys = keys .. '<cmd>' .. call_callback() .. '<CR>'
  end
  vim.api.nvim_input(keys)
end

---paste register content
---@param register string
function M.put(register)
  vim.api.nvim_put(
    ---@diagnostic disable-next-line: param-type-mismatch
    vim.fn.getreg(register, nil, true),
    vim.fn.getregtype(register),
    false,
    false
  )
end

---execute command and then maybe call callback
---@param cmd string
---@param callback? function
function M.vim_cmd(cmd, callback)
  if callback then
    register_callback(callback)
    cmd = cmd .. '\n' .. call_callback()
  end
  vim.cmd(cmd)
end

return M
