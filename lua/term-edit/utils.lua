local config = require "term-edit.config"
local M = {}

function M.debug_print(...)
  if config.debug then
    print(...)
  end
end

---feedkeys
---@param keys string
function M.feedkeys(keys)
  vim.api.nvim_input(keys)
end

---delay function f with vim.defer_fn by delay milliseconds
---@param f function
---@param delay? integer
function M.schedule(f, delay)
  ---@diagnostic disable-next-line: param-type-mismatch
  vim.defer_fn(f, delay or 0)
end

return M
