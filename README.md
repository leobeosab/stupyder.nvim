# Stupyder.nvim

Simple markdown codeblock executor. Stupyder acts as a simple frontend for passing codeblock content to a corrosponding tool and then returning the result in a window or virtual text, or just yank to a register. 

## Installation and config
Install with Lazy!

```lua
return {
  dir = "~/proj/stupyder.nvim/",
  cmd = { "Stupyder" },
  config = function ()
    require("stupyder").setup({
      run_options = { print_debug_info = false },
      modes = {
        win = {
          close_shortcut = "q"
        },
        yank = {
          --default
          register = '*'

          --unnamed clipboard
          --register = '"'

          --unnamedplus clipboard
          --register = '+'
        }
      }
    })
  end
}
```

## Demos!



https://github.com/user-attachments/assets/07dda535-2949-4cb0-a83d-81099feeeb17


