local utils = require 'term-edit.utils'
local navigate = require 'term-edit.navigate'
local async = require 'term-edit.async'
local config = require 'term-edit.config'
local M = {}

local function move_keys(len)
  utils.debug_print('move_by: ', len)
  if len > 0 then
    return string.rep('<Right>', len)
  elseif len < 0 then
    return string.rep('<Left>', -len)
  else
    return ''
  end
end

---Enter insert mode and place cursor at target
---@param callback? function
function M.insert_at(target, callback)
  utils.debug_print('enter_insert: target: ', utils.inspect(target))
  local use_up_down_arrows = config.opts.use_up_down_arrows()
  async.vim_cmd('startinsert', function()
    if use_up_down_arrows then
      navigate.navigate_all_arrows(target, callback)
    else
      navigate.navigate_with(target, move_keys, callback)
    end
  end)
end

return M
