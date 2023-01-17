local utils = require 'term-edit.utils'
local insert = require 'term-edit.insert'
local coord = require 'term-edit.coord'
local config = require 'term-edit.config'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'
local M = {}

---@class AutoCmdOpts
---@field pattern? string[]|string
---@field buffer? integer
---@field desc? string
---@field callback? function|string
---@field command? string
---@field once? boolean
---@field nested? boolean

---create autocmds
---@param name string
---@param autocmds { event: string[]|string, opts: AutoCmdOpts }[]
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
---@param opts? { mode?: string }
local function map(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil
  opts = vim.tbl_deep_extend('force', { buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    rhs()
  end, opts)
end

local function remap(lhs, rhs)
  vim.keymap.set('n', lhs, rhs, { buffer = true, remap = true })
end

---map lhs<motion> to right handside in operator pending mode
---@param lhs string
---@param rhs function
---@param opts? { mode?: string }
local function omap(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil
  opts = vim.tbl_deep_extend('force', { expr = true, buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    _G.term_edit_operatorfunc = rhs
    vim.opt.operatorfunc = 'v:lua.term_edit_operatorfunc'
    return 'g@'
  end, opts)
end

---enable this plugin for the buffer if buf type is terminal
local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    -- insert
    map('i', function()
      insert.enter_insert(coord.get_coord '.')
    end)
    map('a', function()
      insert.enter_insert(coord.get_coord '.', {
        post_nav = 1,
      })
    end)
    map('A', function()
      insert.enter_insert { line = vim.fn.line '$' + 1, col = 1 }
    end)
    map('I', function()
      insert.enter_insert { line = 0, col = 1 }
    end)

    -- delete
    map('d', function()
      local start = coord.get_coord 'v'
      local end_ = coord.get_coord '.'
      async.feedkeys('<Esc>', function()
        delete.delete_range(start, end_, {
          callback = function()
            async.feedkeys '<C-\\><C-n>'
          end,
          post_nav = 1,
        })
      end)
    end, { mode = 'x' })
    omap('d', function()
      delete.delete_range(coord.get_coord "'[", coord.get_coord "']", {
        callback = function()
          async.feedkeys '<C-\\><C-n>'
        end,
        post_nav = 1,
      })
    end, { expr = true })
    remap('dd', '0d$')
    remap('D', 'd$')
    remap('x', 'dl')

    -- change
    map('c', function()
      local start = coord.get_coord 'v'
      local end_ = coord.get_coord '.'
      async.feedkeys('<Esc>', function()
        delete.delete_range(start, end_)
      end)
    end, { mode = 'x' })
    omap('c', function()
      delete.delete_range(coord.get_coord "'[", coord.get_coord "']")
    end, { expr = true })
    remap('cc', '0c$')
    remap('cw', 'ce')
    remap('cW', 'cE')
    remap('C', 'c$')
    remap('s', 'cl')
    remap('S', '0c$')
  end
end

function M.setup(opts)
  config.setup(opts)

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
end

return M
