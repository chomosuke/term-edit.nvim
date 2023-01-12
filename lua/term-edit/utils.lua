local config = require 'term-edit.config'
local M = {}

function M.debug_print(...)
  if config.opts.debug then
    print(...)
  end
end

function M.inspect(obj)
  return vim.inspect(obj, { newline = ' ', indent = '' })
end

return M
