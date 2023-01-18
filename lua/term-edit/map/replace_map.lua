local m = require 'term-edit.map.m'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local insert = require 'term-edit.insert'
local M = {}

function M.enable()
  m.map('r', function()
    local cursor = coord.get_coord '.'
    local replacement = vim.fn.nr2char(vim.fn.getchar())
    async.schedule(function()
      insert.insert_at(cursor, {
        callback = function()
          if replacement == '<' then
            replacement = '<lt>'
          end
          async.feedkeys('<BS>' .. replacement, async.quit_insert)
        end,
        post_nav = 1,
      })
    end)
  end, { expr = true })
end

return M
