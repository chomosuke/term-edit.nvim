local M = {
  opts = {
    debug = false,
    feedkeys_delay = 1,
  },
}

---set options for term-edit
---@param opts { debug?: boolean, key_queue_time?: integer }
function M.setup(opts)
  opts = opts or {}
  M.opts = vim.tbl_deep_extend('force', M.opts, opts)
end

return M
