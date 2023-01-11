local M = {}

local function debug_print(...)
  if M.opts.debug then
    print(...)
  end
end

---@class Coord
---@field col integer
---@field line integer

local function get_coord(expr)
  return { line = vim.fn.line(expr), col = vim.fn.col(expr) }
end

local function equals(c1, c2)
  return c1 and c2 and c1.line == c2.line and c1.col == c2.col
end

---feedkeys
---@param keys string
local function feedkeys(keys)
  vim.api.nvim_input(keys)
end

---delay function f with vim.defer_fn by delay milliseconds
---@param f function
---@param delay? integer
local function schedule(f, delay)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, delay or 0)
end

---move with move_fn until target is reached
---@param target Coord
---@param move_fn function
---@param callback? function this function will be called after target is reached
local function move_to(target, move_fn, callback)
  local function move_col()
    local current = get_coord '.'
    debug_print('move_col: ', current.line, current.col)
    -- If not the same line means move_line reached end of command
    -- Don't move column anymore
    if current.line == target.line then
      move_fn(target.col - current.col)
    end
    if callback then
      callback()
    end
  end

  local function move_line(old)
    old = old or {}
    local current = get_coord '.'
    debug_print('move_line: ', current.line, current.col)
    if
      current.line == target.line -- reached destination
      or equals(current, old) -- didn't move in last call
    then
      schedule(move_col)
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
    schedule(function()
      move_line(current)
    end, M.opts.key_queue_time)
  end

  move_line()
end

---move right by len
---@param len integer negative mean move left
local function move_by(len)
  debug_print('move_by: ', len)
  while len ~= 0 do
    if len > 0 then
      feedkeys '<Right>'
      len = len - 1
    else
      feedkeys '<Left>'
      len = len + 1
    end
  end
end

---Enter insert mode
---@param opts { callback?: function, post_nav?: integer, target: Coord }
local function enter_insert(opts)
  debug_print('target: ', opts.target.line, opts.target.col)
  vim.cmd 'startinsert'

  schedule(function()
    move_to(opts.target, move_by, function()
      if opts.post_nav then
        move_by(opts.post_nav)
      end
      if opts.callback then
        opts.callback()
      end
    end)
  end)
end

---@class AutocmdOpts
---@field pattern? string[]|string
---@field buffer? integer
---@field desc? string
---@field callback? function|string
---@field command? string
---@field once? boolean
---@field nested? boolean

---create autocmds
---@param name string
---@param autocmds { event: string[]|string, opts: AutocmdOpts }[]
local function create_autocmds(name, autocmds)
  local id = vim.api.nvim_create_augroup(name, {})
  for _, autocmd in ipairs(autocmds) do
    autocmd.opts.group = id
    vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
  end
end

---map keys
---@param lhs string
---@param rhs function
---@param mode? string n by default
local function map(lhs, rhs, mode)
  mode = mode or 'n'
  vim.keymap.set(mode, lhs, function()
    debug_print('key', lhs, 'in mode', mode)
    rhs()
  end, { buffer = true })
end

-- local function remap(lhs, rhs)
--   vim.keymap.set('n', lhs, rhs, { buffer = true, remap = true })
-- end

---enable this plugin for the buffer if buf type is terminal
local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    map('i', function()
      enter_insert {
        target = get_coord '.',
      }
    end)
    map('a', function()
      enter_insert {
        target = get_coord '.',
        post_nav = 1,
      }
    end)
    map('A', function()
      enter_insert {
        target = { line = vim.fn.line '$' + 1, col = 1 },
      }
    end)
    map('I', function()
      enter_insert {
        target = { line = 0, col = 1 },
      }
    end)
  end
end

create_autocmds('term_enter_map_insert', {
  {
    event = 'OptionSet',
    opts = {
      pattern = 'buftype',
      callback = maybe_enable,
    },
  },
  { -- tolerate lazy loading
    event = 'BufEnter',
    opts = {
      callback = maybe_enable,
    },
  },
})

maybe_enable() -- tolerate lazy loading

M.opts = {
  debug = false,
  key_queue_time = 5,
}

---set options for term-edit
---@param opts { debug?: boolean, key_queue_time?: integer }
function M.setup(opts)
  opts = opts or {}
  M.opts = vim.tbl_deep_extend('force', M.opts, opts)
end

return M
