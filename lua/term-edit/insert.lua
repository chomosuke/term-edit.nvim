local utils = require 'term-edit.utils'
local navigate = require 'term-edit.navigate'
local async = require 'term-edit.async'
local config = require 'term-edit.config'
local M = {}

local function move_keys(len, _)
  utils.debug_print('move_by: ', len)
  if len > 0 then
    return string.rep('<Right>', len)
  elseif len < 0 then
    return string.rep('<Left>', -len)
  else
    return ''
  end
end

local function move_keys_up_down(len, lines)
  utils.debug_print 'using up down arrow to move'
  if lines > 0 then
    return string.rep('<Down>', lines)
  elseif lines < 0 then
    return string.rep('<Up>', -lines)
  else
    return move_keys(len, 0)
  end
end

---Enter insert mode and place cursor at target
---@param callback? function
function M.insert_at(target, callback)
  utils.debug_print('enter_insert: target: ', utils.inspect(target))
  local use_up_down_arrows = config.opts.use_up_down_arrows()
  async.vim_cmd('startinsert', function()
    navigate.navigate_with(
      target,
      use_up_down_arrows and move_keys_up_down or move_keys,
      callback
    )
  end)
end

return M
