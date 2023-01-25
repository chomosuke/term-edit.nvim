local m = require 'term-edit.map.m'
local insert = require 'term-edit.insert'
local coord = require 'term-edit.coord'

local M = {}

function M.enable()
  m.map('<C-i>', function()
    vim.cmd 'startinsert'
  end)

  m.map('i', function()
    insert.insert_at(coord.get_coord '.')
  end)
  m.map('a', function()
    insert.insert_at(coord.add(coord.get_coord '.', { col = 1 }))
  end)
  m.map('A', function()
    insert.insert_at(coord.get_coord '$+')
  end)
  m.map('I', function()
    insert.insert_at(coord.get_coord '0')
  end)
end

return M
