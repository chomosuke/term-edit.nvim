local m = require 'term-edit.map.m'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'
local navigate_normal = require 'term-edit.navigate_normal'

local M = {}

local function adjust_cursor(start)
  return function()
    navigate_normal.navigate_to(start)
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
  m.remap('x', 'dl')
  m.remap('x', 'd', { mode = 'x' })
end

return M
