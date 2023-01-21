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
    local start_col = nil
    if type(config.opts.prompt_end) == 'string' then
      _, start_col = string.find(line, config.opts.prompt_end --[[@as string]])
    else
      for _, prompt_end in
        pairs(config.opts.prompt_end --[[@as string[] ]])
      do
        _, start_col = string.find(line, prompt_end)
        if start_col ~= nil then
          break
        end
      end
    end
    if start_col then
      -- found prompt_end
      return { line = lnum, col = start_col + 1 }
    end

    lnum = lnum - 1
    if lnum < 1 then
      vim.notify('Can not find prompt_end: ' .. config.opts.prompt_end)
      return { line = 1, col = 1 }
    end

    line = vim.fn.getline(lnum) --[[@as string]]
    if #line < winwidth then
      -- current lnum end with <CR>
      -- last lnum is line start
      return { line = lnum + 1, col = 1 }
    end
  end
end

local function find_line_end(include_cr)
  local winwidth = get_winwidth()
  local winheight = vim.fn.line '$'
  local lnum = vim.fn.line '.'
  local line = vim.fn.getline(lnum) --[[@as string]]
  while #line == winwidth and lnum <= winheight do
    -- lnum don't end with <CR>
    lnum = lnum + 1
    line = vim.fn.getline(lnum) --[[@as string]]
  end
  local col = #line
  if include_cr and col ~= 1 then
    col = col + 1
  end
  return { line = lnum, col = col }
end

---get coord with expr, '.' is cursor, '0' is start of the line
---and '$' is end of the line
---@param expr string
---@return Coord
function M.get_coord(expr)
  if expr == '0' then
    return find_line_start()
  elseif expr == '$' or expr == '$+' then
    return find_line_end(expr == '$+')
  else
    return { line = vim.fn.line(expr), col = vim.fn.col(expr) }
  end
end

---check if 2 coords are equal
---@param c1 Coord
---@param c2 Coord
---@return boolean
function M.equals(c1, c2)
  return c1 and c2 and c1.line == c2.line and c1.col == c2.col
end

---check if first coord is before the second coord
---@param c1 Coord
---@param c2 Coord
---@return boolean
function M.before(c1, c2)
  return c1.line < c2.line or (c1.line == c2.line and c1.col < c2.col)
end

---get text between the two coords
---@param m1 Coord
---@param m2 Coord
---@return string
function M.get_text_between(m1, m2)
  if M.before(m2, m1) then
    local temp = m1
    m1 = m2
    m2 = temp
  end
  local lines = vim.fn.getline(m1.line, m2.line)
  local winwidth = get_winwidth()
  for i, _ in ipairs(lines) do
    if #lines[i] < winwidth then
      lines[i] = lines[i] .. '\n'
    end
  end
  lines[#lines] = string.sub(lines[#lines], 1, m2.col)
  lines[1] = string.sub(lines[1], m1.col, #lines[1])
  return table.concat(lines, '')
end

---add two coords and return the result
---@param c1 Coord
---@param c2 Coord
---@return Coord
function M.add(c1, c2)
  return {
    line = (c1.line or 0) + (c2.line or 0),
    col = (c1.col or 0) + (c2.col or 0),
  }
end

return M
