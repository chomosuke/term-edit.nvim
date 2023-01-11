local M = {
  debug = false,
  key_queue_time = 5,
}

---set options for term-edit
---@param opts { debug?: boolean, key_queue_time?: integer }
function M.setup(opts)
  opts = opts or {}
  M = vim.tbl_deep_extend('force', M, opts)
end

return M
