local function feedkeys(keys)
  return vim.api.nvim_input(keys)
end

local function schedule(f)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, 0)
end

-- insert
local function term_insert(post_nav)
  post_nav = post_nav or 0
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd 'startinsert'
  schedule(function()
    local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
    if new_row == row then
      while new_col ~= col do
        if new_col > col then
          feedkeys '<Left>'
          new_col = new_col - 1
        else
          feedkeys '<Right>'
          new_col = new_col + 1
        end
      end
    end
    while post_nav ~= 0 do
      if post_nav > 0 then
        feedkeys '<Right>'
        post_nav = post_nav - 1
      else
        feedkeys '<Left>'
        post_nav = post_nav + 1
      end
    end
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

local function remap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { buffer = true, remap = true })
end

local function map_insert(opts)
  return function()
    term_insert(opts)
  end
end

local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    map('i', map_insert())
    map('a', map_insert { post_nav = 1 })
    remap('I', '^i')
    remap('A', '$a')
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
