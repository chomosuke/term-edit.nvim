local m = require 'term-edit.map.m'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'

local M = {}

function M.enable()
  m.map('c', function()
    local start = coord.get_coord 'v'
    local end_ = coord.get_coord '.'
    async.feedkeys('<Esc>', function()
      delete.delete_range(start, end_)
    end)
  end, { mode = 'x' })
  m.omap('c', function()
    delete.delete_range(coord.get_coord "'[", coord.get_coord "']")
  end)
  m.map('cc', function()
    delete.delete_range(coord.get_coord '0', coord.get_coord '$')
  end)
  m.remap('cw', 'ce')
  m.remap('cW', 'cE')
  m.map('C', function()
    delete.delete_range(coord.get_coord '.', coord.get_coord '$')
  end)
  m.remap('s', 'cl')
  m.remap('S', 'cc')
end

return M
