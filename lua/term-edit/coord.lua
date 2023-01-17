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

function M.before(c1, c2)
  return c1.line < c2.line or (c1.line == c2.line and c1.col < c2.col)
end

function M.get_text_between(m1, m2)
  if M.before(m2, m1) then
    local temp = m1
    m1 = m2
    m2 = temp
  end
  local lines = vim.fn.getline(m1.line, m2.line)
  lines[#lines] = string.sub(lines[#lines], 1, m2.col)
  lines[1] = string.sub(lines[1], m1.col, #lines[1])
  return table.concat(lines, '\n')
end

return M
