# term-edit.nvim
Allowing you to edit your command in the terminal just like any other buffer.


https://user-images.githubusercontent.com/38484873/213377673-bed6a3c9-9bc8-4d96-bdf8-a5e5e77ce7dc.mp4


No more smashing left and right arrow when you make a typo.\
You can now smash `h` and `l` instead ;).

## Supported Actions
- Enter insert as if this plugin doesn't exist: `<C-i>`
- Enter insert: `i`, `a`, `A`, `I`.
- Delete: `d<motion>`, `dd`, `D`, `x`.
- Change: `c<motion>`, `cc`, `C`, `s`, `S`.
- Visual change: `c` in visual mode.
- Visual delete: `d` in visual mode.
- Paste: `p` `P` `"<register>p` `"<register>P`
- Replace: `r` in normal mode

## Installation
**Lazy.nvim:**
```lua
{
    'chomosuke/term-edit.nvim',
    lazy = false, -- or ft = 'toggleterm' if you use toggleterm.nvim
}
```
**Packer.nvim:**
```lua
use 'chomosuke/term-edit.nvim'
```
**vim-plug:**
```vim
Plug 'chomosuke/term-edit.nvim'
```

## Setup
```lua
-- Calling require 'term-edit'.setup(opts) is mandatory
require 'term-edit'.setup {
    -- Mandatory option:
    -- Set this to a lua pattern that would match the end of your prompt
    -- For most bash/zsh user this is '%$ '
    -- For most powershell/fish user this is '> '
    -- For most windows cmd user this is '>'
    prompt_end = '%$ ',
    -- How to write lua patterns: https://www.lua.org/pil/20.2.html
}
```

## Configuration
This plugin should work out of the box with default settings.
```lua
local default_opts = {
    -- Setting this true will enable printing debug information with print()
    debug = false,

    -- Number of event loops it takes for <Left>, <Right> or <BS> keys to change
    -- the cursor's position.
    -- If term-edit.nvim is unreliable, increasing this value could help.
    -- Decreasing this value can increase the responsiveness of term-edit.nvim
    feedkeys_delay = 10,

    -- To achine its functionality term-edit.nvim does things like:
    -- `vim.keymap.set('n', 'i', function() --[[magic]] end)`
    --
    -- Let's say instead of 'i', you would want to press 'o' to insert at cursor.
    -- You can either: `vim.keymap.set('n', 'o', 'i', { remap = true })`
    --
    -- Or: `mapping = { n --[[normal mode]] = { i = 'o' } }`
    --   This would resulting in term-edit.nvim running:
    --   `vim.keymap.set('n', 'o', function() --[[magic]] end)`
    --   instead of `vim.keymap.set('n', 'i', function() --[[magic]] end)`.
    --
    -- Note: if lhs is one character, it'll replace all instance of that
    --   characters in the same mode.
    --   I.e. `mapping = { n = { c = 'o' } }` will also replace 'cc' with 'oo'.
    --   To map 'c' to 'o' without mapping 'cc' to 'oo' do:
    --   `mapping = { n = { c = 'o', cc = 'cc' } }`.
    --
    --   Further more, `mapping = { n = { c = false } }` will also disable 'cc'.
    --   To disable 'c' without disabling 'cc' do:
    --   `mapping = { n = { c = false, cc = 'cc' } }`
    --
    -- Setting new_lhs to false would disable the mapping.
    -- I.e. `mapping = { n = { i = false } }` would prevent
    --   `vim.keymap.set('n', 'i', function() --[[magic]] end)`
    --   from running at all.
    --
    -- For more examples and explaination, see :h term-edit.mapping
    mapping = {
        -- mode = {
        --     lhs = new_lhs
        -- }
    },

    -- Used to detect the start of the command
    -- prompt_end = no default, this is mandatory
}
```

## Limitations
- This plugin assumes there are no \<Tab\> though it might tolerate it.
- This plugin might feed more \<Left\>, \<Right\> and \<BS\> to the shell than necessary. This can happen when it is instructed to go somewhere it can't reach or delete something not a part of the command. This may make your terminal beep if you have audio bell enabled.

## Contribution
All PRs are welcome.
