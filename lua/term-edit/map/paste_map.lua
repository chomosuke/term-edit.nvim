local m = require 'term-edit.map.m'
local insert = require 'term-edit.insert'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'
local config = require 'term-edit.config'

local M = {}

local function paste_v(r)
  local start = coord.get_coord 'v'
  local end_ = coord.get_coord '.'
  ---@diagnostic disable-next-line: param-type-mismatch
  local content = vim.fn.getreg(r, nil, true)
  local regtype = vim.fn.getregtype(r)
  async.feedkeys('<Esc>', function()
    delete.delete_range(start, end_, function()
      async.quit_insert(function()
        vim.api.nvim_put(
          ---@diagnostic disable-next-line: param-type-mismatch
          content,
          regtype,
          false,
          false
        )
        async.schedule(function()
          async.vim_cmd('startinsert', function()
            async.schedule(async.quit_insert, 5)
          end)
        end, 5)
      end)
    end)
  end)
end

local function paste_n(r, p)
  insert.insert_at(
    coord.add(coord.get_coord '.', { col = p == 'p' and 1 or 0 }),
    function()
      async.quit_insert(function()
        async.put(r)
        async.schedule(function()
          async.vim_cmd('startinsert', function()
            async.schedule(async.quit_insert, 5)
          end)
        end, 5)
      end)
    end
  )
end

function M.enable()
  local registers =
    '"0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:.%#=*+_/'
  for r in registers:gmatch '.' do
    for p in ('pP'):gmatch '.' do
      -- normal mode
      m.map('"' .. r .. p, function()
        paste_n(r, p)
      end)

      -- virtual mode
      m.map('"' .. r .. p, function()
        paste_v(r)
      end, { mode = 'x' })
    end
  end
  m.map('p', function()
    paste_n(config.opts.default_reg, 'p')
  end)
  m.map('P', function()
    paste_n(config.opts.default_reg, 'P')
  end)
  m.map('p', function()
    paste_v(config.opts.default_reg)
  end, { mode = 'x' })
  m.map('P', function()
    paste_v(config.opts.default_reg)
  end, { mode = 'x' })

  m.map('<C-p>', 'p', { mode = 'n' })
  m.map('<C-p>', 'p', { mode = 'x' })
  m.map('<C-P>', 'P', { mode = 'n' })
  m.map('<C-P>', 'P', { mode = 'x' })
end

return M
