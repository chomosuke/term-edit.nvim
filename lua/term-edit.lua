local function feedkeys(keys)
  return vim.api.nvim_feedkeys(
    vim.api.nvim_replace_termcodes(keys, true, false, true),
    'm',
    false
  )
end

local function schedule(f)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, 0)
end

-- insert
local function term_insert(key)
  local row, col = unpack(vim.api.nvim_win_get_cursor(0))
  vim.cmd 'startinsert'
  schedule(function()
    local new_row, new_col = unpack(vim.api.nvim_win_get_cursor(0))
    if new_row == row then
      if key == 'a' then
        col = col + 1
      end
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
  end)
end

local function create_autocmds(name, autocmds)
  local id = vim.api.nvim_create_augroup(name, {})
  for _, autocmd in ipairs(autocmds) do
    autocmd.opts.group = id
    vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
  end
end

local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    vim.keymap.set('n', 'i', function()
      term_insert 'i'
    end, { buffer = true })
    vim.keymap.set('n', 'a', function()
      term_insert 'a'
    end, { buffer = true })
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
