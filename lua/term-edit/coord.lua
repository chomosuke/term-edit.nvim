local M = {}

---@class Coord
---@field col integer
---@field line integer

function M.get_coord(expr)
  return { line = vim.fn.line(expr), col = vim.fn.col(expr) }
end

function M.equals(c1, c2)
  return c1 and c2 and c1.line == c2.line and c1.col == c2.col
end

return M
