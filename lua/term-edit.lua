local function feedkeys(keys)
  return vim.api.nvim_input(keys)
end

---move right by len
---@param len integer negative mean move left
local function move(len)
  -- print('move_len: ', len)
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

---delay function f with vim.defer_fn by delay milliseconds
---@param delay integer
---@param f function
local function schedule(delay, f)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, delay)
end

---@class InsertOpts
---@field d_line integer
---@field d_col integer
---@field post_nav integer

---Insert
---@param opts? InsertOpts
local function term_insert(opts)
  -- print 'start'
  opts = opts or {}
  local target_line = vim.fn.line '.'
  local target_col = vim.fn.col '.'
  if opts.d_line then
    target_line = target_line + opts.d_line
  end
  if opts.d_col then
    target_col = target_col + opts.d_col
  end
  -- print('target: ', target_line, target_col)
  vim.cmd 'startinsert'

  local function post()
    if opts.post_nav then
      move(opts.post_nav)
    end
  end

  local function move_col()
    local cur_line = vim.fn.line '.'
    local cur_col = vim.fn.col '.'
    -- print('move_col: ', cur_line, cur_col)
    -- If not the same row means move_row reached end of command
    -- Don't move column anymore
    if cur_line == target_line then
      move(target_col - cur_col)
    end
    post()
  end

  local function move_row(old_line, old_col)
    local cur_line = vim.fn.line '.'
    local cur_col = vim.fn.col '.'
    -- print('move_row: ', cur_line, cur_col)
    if
      (cur_line == target_line) -- reached destination
      or (cur_line == old_line and cur_col == old_col) -- didn't move in last call
    then
      schedule(0, move_col)
      return
    end
    -- if cur_line == old_line, then previous keys haven't been processed yet
    -- Skip moving and wait one more event loop instead
    if cur_line ~= old_line then
      local col_end = vim.fn.col '$'
      local move_len
      if cur_line < target_line then
        -- move to end + one right to move to row below
        move_len = col_end - cur_col
      else
        -- move to start + one left to move to row above
        move_len = -cur_col
      end
      move(move_len)
    end
    schedule(5, function()
      move_row(cur_line, cur_col)
    end)
  end

  schedule(0, function()
    move_row()
  end)
end

local function create_autocmds(name, autocmds)
  local id = vim.api.nvim_create_augroup(name, {})
  for _, autocmd in ipairs(autocmds) do
    autocmd.opts.group = id
    vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
  end
end

local function map(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { buffer = true })
end

-- local function remap(lhs, rhs)
--   vim.keymap.set('n', lhs, rhs, { buffer = true, remap = true })
-- end

---return a function that call term_insert with opts as the options
---@param opts? table|function Option to pass to term_insert, or a function that returns option to term_insert
---@return function
local function map_insert(opts)
  return function()
    if type(opts) == 'function' then
      term_insert(opts())
    else
      term_insert(opts)
    end
  end
end

local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    map('i', map_insert())
    map('a', map_insert { post_nav = 1 })
    map(
      'A',
      map_insert(function()
        -- very bottom
        return { d_line = vim.fn.line '$' }
      end)
    )
    map(
      'I',
      map_insert(function()
        -- very top
        return { d_line = -vim.fn.line '$' }
      end)
    )
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
