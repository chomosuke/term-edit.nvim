local config = require 'term-edit.config'
local M = {}

---@class Coord
---@field col integer
---@field line integer

local function get_winwidth()
  return vim.fn.winwidth(0) - vim.fn.wincol() + vim.fn.col '.'
end

local function find_line_start()
  local lnum = vim.fn.line '.'
  local winwidth = get_winwidth()
  local line = vim.fn.getline(lnum) --[[@as string]]
  while true do
    local _, start_col = string.find(line, config.opts.prompt_start)
    if start_col then
      -- found prompt_start
      return { line = lnum, col = start_col + 1 }
    end

    lnum = lnum - 1
    if lnum < 1 then
      vim.notify('Can not find prompt_start: ' .. config.opts.prompt_start)
    end

    line = vim.fn.getline(lnum) --[[@as string]]
    if #line < winwidth then
      -- current lnum end with <CR>
      -- last lnum is line start
      return { line = lnum + 1, col = 1 }
    end
  end
end

local function find_line_end()
  local winwidth = get_winwidth()
  local lnum = vim.fn.line '.'
  local line = vim.fn.getline(lnum) --[[@as string]]
  while #line == winwidth do
    -- lnum don't end with <CR>
    lnum = lnum + 1
    line = vim.fn.getline(lnum) --[[@as string]]
  end
  return { line = lnum, col = #line }
end

---get coord with expr, '.' is cursor, '0' is start of the line
---and '$' is end of the line
---@param expr string
---@return Coord
function M.get_coord(expr)
  if expr == '0' then
    return find_line_start()
  elseif expr == '$' then
    return find_line_end()
  else
    return { line = vim.fn.line(expr), col = vim.fn.col(expr) }
  end
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

function M.add(c1, c2)
  return {
    line = (c1.line or 0) + (c2.line or 0),
    col = (c1.col or 0) + (c2.col or 0),
  }
end

return M
