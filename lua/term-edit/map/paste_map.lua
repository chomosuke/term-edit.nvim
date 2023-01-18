local m = require 'term-edit.map.m'
local insert = require 'term-edit.insert'
local coord = require 'term-edit.coord'
local async = require 'term-edit.async'
local delete = require 'term-edit.delete'

local M = {}

function M.enable()
  local registers =
    '"0123456789-abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ:.%#=*+_/'
  for r in registers:gmatch '.' do
    for p in ('pP'):gmatch '.' do
      -- normal mode
      m.map('"' .. r .. p, function()
        insert.insert_at(coord.get_coord '.', {
          post_nav = p == 'p' and 1 or 0,
          callback = function()
            async.quit_insert(function()
              async.put(r)
              async.schedule(function()
                async.vim_cmd('startinsert', function()
                  async.schedule(async.quit_insert, 5)
                end)
              end, 5)
            end)
          end,
        })
      end)

      -- virtual mode
      m.map('"' .. r .. p, function()
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
                async.schedule(function()
                  async.vim_cmd('startinsert', function()
                    async.schedule(async.quit_insert, 5)
                  end)
                end, 5)
              end)
            end,
          })
        end)
      end, { mode = 'x' })
    end
  end
  m.remap('p', '""p')
  m.remap('P', '""P')
  m.remap('p', '""p', { mode = 'x' })
  m.remap('P', '""P', { mode = 'x' })
end

return M
