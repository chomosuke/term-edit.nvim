local utils = require 'term-edit.utils'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local M = {}

---navigate with move_fn until target is reached
---@param target Coord
---@param move_keys function
---@param callback? function this function will be called after target is reached
function M.navigate_with(target, move_keys, callback)
  local function navigate_col()
    local current = coord.get_coord '.'
    utils.debug_print('move_col: ', current.line, current.col)
    -- If not the same line means move_line reached end of command
    -- Don't move column anymore
    if current.line == target.line then
      async.feedkeys(move_keys(target.col - current.col), callback)
    end
  end

  local function navigate_line(old)
    old = old or {}
    local current = coord.get_coord '.'
    utils.debug_print('move_line: ', current.line, current.col)
    if
      current.line == target.line -- reached destination
      or coord.equals(current, old) -- didn't move in last call
    then
      navigate_col()
      return
    end
    local col_end = vim.fn.col '$'
    local move_len
    local expected_line
    if current.line < target.line then
      -- move to end + one right to move to line below
      move_len = col_end - current.col
      expected_line = current.line + 1
    else
      -- move to start + one left to move to line above
      move_len = -current.col
      expected_line = current.line - 1
    end
    old = current
    async.feedkeys(move_keys(move_len), function()
      navigate_line(old)
    end, function()
      local next = coord.get_coord '.'
      local moved = not coord.equals(next, old)
      old = next
      return moved -- wait till it doesn't move
        -- keep waiting if the line number isn't expected
        or (next.line ~= expected_line and next.line ~= current.line)
    end)
  end

  navigate_line()
end

return M
