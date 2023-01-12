local utils = require 'term-edit.utils'
local insert = require 'term-edit.insert'
local coord = require 'term-edit.coord'
local config = require 'term-edit.config'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'
local M = {
  setup = config.setup,
}

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
    utils.debug_print('key', lhs, 'in mode', mode)
    rhs()
  end, { buffer = true })
end

-- local function remap(lhs, rhs)
--   vim.keymap.set('n', lhs, rhs, { buffer = true, remap = true })
-- end

local function get_visual_range()
  local start = coord.get_coord 'v'
  local end_ = coord.get_coord '.'
  if
    end_.line < start.line
    or (end_.line == start.line and end_.col < start.col)
  then
    utils.debug_print 'start end swap'
    local temp = end_
    end_ = start
    start = temp
  end
  return start, end_
end

---enable this plugin for the buffer if buf type is terminal
local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    map('i', function()
      insert.enter_insert {
        target = coord.get_coord '.',
      }
    end)
    map('a', function()
      insert.enter_insert {
        target = coord.get_coord '.',
        post_nav = 1,
      }
    end)
    map('A', function()
      insert.enter_insert {
        target = { line = vim.fn.line '$' + 1, col = 1 },
      }
    end)
    map('I', function()
      insert.enter_insert {
        target = { line = 0, col = 1 },
      }
    end)
    map('c', function()
      local start, end_ = get_visual_range()
      async.feedkeys('<Esc>', function()
        delete.delete_range(start, end_)
      end)
    end, 'x')
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

return M
