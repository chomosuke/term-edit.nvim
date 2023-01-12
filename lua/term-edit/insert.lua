local utils = require 'term-edit.utils'
local navigate = require 'term-edit.navigate'
local async = require 'term-edit.async'
local M = {}

---move right by len
---@param len integer negative mean move left
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

---Enter insert mode
---@param opts { callback?: function, post_nav?: integer, target: Coord }
function M.enter_insert(opts)
  utils.debug_print('target: ', opts.target.line, opts.target.col)
  async.vim_cmd('startinsert', function()
    navigate.navigate_with(opts.target, move_keys, function()
      if opts.post_nav then
        async.feedkeys(move_keys(opts.post_nav), opts.callback)
      end
    end)
  end)
end

return M
