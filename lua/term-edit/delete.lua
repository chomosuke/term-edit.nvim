local utils = require 'term-edit.utils'
local coord = require 'term-edit.coord'
local insert = require 'term-edit.insert'
local navigate = require 'term-edit.navigate'
local async = require 'term-edit.async'
local M = {}

local function delete_keys(len)
  assert(len <= 0, len)
  utils.debug_print('delete_by:', len)
  return string.rep('<BS>', -len)
end

---Delete all character from start to end inclusive
---Start in
---@param start Coord
---@param end_ Coord
---@param opts? { callback?: function, post_nav?: integer }
function M.delete_range(start, end_, opts)
  opts = opts or {}
  utils.debug_print(
    'delete_range: start:',
    utils.inspect(start),
    'end:',
    utils.inspect(end_)
  )

  vim.fn.setreg('"', coord.get_text_between(start, end_))

  if coord.before(end_, start) then
    utils.debug_print 'start end swap'
    local temp = end_
    end_ = start
    start = temp
  end

  local function post()
    if opts.post_nav then
      async.feedkeys(
        insert.move_keys(opts.post_nav),
        opts.callback,
        { moves = true }
      )
    elseif opts.callback then
      opts.callback()
    end
  end

  local function delete()
    local cursor = coord.get_coord '.'
    if -- nothing to delete if current cursor isn't after start
      cursor.line > start.line
      or (cursor.line == start.line and cursor.col > start.col)
    then
      navigate.navigate_with(start, delete_keys, post)
    else
      post()
    end
  end

  insert.enter_insert(end_, {
    callback = delete,
    post_nav = 1,
  })
end

return M
