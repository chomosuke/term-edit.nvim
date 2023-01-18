local m = require 'term-edit.map.m'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'

local M = {}

function M.enable()
  m.map('d', function()
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
  m.omap('d', function()
    delete.delete_range(coord.get_coord "'[", coord.get_coord "']", {
      callback = function()
        async.quit_insert()
      end,
      post_nav = 1,
    })
  end)
  m.map('dd', function()
    delete.delete_range(coord.get_coord '0', coord.get_coord '$+', {
      callback = function()
        async.quit_insert()
      end,
      post_nav = 1,
    })
  end)
  m.map('D', function()
    delete.delete_range(coord.get_coord '.', coord.get_coord '$+', {
      callback = function()
        async.quit_insert()
      end,
    })
  end)
  m.remap('x', 'dl')
end

return M
