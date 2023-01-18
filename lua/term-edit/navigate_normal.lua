local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local M = {}

---navigate in normal mode
---@param target Coord
function M.navigate(target)
  local current = coord.get_coord '.'
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
      M.navigate(target)
    end, { moves = true })
  end
end

return M
