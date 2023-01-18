local M = {
  ---@type TermEditOpts
  opts = {
    debug = false,
    feedkeys_delay = 10,
  },
}

---@class TermEditOpts
---@field prompt_start string
---@field debug boolean
---@field feedkeys_delay integer

---set options for term-edit
---@param opts TermEditOpts
function M.setup(opts)
  if not opts or not opts.prompt_start then
    vim.notify(
      [[prompt_start is a mandatory argument to setup!
Please provide it with a lua pattern that would match the end of the shell prompt.
Say if your shell prompt is `user@Host ~ $ ` then do:
`require('term-edit').setup { prompt_start = ' %$ ' }`]],
      vim.log.levels.WARN
    )
  end
  M.opts = vim.tbl_deep_extend('force', M.opts, opts)
end

return M
