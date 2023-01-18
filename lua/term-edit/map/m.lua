local utils = require 'term-edit.utils'
local M = {}

---map keys
---@param lhs string
---@param rhs function
---@param opts? { mode?: string }
function M.map(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil
  opts = vim.tbl_deep_extend('force', { buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    rhs()
  end, opts)
end

function M.remap(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  vim.keymap.set(mode, lhs, rhs, { buffer = true, remap = true })
end

---map lhs<motion> to right handside in operator pending mode
---@param lhs string
---@param rhs function
---@param opts? { mode?: string }
function M.omap(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil
  opts = vim.tbl_deep_extend('force', { expr = true, buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    _G.term_edit_operatorfunc = rhs
    vim.opt.operatorfunc = 'v:lua.term_edit_operatorfunc'
    return 'g@'
  end, opts)
end

return M
