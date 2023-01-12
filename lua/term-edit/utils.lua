local config = require 'term-edit.config'
local M = {}

function M.debug_print(...)
  if config.opts.debug then
    print(...)
  end
end

return M
