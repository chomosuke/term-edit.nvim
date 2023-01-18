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

local function remap(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  vim.keymap.set(mode, lhs, rhs, { buffer = true, remap = true })
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
    -- insert and that's it
    map('<C-i>', function()
      vim.cmd 'startinsert'
    end)

    -- insert
    map('i', function()
      insert.insert_at(coord.get_coord '.')
    end)
    map('a', function()
      insert.insert_at(coord.get_coord '.', {
        post_nav = 1,
      })
    end)
    map('A', function()
      insert.insert_at(coord.get_coord '$+')
    end)
    map('I', function()
      insert.insert_at(coord.get_coord '0')
    end)

    -- delete
    map('d', function()
      local start = coord.get_coord 'v'
      local end_ = coord.get_coord '.'
      async.feedkeys('<Esc>', function()
        delete.delete_range(start, end_, {
          callback = function()
            async.quit_insert()
          end,
          post_nav = 1,
        })
      end)
    end, { mode = 'x' })
    omap('d', function()
      delete.delete_range(coord.get_coord "'[", coord.get_coord "']", {
        callback = function()
          async.quit_insert()
        end,
        post_nav = 1,
      })
    end)
    map('dd', function()
      delete.delete_range(coord.get_coord '0', coord.get_coord '$+', {
        callback = function()
          async.quit_insert()
        end,
        post_nav = 1,
      })
    end)
    map('D', function()
      delete.delete_range(coord.get_coord '.', coord.get_coord '$+', {
        callback = function()
          async.quit_insert()
        end,
      })
    end)
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
    end)
    map('cc', function()
      delete.delete_range(coord.get_coord '0', coord.get_coord '$')
    end)
    remap('cw', 'ce')
    remap('cW', 'cE')
    map('C', function()
      delete.delete_range(coord.get_coord '.', coord.get_coord '$', {
        callback = function()
          async.quit_insert()
        end,
      })
    end)
    remap('s', 'cl')
    remap('S', 'cc')

    -- paste
    local registers =
      '"0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:.%#=*+_/'
    for r in registers:gmatch '.' do
      for p in ('pP'):gmatch '.' do
        -- normal mode
        map('"' .. r .. p, function()
          insert.insert_at(coord.get_coord '.', {
            post_nav = p == 'p' and 1 or 0,
            callback = function()
              async.quit_insert(function()
                async.put(r)
              end)
            end,
          })
        end)

        -- virtual mode
        map('"' .. r .. p, function()
          local start = coord.get_coord 'v'
          local end_ = coord.get_coord '.'
          ---@diagnostic disable-next-line: param-type-mismatch
          local content = vim.fn.getreg(r, nil, true)
          local regtype = vim.fn.getregtype(r)
          async.feedkeys('<Esc>', function()
            delete.delete_range(start, end_, {
              callback = function()
                async.quit_insert(function()
                  vim.api.nvim_put(
                    ---@diagnostic disable-next-line: param-type-mismatch
                    content,
                    regtype,
                    false,
                    false
                  )
                end)
              end,
            })
          end)
        end, { mode = 'x' })
      end
    end
    remap('p', '""p')
    remap('P', '""P')
    remap('p', '""p', { mode = 'x' })
    remap('P', '""P', { mode = 'x' })
  end
end

---setup term-edit
---@param opts TermEditOpts
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
