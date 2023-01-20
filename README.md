# term-edit.nvim
Allowing you to edit your command in the terminal just like any other buffer.

https://user-images.githubusercontent.com/38484873/213723395-356cdd51-0340-4741-9830-84970ada1913.mp4

No more smashing left and right arrow when you make a typo.\
You can now smash `h` and `l` instead ;).

## 💪 Supported Actions
- Enter insert as if this plugin doesn't exist: `<C-i>`
- Enter insert: `i`, `a`, `A`, `I`.
- Delete: `d<motion>`, `dd`, `D`, `x`.
- Change: `c<motion>`, `cc`, `C`, `s`, `S`.
- Visual change: `c` in visual mode.
- Visual delete: `d` in visual mode.
- Paste: `p` `P` `"<register>p` `"<register>P`
- Replace: `r` in normal mode

## 📦 Installation
**Lazy.nvim:**
```lua
{
    'chomosuke/term-edit.nvim',
    lazy = false, -- or ft = 'toggleterm' if you use toggleterm.nvim
    version = '1.*',
}
```
**Packer.nvim:**
```lua
use { 'chomosuke/term-edit.nvim', tag = 'v1.*' }
```
**vim-plug:**
```vim
Plug 'chomosuke/term-edit.nvim', {'tag': 'v1.*'}
```

## 🛠️ Setup
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

## ⚙️ Configuration
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

    -- Use case 1: I want to press 'o' instead of 'i' to enter insert.
    --   `mapping = { n --[[normal mode]] = { i = 'o' } }`
    --   `vim.keymap.set('n', 'o', 'i', { remap = true })` will achieve the same
    --   thing. (won't work without remap = true)
    -- Use case 2: I want to map 'c' to 'd' and 'd' to 'c'
    --   (keymap with remap is no longer an option)
    --   `mapping = { n = { c = 'd', d = 'c' } }` (will also map 'cc' to 'dd'
    --   and 'dd' to 'cc')
    -- Use case 3: I already mapped s to something else and do not want
    --   term-edit.nvim to override my mapping.
    --   `mapping = { n = { s = false } }`
    --
    -- For more examples and detailed explaination, see :h term-edit.mapping
    mapping = {
        -- mode = {
        --     lhs = new_lhs
        -- }
    },

    -- Used to detect the start of the command
    -- prompt_end = no default, this is mandatory
}
```

## 🚫 Limitations
- This plugin assumes there are no \<Tab\> though it might tolerate it.
- This plugin might feed more \<Left\>, \<Right\> and \<BS\> to the shell than necessary. This can happen when it is instructed to go somewhere it can't reach or delete something not a part of the command. This may make your terminal beep if you have audio bell enabled.

## 💻 Contribution
All PRs are welcome.
