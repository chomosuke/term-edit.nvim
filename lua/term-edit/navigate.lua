local utils = require "term-edit.utils"
local coord = require "term-edit.coord"
local config= require "term-edit.config"
local M = {}

---navigate with move_fn until target is reached
---@param target Coord
---@param move_fn function
---@param callback? function this function will be called after target is reached
function M.navigate_with(target, move_fn, callback)
  local function navigate_col()
    local current = coord.get_coord '.'
    utils.debug_print('move_col: ', current.line, current.col)
    -- If not the same line means move_line reached end of command
    -- Don't move column anymore
    if current.line == target.line then
      move_fn(target.col - current.col)
    end
    if callback then
      callback()
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
      utils.schedule(navigate_col)
      return
    end
    -- if current.line == old.line, then previous keys haven't been processed yet
    -- Skip moving and wait one more event loop instead
    if current.line ~= old.line then
      local col_end = vim.fn.col '$'
      local move_len
      if current.line < target.line then
        -- move to end + one right to move to line below
        move_len = col_end - current.col
      else
        -- move to start + one left to move to line above
        move_len = -current.col
      end
      move_fn(move_len)
    end
    utils.schedule(function()
      navigate_line(current)
    end, config.key_queue_time)
  end

  navigate_line()
end

return M
