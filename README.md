# term-edit.nvim
Allowing you to edit your command in the terminal just like any other buffer.

No more smashing left and right arrow when you make a typo.\
You can now smash `h` and `l` instead ;).

## WIP
This is a work in progress. It might or might not work expected.

## Supported Actions
- Enter insert: `i`, `a`, `A`, `I`.
- Delete: `d<motion>`, `dd`, `D`, `x`.
- Change: `c<motion>`, `cc`, `C`, `s`, `S`.
- Visual change: `c` in visual mode.
- Visual delete: `d` in visual mode.
- Paste: `p` `P` `"<register>p` `"<register>P`

## Limitations
term-edit.nvim assumes there are no \<Tab\> though it might tolerate it.
