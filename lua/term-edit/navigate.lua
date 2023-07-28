local utils = require 'term-edit.utils'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local M = {}

---navigate with move_fn until target is reached
---@param target Coord
---@param move_keys function len
---len is the number of col to move right, negative means move left,
---@param callback? function this function will be called after target is reached
function M.navigate_with(target, move_keys, callback)
  local function navigate_col()
    local current = coord.get_coord '.'
    utils.debug_print('move_col: ', utils.inspect(current))
    -- If not the same line means move_line reached end of command
    -- Don't move column anymore
    if current.line == target.line then
      async.feedkeys(
        move_keys(target.col - current.col),
        callback,
        { moves = true }
      )
    elseif callback then
      callback()
    end
  end

  local function navigate_line(old)
    old = old or {}
    local current = coord.get_coord '.'
    utils.debug_print('move_line: ', utils.inspect(current))
    if
      current.line == target.line -- reached destination
      or coord.equals(current, old) -- didn't move in last call
    then
      navigate_col()
      return
    end
    local col_end = vim.fn.col '$'
    local move_len
    if current.line < target.line then
      -- move to end + one right to move to line below
      move_len = col_end - current.col
      if move_len == 0 then
        -- encountered <CR>, need to move one more to get to the next line
        move_len = 1
      end
    else
      -- move to start + one left to move to line above
      move_len = -current.col
    end
    old = current
    async.feedkeys(move_keys(move_len), function()
      navigate_line(old)
    end, { moves = true })
  end

  navigate_line()
end

---navigate in normal mode
---@param target Coord
function M.navigate_normal(target)
  local function n(old)
    local current = coord.get_coord '.'
    if coord.equals(current, old) then
      return
    end
    local keys = nil
    if current.line < target.line then
      keys = string.rep('j', target.line - current.line)
    elseif current.line > target.line then
      keys = string.rep('k', current.line - target.line)
    elseif current.col < target.col then
      keys = string.rep('l', target.col - current.col)
    elseif current.col > target.col then
      keys = string.rep('h', current.col - target.col)
    end
    if keys then
      async.feedkeys(keys, function()
        n(current)
      end, { moves = true, start_normal = true, callback_normal = true })
    end
  end
  n()
end

---navigate with all arrow keys
---@param target Coord
---@param callback? function this function will be called after target is reached
function M.navigate_all_arrows(target, callback)
  local function n(old)
    local current = coord.get_coord '.'
    if coord.equals(current, old) or coord.equals(current, target) then
      if coord.equals(current, old) then
        utils.debug_print('Did not move')
      else
        utils.debug_print('Target reached')
      end
      if callback then
        callback()
      end
      return
    end
    local keys = ''
    if current.line < target.line then
      keys = keys .. string.rep('<Down>', target.line - current.line)
    elseif current.line > target.line then
      keys = keys .. string.rep('<Up>', current.line - target.line)
    end
    if current.col < target.col then
      keys = keys .. string.rep('<Right>', target.col - current.col)
    elseif current.col > target.col then
      keys = string.rep('<Left>', current.col - target.col) .. keys
    end
    utils.debug_print('All arrow navigation: ', keys)
    async.feedkeys(keys, function()
      n(current)
    end, { moves = true })
  end
  n()
end

return M
