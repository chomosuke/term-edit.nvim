local config = require 'term-edit.config'
local insert_map = require 'term-edit.map.insert_map'
local delete_map = require 'term-edit.map.delete_map'
local change_map = require 'term-edit.map.change_map'
local paste_map = require 'term-edit.map.paste_map'
local replace_map = require 'term-edit.map.replace_map'
local M = {}

---@class AutoCmdOpts
---@field pattern? string[]|string
---@field buffer? integer
---@field desc? string
---@field callback? function|string
---@field command? string
---@field once? boolean
---@field nested? boolean

---create autocmds
---@param name string
---@param autocmds { event: string[]|string, opts: AutoCmdOpts }[]
local function create_autocmds(name, autocmds)
  local id = vim.api.nvim_create_augroup(name, {})
  for _, autocmd in ipairs(autocmds) do
    autocmd.opts.group = id
    vim.api.nvim_create_autocmd(autocmd.event, autocmd.opts)
  end
end

---enable this plugin for the buffer if buf type is terminal
local function maybe_enable()
  if vim.bo.buftype == 'terminal' then
    insert_map.enable()
    delete_map.enable()
    change_map.enable()
    paste_map.enable()
    replace_map.enable()
  end
end

---setup term-edit
---@param opts TermEditOpts
function M.setup(opts)
  config.setup(opts)

  create_autocmds('term_enter_map_insert', {
    {
      event = 'OptionSet',
      opts = {
        pattern = 'buftype',
        callback = maybe_enable,
      },
    },
    { -- tolerate lazy loading
      event = 'BufEnter',
      opts = {
        callback = maybe_enable,
      },
    },
    { -- allow `nvim -c :term` as OptionSet aren't triggered during startup
      event = 'VimEnter',
      opts = {
        callback = maybe_enable,
      },
    },
  })

  maybe_enable() -- tolerate lazy loading
end

return M
