local M = {
  ---@type TermEditOpts
  opts = {
    debug = false,
    feedkeys_delay = 10,
    mapping = {},
    use_up_down_arrows = function()
      return false
    end,
    default_reg = '"',
  },
}

---@class TermEditOpts
---@field prompt_end string|string[]
---@field debug boolean
---@field feedkeys_delay integer
---@field mapping { [string]: { [string]: string|false } }
---@field use_up_down_arrows function
---@field default_reg string

---set options for term-edit
---@param opts TermEditOpts
function M.setup(opts)
  if not opts or not opts.prompt_end then
    vim.notify(
      [[prompt_end is a mandatory argument to setup!
Please provide it with a lua pattern that would match the end of the shell prompt.
Say if your shell prompt is `user@Host ~ $ ` then do:
`require('term-edit').setup { prompt_end = ' %$ ' }`]],
      vim.log.levels.WARN
    )
  end
  M.opts = vim.tbl_deep_extend('force', M.opts, opts)
end

return M
