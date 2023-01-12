local utils = require 'term-edit.utils'
-- local coord = require 'term-edit.coord'
local insert = require 'term-edit.insert'
local navigate = require 'term-edit.navigate'
local M = {}

local function delete_keys(len)
  assert(len < 0, len)
  print('delete_by:', len)
  return string.rep('<BS>', -len)
end

---Delete all character from start to end inclusive
---Start in
---@param start Coord
---@param end_ Coord
---@param callback? function
function M.delete_range(start, end_, callback)
  utils.debug_print(
    'delete_range: start:',
    utils.inspect(start),
    'end:',
    utils.inspect(end_)
  )

  local function delete()
    -- local current = coord.get_coord '.'
    -- -- if end can't be reached, do nothing
    -- if coord.equals(current, end_) then
    navigate.navigate_with(start, delete_keys, callback)
    -- end
  end

  insert.enter_insert {
    target = end_,
    callback = delete,
    post_nav = 1,
  }
end

return M
