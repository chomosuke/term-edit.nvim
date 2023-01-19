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

## Limitations
- This plugin assumes there are no \<Tab\> though it might tolerate it.
- This plugin might feed more \<Left\>, \<Right\> and \<BS\> to the shell than necessary. This can happen when it is instructed to go somewhere it can't reach or delete something not a part of the command. This may make your terminal beep if you have audio bell enabled.
