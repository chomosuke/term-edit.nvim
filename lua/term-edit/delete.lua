local utils = require 'term-edit.utils'
local coord = require 'term-edit.coord'
local insert = require 'term-edit.insert'
local navigate = require 'term-edit.navigate'
local config   = require 'term-edit.config'
local M = {}

local function delete_keys(len)
  assert(len <= 0, len)
  utils.debug_print('delete_by:', len)
  return string.rep('<BS>', -len)
end

---Delete all character from start to end inclusive
---Start in normal mode, end in insert mode
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

  vim.fn.setreg(config.opts.default_reg, coord.get_text_between(start, end_))

  if coord.before(end_, start) then
    utils.debug_print 'start end swap'
    local temp = end_
    end_ = start
    start = temp
  end

  local function delete()
    local cursor = coord.get_coord '.'
    if -- nothing to delete if current cursor isn't after start
      coord.before(start, cursor)
    then
      navigate.navigate_with(start, delete_keys, callback)
    elseif callback then
      callback()
    end
  end

  insert.insert_at(coord.add(end_, { col = 1 }), delete)
end

return M
