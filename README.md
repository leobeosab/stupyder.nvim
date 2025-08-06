# Stupyder.nvim
This is still a WIP but functional(no promises) and has most of the features worked out. I'm working on making the config less wonky, more default tool options and adding a couple QoL additions.

**If you encounter an issue**: ~~keep it to yourself~~ Please open a ticket, I'll fix it asap!


Simple markdown codeblock executor. Stupyder acts as a simple frontend: it passes code block content to a corresponding tool and returns the result, either displaying it in a window, as virtual text, or by yanking it to a register. A tool’s configuration can include multiple steps, such as compiling and then running code snippets.


https://github.com/user-attachments/assets/07dda535-2949-4cb0-a83d-81099feeeb17


## Why
I've got a couple niche problems I thought this could solve. Also it was a good enough excuse to learn more of the neovim api. 

**Niche problems**:
* Running README.md example commands / snippets without leaving the readme ( useful for updating the output for documentation )
* I write all my notes in markdown.md in neovim, being able to run snippets/commands in my notes is neat.
* With (self-plug) [brr.nvim](https://github.com/leobeosab) I use it as a repl in my scratch pad, saves time if I don't want to run a whole test or project
  * Or with any other markdown scartch pad like the one in [snacks.nvim](https://github.com/folke/snacks.nvim)


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
![virtual lines  example](./media/windemo.png)

### Win(dow)
Creates a new window and pumps the output into it.
![win example](./media/virtuallinesdemo.png)

### Yank
Yanks the output to a user-specified register. Check the example config to see the different registers.
![yank example](./media/yankdemo.png)

### Change default mode
You can set the default mode in the config
```lua
return {
  dir = "~/proj/stupyder.nvim/",
  cmd = { "Stupyder" },
  config = function ()
    require("stupyder").setup({
      run_options = { default_mode = "virtual_lines" },
    })
  end
}
```


## Tools
Tools are any application we want to pump a code block's content into. Most often, a tool is a compiler or interpreter, but tools like mermaid or curl could also be used.


### Basic Tool config

To add a new tool we assign a `command_context` config to the tool table in our config. The index for the tools table matches the markdown code blocks' language label that are used with the tool. 

**Note:** See CMD / CWD variables documentation for usage in the command and cwd strings.

```lua
local stupyder = require("stupyder")
stupyder.setup({
  run_options = {
    default_mode = "yank"
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
          -- file extension for created files
          ext = ".go",
          -- string or list of commands
          cmd = {"go fmt {code_file}", "go run {code_file}"}
        }
      }
    },
    python = {
      contexts = {
        command_context = {
          ext = ".py",
          -- set a specific filename, default is random
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
          -- list of file s to remove
          remove_files = { "out.bin" },
          -- change where the command(s) are executed, default is pwd
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
      -- Lua is executed using Neovim's lua interpreter, hence the different context
      -- Using lua you can execute actions in neovim from markdown codeblocks
      contexts = { nvim_context = {} }
    },
  },
  modes = {
    virtual_lines = {
      -- highlight group to apply to stdout
      hl_group = nil,
      -- highlight group to apply to stderr 
      error_hl_group = "ErrorMsg"
    },
    win = {
      close_shortcut = "q",
      -- Standard neovim window config
      win_config = {
        split = "below",
        height = 10
      }
    },
    yank = {
      -- what register to "yank" the output to
      register = "*"
    }
  },
  contexts = {
    -- Default settings, you can add cwd, filename, etc
    default = {},
  },
}


