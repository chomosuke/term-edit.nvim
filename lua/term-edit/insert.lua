local utils = require 'term-edit.utils'
local navigate = require 'term-edit.navigate'
local async = require 'term-edit.async'
local M = {}

---move right by len
---@param len integer negative mean move left
function M.move_keys(len)
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
  async.vim_cmd('startinsert', function()
    navigate.navigate_with(target, M.move_keys, callback)
  end)
end

return M
