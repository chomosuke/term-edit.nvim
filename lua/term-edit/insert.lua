local utils = require "term-edit.utils"
local navigate  = require "term-edit.navigate"
local M = {}

---move right by len
---@param len integer negative mean move left
local function move_by(len)
  utils.debug_print('move_by: ', len)
  while len ~= 0 do
    if len > 0 then
      utils.feedkeys '<Right>'
      len = len - 1
    else
      utils.feedkeys '<Left>'
      len = len + 1
    end
  end
end

---Enter insert mode
---@param opts { callback?: function, post_nav?: integer, target: Coord }
function M.enter_insert(opts)
  utils.debug_print('target: ', opts.target.line, opts.target.col)
  vim.cmd 'startinsert'

  utils.schedule(function()
    navigate.navigate_with(opts.target, move_by, function()
      if opts.post_nav then
        move_by(opts.post_nav)
      end
      if opts.callback then
        opts.callback()
      end
    end)
  end)
end

return M
