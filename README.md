# term-edit.nvim
Allowing you to edit your command in the terminal just like any other buffer.


https://user-images.githubusercontent.com/38484873/213377673-bed6a3c9-9bc8-4d96-bdf8-a5e5e77ce7dc.mp4


No more smashing left and right arrow when you make a typo.\
You can now smash `h` and `l` instead ;).

## Supported Actions
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

## Limitations
- This plugin assumes there are no \<Tab\> though it might tolerate it.
- This plugin might feed more \<Left\>, \<Right\> and \<BS\> to the shell than necessary. This can happen when it is instructed to go somewhere it can't reach or delete something not a part of the command. This may make your terminal beep if you have audio bell enabled.

## Contribution
All PRs are welcome.
