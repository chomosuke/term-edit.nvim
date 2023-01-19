local utils = require 'term-edit.utils'
local config = require 'term-edit.config'
local M = {}

local function get_mapped(keys, mode)
  local function get_mapping(k, m)
    return (config.opts.mapping[m] or {})[k]
  end

  local direct_map = get_mapping(keys, mode)
  if direct_map == false then
    return nil
  end
  if direct_map then
    return direct_map
  end

  local mapped = ''
  for c in keys:gmatch '.' do
    local c_map = get_mapping(c, mode)
    if c_map == false then
      return nil
    end
    if not c_map then
      c_map = c
    else
    end
    mapped = mapped .. c_map
  end
  return mapped
end

---map keys
---@param lhs string
---@param rhs function
---@param opts? { mode?: string }
function M.map(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil

  local nlhs = get_mapped(lhs, mode)
  if not nlhs then
    return
  end
  lhs = nlhs

  opts = vim.tbl_deep_extend('force', { buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    rhs()
  end, opts)
end

function M.remap(lhs, rhs, opts)
  opts = opts or {}
  local mode = opts.mode or 'n'
  opts.mode = nil

  local nlhs = get_mapped(lhs, mode)
  if not nlhs then
    return
  end
  lhs = nlhs

  local nrhs = get_mapped(rhs, mode)
  if not nrhs then
    return
  end
  rhs = nrhs

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

  local nlhs = get_mapped(lhs, mode)
  if not nlhs then
    return
  end
  lhs = nlhs

  opts = vim.tbl_deep_extend('force', { expr = true, buffer = true }, opts)
  vim.keymap.set(mode, lhs, function()
    utils.debug_print('key', lhs, 'in mode', mode)
    _G.term_edit_operatorfunc = rhs
    vim.opt.operatorfunc = 'v:lua.term_edit_operatorfunc'
    return 'g@'
  end, opts)
end

return M
