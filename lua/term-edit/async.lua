local config = require 'term-edit.config'
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

local function register_callback(callback, defer_more)
  callback_index = (callback_index + 1) % 1000
  if not callback then
    callback = function() end
  end
  if not defer_more then
    defer_more = function()
      return false
    end
  end
  M.callbacks[callback_index] = function()
    local event_loop_elapsed = 0
    local function schedule_callback()
      if event_loop_elapsed < config.opts.feedkeys_delay or defer_more() then
        event_loop_elapsed = event_loop_elapsed + 1
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
---@param defer_more function? will keep defering callback if this returns true
function M.feedkeys(keys, callback, callback_in, defer_more)
  register_callback(callback, defer_more)
  vim.api.nvim_input(
    keys
      .. '<C-\\><C-n>' -- exit terminal mode
      .. '<cmd>' -- enter command mode
      .. 'startinsert | ' -- get back to terminal mode
      .. call_callback()
      .. '<CR>'
  )
end

function M.vim_cmd(cmd, callback)
  register_callback(callback)
  vim.cmd(cmd .. '\n' .. call_callback())
end

return M
