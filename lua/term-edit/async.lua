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

---@param callback function?
---@param defer_more function? will keep defering callback if this returns true
local function register_callback(callback, defer_more)
  callback_index = (callback_index + 1) % 1000
  callback = callback or function() end
  defer_more = defer_more or function()
    return false
  end
  M.callbacks[callback_index] = function()
    local event_loop_elapsed = 0
    local function schedule_callback()
      if defer_more() then
        event_loop_elapsed = 0
      end
      if event_loop_elapsed < config.opts.feedkeys_delay then
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
---@param opts? { moves?: boolean, line_ranges?: { l1: integer, l2: integer }[] }
function M.feedkeys(keys, callback, opts)
  local old
  register_callback(callback, function()
    if not opts then
      return false
    end

    local current = coord.get_coord '.'
    local moved = not coord.equals(current, old)
    old = current

    -- wait till it doesn't move if the keys moves
    local defer_more = opts.moves and moved

    if opts.line_ranges then
      -- wait till line is withing range
      local in_range = false
      for _, line_range in pairs(opts.line_ranges) do
        if
          current.line <= math.max(line_range.l1, line_range.l2)
          and current.line >= math.min(line_range.l1, line_range.l2)
        then
          in_range = true
          break
        end
      end
      defer_more = defer_more or not in_range
    end
    return defer_more
  end)
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
