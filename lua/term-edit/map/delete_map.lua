local m = require 'term-edit.map.m'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'
local navigate = require 'term-edit.navigate'

local M = {}

local function adjust_cursor(start)
  return function()
    navigate.navigate_normal(start)
  end
end

function M.enable()
  m.map('d', function()
    local start = coord.get_coord 'v'
    local end_ = coord.get_coord '.'
    async.feedkeys('<Esc>', function()
      delete.delete_range(start, end_, function()
        async.quit_insert(adjust_cursor(start))
      end)
    end)
  end, { mode = 'x' })
  m.omap('d', function()
    local start = coord.get_coord "'["
    delete.delete_range(start, coord.get_coord "']", function()
      async.quit_insert(adjust_cursor(start))
    end)
  end)
  m.map('dd', function()
    local start = coord.get_coord '0'
    delete.delete_range(start, coord.get_coord '$+', function()
      async.quit_insert(adjust_cursor(start))
    end)
  end)
  m.map('D', function()
    local start = coord.get_coord '.'
    delete.delete_range(start, coord.get_coord '$+', function()
      async.quit_insert(adjust_cursor(start))
    end)
  end)
  m.map('D', function()
    local sl = vim.fn.line 'v'
    local el = vim.fn.line '.'

    if el < sl then
      local temp = el
      el = sl
      sl = temp
    end

    local start = coord.find_line_start(sl)
    local end_ = coord.find_line_end(el, true)
    async.feedkeys('<Esc>', function()
      delete.delete_range(start, end_, function()
        async.quit_insert(adjust_cursor(start))
      end)
    end)
  end, { mode = 'x' })
  m.remap('x', 'dl')
  m.remap('x', 'd', { mode = 'x' })
  m.remap('X', 'dh')
  m.remap('X', 'D', { mode = 'x' })
end

return M
