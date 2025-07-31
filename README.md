# Stupyder.nvim

Simple markdown codeblock executor. Stupyder acts as a simple frontend: it passes code block content to a corresponding tool and returns the result, either displaying it in a window, as virtual text, or by yanking it to a register. A tool’s configuration can include multiple steps, such as compiling and then running code snippets. 


https://github.com/user-attachments/assets/07dda535-2949-4cb0-a83d-81099feeeb17


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

## Modes
Stupyder has multiple "modes" which are just different ways of handling output from stdout and displaying it to the user (or yanking it directly to a register)

### Virtual Text ( default )
Creates virtual text below the code block.

### Win(dow)
Creates a new window and pumps the output into it.

### Yank
Yanks the output to a user-specified register. Check the example config to see the different registers.


## Tools
Tools are any application we want to pump a code block's content into. Most often, a tool is a compiler or interpreter, but tools like mermaid or curl could also be used.


### Basic Tool config

To add a new tool we assign a `command_context` config to the tool table in our config. The index for the tools table matches the markdown code blocks' language label that are used with the tool. 

**Note:** See CMD / CWD variables documentation for usage in the command and cwd strings.

```lua

local stupyder = require("stupyder")

stupyder.setup({
  tools = {
    python = { contexts = {
      command_context = {
        ext = ".py",
        filename = "test",
        cmd = "python3 {code_file}", -- String or Table of strings
        remove_files = { "some.jpg" }, -- Remove specific files after execution
        cwd = "{tmpdir}/stupyder/python" -- set the cwd for command execution
      }
    }}
  }
})

```

### CMD / CWD variables

```
-- todo, update tmpdir to tmp_dir (I'm for sure going to forget)
{tmpdir} = String; path to the temporary directory of the host 
{code_file} = String; filename of temporary code block content file
```

## Full Config

```lua
local default_config = {
  run_options = {
    print_debug_info = false,
    default_mode = "virtual_lines",
  },
  tools = {
    go = {
      contexts = {
        command_context = {
          ext = ".go",
          cmd = {"go fmt {code_file}", "go run {code_file}"}
        }
      }
    },
    python = {
      contexts = {
        command_context = {
          ext = ".py",
          filename = "test",
          cmd = "python3 {code_file}"
        }
      }
    },
    c = {
      contexts = {
        command_context = {
          ext =".c",
          cmd = { "gcc {code_file} -o out.bin", "./out.bin" },
          remove_files = { "out.bin" },
          cwd = "{tmpdir}/stupyder/c"
        }
      }
    },
    bash = {
      contexts = {
        command_context = {
          ext = ".sh",
          cmd = { "chmod +x {code_file}", "bash {code_file}" }
        }
      }
    },
    lua = {
      contexts = { nvim_context = {} }
    },
  },
  modes = {
    virtual_lines = {
      hl_group = nil,
      error_hl_group = "ErrorMsg"
    },
    win = {
      close_shortcut = "q",
      win_config = {
        split = "below",
        height = 10
      }
    },
    yank = {
      register = "*"
    }
  },
  contexts = {
    default = {},
  },
}

local M = default_config

function M:apply_user_config(config)
    for k, v in pairs(config) do
        M[k] = vim.tbl_deep_extend("force", M[k], v)
    end
end


return M


